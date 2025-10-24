import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simple_paint/data/preview_item.dart';

class FireImageRepo {
  final FirebaseFirestore db;
  final int chunkSize = 750 * 1024;

  FireImageRepo(this.db);

  /// Загрузка нового изображения:
  /// - режем оригинал на чанки -> images/{imageId}/chunks
  /// - пишем метаданные -> images/{imageId}
  /// - пишем превью -> preview_images/{imageId}
  Future<String> uploadOriginalWithPreview({
    required String userId,
    required Uint8List originalBytes,
    required Uint8List previewBytes,
    required String mime,
  }) async {
    final doc = db.collection('images').doc();
    final imageId = doc.id;

    // 1) метаданные
    final chunkCount = (originalBytes.length + chunkSize - 1) ~/ chunkSize;
    final metaRef = doc;
    await metaRef.set({
      'ownerUid': userId,
      'mime': mime,
      'size': originalBytes.length,
      'chunkCount': chunkCount,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 2) чанки (последовательно, чтобы не упереться в лимиты)
    final chunks = metaRef.collection('chunks');
    var offset = 0;
    for (int i = 0; i < chunkCount; i++) {
      final end =
          (offset + chunkSize > originalBytes.length)
              ? originalBytes.length
              : offset + chunkSize;
      final slice = originalBytes.sublist(offset, end);
      offset = end;

      await chunks.add({'index': i, 'data': slice});
    }

    final thumbBytes = previewBytes;
    await db.collection('preview_images').doc(imageId).set({
      'imageId': imageId,
      'userId': userId,
      'thumb': thumbBytes,
      'mime': 'image/jpeg',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return imageId;
  }

  /// Стрим превью для галереи пользователя
  Future<List<ImageInfoItem>> previews(String userId) async {
    print('FireImageRepo.previews() called for userId: $userId');

    if (userId.isEmpty) {
      print('Error: userId is empty');
      return Future.error('User ID cannot be empty');
    }

    try {
      print('Creating Firestore query...');
      // Используем только фильтрацию по userId без сортировки, чтобы избежать составного индекса
      // Сортировку выполним на клиенте
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
          // Пропускаем поврежденные документы вместо падения всего стрима
          continue;
        }
      }

      // Сортируем на клиенте по createdAt (новые сверху)
      items.sort((a, b) {
        // Если у обоих есть createdAt, сортируем по нему
        if (a.createdAt != null && b.createdAt != null) {
          return b.createdAt!.compareTo(a.createdAt!);
        }
        // Если у одного есть createdAt, а у другого нет, приоритет тому, у кого есть
        if (a.createdAt != null && b.createdAt == null) {
          return -1;
        }
        if (a.createdAt == null && b.createdAt != null) {
          return 1;
        }
        // Если у обоих нет createdAt, сортируем по imageId (который содержит timestamp от Firestore)
        return b.imageId.compareTo(a.imageId);
      });

      print('Returning ${items.length} valid items (sorted on client)');
      return items;
    } catch (e) {
      print('Error creating previews stream: $e');
      return Future.error('Failed to create previews stream: $e');
    }
  }

  /// Скачивание и сборка оригинала
  Future<Uint8List> downloadOriginal(String imageId) async {
    final meta = await db.collection('images').doc(imageId).get();
    if (!meta.exists) {
      throw StateError('Image $imageId not found');
    }
    final chunkSnap =
        await db
            .collection('images')
            .doc(imageId)
            .collection('chunks')
            .orderBy('index')
            .get();

    // склеиваем
    final parts = <Uint8List>[];
    var total = 0;
    for (final d in chunkSnap.docs) {
      final p = d['data'] as Uint8List;
      parts.add(p);
      total += p.length;
    }
    final out = Uint8List(total);
    var off = 0;
    for (final p in parts) {
      out.setRange(off, off + p.length, p);
      off += p.length;
    }
    return out;
  }

  /// Замена оригинала (редактирование): перезапишем чанки и мета, превью — тоже
  Future<void> replaceImage({
    required String imageId,
    required String userId,
    required Uint8List originalBytes,
    required Uint8List previewBytes,
    required String mime,
  }) async {
    final metaRef = db.collection('images').doc(imageId);

    // 1) удалить старые чанки
    final old = await metaRef.collection('chunks').get();
    for (final d in old.docs) {
      await d.reference.delete();
    }

    // 2) записать новые чанки
    final chunkCount = (originalBytes.length + chunkSize - 1) ~/ chunkSize;
    var offset = 0;
    for (int i = 0; i < chunkCount; i++) {
      final end =
          (offset + chunkSize > originalBytes.length)
              ? originalBytes.length
              : offset + chunkSize;
      final slice = originalBytes.sublist(offset, end);
      offset = end;
      await metaRef.collection('chunks').add({'index': i, 'data': slice});
    }

    // 3) обновить метаданные
    await metaRef.update({
      'ownerUid': userId,
      'mime': mime,
      'size': originalBytes.length,
      'chunkCount': chunkCount,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // 4) превью
    final thumb = previewBytes;
    await db.collection('preview_images').doc(imageId).update({
      'thumb': thumb,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Удаление (и превью, и оригинала)
  Future<void> deleteImage(String imageId) async {
    final metaRef = db.collection('images').doc(imageId);
    final chunks = await metaRef.collection('chunks').get();
    for (final c in chunks.docs) {
      await c.reference.delete();
    }
    await metaRef.delete();
    await db.collection('preview_images').doc(imageId).delete();
  }
}
