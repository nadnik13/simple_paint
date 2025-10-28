import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

class FireImageRepo {
  final FirebaseFirestore db;
  final int chunkSize = 750 * 1024;

  FireImageRepo(this.db);

  Future<Map<String, Uint8List>> downloadData(String imageId) async {
    final meta = await db.collection('images').doc(imageId).get();
    print('get meta');
    if (!meta.exists) {
      throw StateError('Image $imageId not found');
    }
    try {
      final bgSnap =
          await db
              .collection('images')
              .doc(imageId)
              .collection('background')
              .orderBy('index')
              .get();
      print('bgSnap: ${bgSnap.size}');
    } catch (e) {
      print('Error: $e');
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
