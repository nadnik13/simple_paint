import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

class ImageInfoItem {
  ImageInfoItem({
    required this.imageId,
    required this.userId,
    required this.thumb,
    this.createdAt,
    this.updatedAt,
  });
  final String imageId;
  final String userId;
  final Uint8List thumb;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ImageInfoItem.fromDoc(DocumentSnapshot d) {
    if (!d.exists) {
      throw StateError('Изображение ${d.id} не существует');
    }

    final data = d.data();
    if (data == null) {
      throw StateError('У изображения ${d.id} нет данных');
    }

    final m = data as Map<String, dynamic>;

    final imageId = m['imageId'];
    final userId = m['userId'];
    final thumb = m['thumb'];
    final createdAt = m['createdAt'];
    final updatedAt = m['updatedAt'];

    if (imageId == null || imageId is! String || imageId.isEmpty) {
      throw StateError('У изображения ${d.id} некорретный imageId $imageId');
    }

    if (userId == null || userId is! String || userId.isEmpty) {
      throw StateError('У изображения ${d.id} некорретный userId: $userId');
    }

    if (thumb == null || thumb is! List || thumb.isEmpty) {
      throw StateError(
        'У изображения ${d.id} некорретный preview: ${thumb.runtimeType}',
      );
    }

    DateTime? parsedCreatedAt;
    if (createdAt != null) {
      if (createdAt is Timestamp) {
        parsedCreatedAt = createdAt.toDate();
      } else if (createdAt is DateTime) {
        parsedCreatedAt = createdAt;
      }
    }

    DateTime? parsedUpdatedAt;
    if (updatedAt != null) {
      if (updatedAt is Timestamp) {
        parsedCreatedAt = updatedAt.toDate();
      } else if (updatedAt is DateTime) {
        parsedCreatedAt = updatedAt;
      }
    }
    return ImageInfoItem(
      imageId: imageId,
      userId: userId,
      thumb: Uint8List.fromList((thumb).cast<int>()),
      createdAt: parsedCreatedAt,
      updatedAt: parsedUpdatedAt,
    );
  }
}
