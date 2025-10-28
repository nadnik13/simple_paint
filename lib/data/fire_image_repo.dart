import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simple_paint/data/preview_item.dart';

class FireImageRepo {
  final FirebaseFirestore db;
  final int chunkSize = 750 * 1024;

  FireImageRepo(this.db);

  Future<List<ImageInfoItem>> previews(String userId) async {
    print('FireImageRepo.previews() called for userId: $userId');

    if (userId.isEmpty) {
      print('Error: userId is empty');
      return Future.error('User ID cannot be empty');
    }

    try {
      print('Creating Firestore query...');
      final querySnapshot =
          await db
              .collection('preview_images')
              .where('userId', isEqualTo: userId)
              .get();

      print('Received snapshot with ${querySnapshot.docs.length} documents');

      final items = <ImageInfoItem>[];
      for (final doc in querySnapshot.docs) {
        try {
          final item = ImageInfoItem.fromDoc(doc);
          items.add(item);
          print('Successfully parsed document: ${doc.id}');
        } catch (e) {
          print('Error parsing document ${doc.id}: $e');
          continue;
        }
      }
      //:TODO доделать
      items.sort((a, b) {
        if (a.updatedAt != null && b.updatedAt != null) {
          return b.updatedAt!.compareTo(a.updatedAt!);
        }
        if (a.updatedAt != null && b.createdAt == null) {
          throw Exception('a.updatedAt != null && b.createdAt == null');
          return -1;
        }
        if (a.updatedAt == null && b.updatedAt != null) {
          throw Exception('a.updatedAt == null && b.updatedAt != null');
          return 1;
        }
        if (a.createdAt != null && b.createdAt != null) {
          return b.createdAt!.compareTo(a.createdAt!);
        }
        return b.imageId.compareTo(a.imageId);
      });

      print('Returning ${items.length} valid items (sorted on client)');
      return items;
    } catch (e) {
      print('Error creating previews stream: $e');
      return Future.error('Failed to create previews stream: $e');
    }
  }

  Future<Map<String, Uint8List>> downloadData(String imageId) async {
    final meta = await db.collection('images').doc(imageId).get();
    print('get meta');

    if (!meta.exists) {
      throw StateError('Image $imageId not found');
    }
    final bgSnap =
        await db
            .collection('images')
            .doc(imageId)
            .collection('background')
            .orderBy('index')
            .get();
    print('bgSnap: ${bgSnap.size}');

    final linesSnap =
        await db
            .collection('images')
            .doc(imageId)
            .collection('lines')
            .orderBy('index')
            .get();

    print('linesSnap: ${linesSnap.size}');
    return {'background': _getBytes(bgSnap), 'lines': _getBytes(linesSnap)};
  }

  Uint8List _getBytes(QuerySnapshot<Map<String, dynamic>> snap) {
    final parts = <Uint8List>[];
    var total = 0;
    for (final d in snap.docs) {
      final data = Uint8List.fromList((d['data'] as List).cast<int>());
      parts.add(data);
      total += data.length;
    }
    final out = Uint8List(total);
    var off = 0;
    for (final p in parts) {
      out.setRange(off, off + p.length, p);
      off += p.length;
    }
    return out;
  }

  Future<String> saveImage({
    required String userId,
    required String? imageId,
    required Uint8List bgBytes,
    required Uint8List previewBytes,
    required Uint8List linesBytes,
  }) async {
    print('saveImage fireStore');

    if (imageId == null) {
      print('_uploadImage: ${previewBytes.length}');
      return _uploadImage(
        userId: userId,
        bgBytes: bgBytes,
        previewBytes: previewBytes,
        linesBytes: linesBytes,
      );
    } else {
      print('_replaceImage: ${previewBytes.length}');
      return _replaceImage(
        imageId: imageId,
        userId: userId,
        bgBytes: bgBytes,
        previewBytes: previewBytes,
        linesBytes: linesBytes,
      );
    }
  }

  Future<void> _removeChunks(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) async {
    for (final d in snapshot.docs) {
      await d.reference.delete();
    }
  }

  Future<void> _uploadChunks(
    int chunkCount,
    Uint8List bytes,
    CollectionReference<Map<String, dynamic>> collection,
  ) async {
    print('_uploadChunks');
    var offset = 0;
    for (int i = 0; i < chunkCount; i++) {
      final end =
          (offset + chunkSize > bytes.length)
              ? bytes.length
              : offset + chunkSize;
      final slice = bytes.sublist(offset, end);
      offset = end;

      final metaRef = collection.doc();
      final chunkId = metaRef.id;
      await metaRef.set({'chunkId': chunkId, 'index': i, 'data': slice});
    }
  }

  Future<String> _uploadImage({
    required String userId,
    required Uint8List bgBytes,
    required Uint8List previewBytes,
    required Uint8List linesBytes,
  }) async {
    print('_uploadImage fireStore');
    final metaRef = db.collection('images').doc();
    final imageId = metaRef.id;
    final bgChunkCount = (bgBytes.length + chunkSize - 1) ~/ chunkSize;
    final linesChunkCount = (linesBytes.length + chunkSize - 1) ~/ chunkSize;
    print('bgChunkCount=$bgChunkCount linesChunkCount=$linesChunkCount');
    try {
      await metaRef.set({
        'ownerUid': userId,
        'imageId': imageId,
        'size': bgBytes.length,
        'bgChunkCount': bgChunkCount,
        'linesChunkCount': linesChunkCount,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print(e);
    }

    print('metaRef set');

    await _uploadChunks(
      bgChunkCount,
      bgBytes,
      metaRef.collection('background'),
    );
    print('_uploadedChunks background');
    await _uploadChunks(
      linesChunkCount,
      linesBytes,
      metaRef.collection('lines'),
    );
    print('_uploadedChunks lines');

    final thumbBytes = previewBytes;
    await db.collection('preview_images').doc(imageId).set({
      'imageId': imageId,
      'userId': userId,
      'thumb': thumbBytes,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return imageId;
  }

  Future<String> _replaceImage({
    required String imageId,
    required String userId,
    required Uint8List bgBytes,
    required Uint8List previewBytes,
    required Uint8List linesBytes,
  }) async {
    final metaRef = db.collection('images').doc(imageId);

    final bgOldData = await metaRef.collection('background').get();
    final linesOldData = await metaRef.collection('lines').get();
    _removeChunks(bgOldData);
    _removeChunks(linesOldData);

    final bgChunkCount = (bgBytes.length + chunkSize - 1) ~/ chunkSize;
    final linesChunkCount = (linesBytes.length + chunkSize - 1) ~/ chunkSize;

    await metaRef.update({
      'ownerUid': userId,
      'size': bgBytes.length,
      'bgChunkCount': bgChunkCount,
      'linesChunkCount': linesChunkCount,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _uploadChunks(
      bgChunkCount,
      bgBytes,
      metaRef.collection('background'),
    );
    await _uploadChunks(
      linesChunkCount,
      linesBytes,
      metaRef.collection('lines'),
    );

    print('thumb updated: ${FieldValue.serverTimestamp()}');
    final thumbBytes = previewBytes;
    await db.collection('preview_images').doc(imageId).update({
      'thumb': thumbBytes,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return imageId;
  }

  Future<void> deleteImage(String imageId) async {
    final metaRef = db.collection('images').doc(imageId);
    final bgChunks = await metaRef.collection('background').get();
    final linesChunks = await metaRef.collection('lines').get();
    _removeChunks(bgChunks);
    _removeChunks(linesChunks);
    await metaRef.delete();
    await db.collection('preview_images').doc(imageId).delete();
  }
}
