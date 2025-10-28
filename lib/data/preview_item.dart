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
    print('ImageInfoItem.fromDoc for document: ${d.id}');

    if (!d.exists) {
      throw StateError('Document ${d.id} does not exist');
    }

    final data = d.data();
    if (data == null) {
      throw StateError('Document ${d.id} has null data');
    }

    final m = data as Map<String, dynamic>;

    // Проверяем наличие всех обязательных полей
    final imageId = m['imageId'];
    final userId = m['userId'];
    final thumb = m['thumb'];
    final createdAt = m['createdAt'];
    final updatedAt = m['updatedAt'];

    if (imageId == null || imageId is! String || imageId.isEmpty) {
      throw StateError('Document ${d.id} has invalid imageId: $imageId');
    }

    if (userId == null || userId is! String || userId.isEmpty) {
      throw StateError('Document ${d.id} has invalid userId: $userId');
    }

    if (thumb == null || thumb is! List || thumb.isEmpty) {
      throw StateError(
        'Document ${d.id} has invalid thumb data: ${thumb.runtimeType}',
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
        print('parsedUpdatedAt createdAt is Timestamp');
        parsedCreatedAt = updatedAt.toDate();
      } else if (updatedAt is DateTime) {
        print('parsedUpdatedAt createdAt is DateTime');
        parsedCreatedAt = updatedAt;
      }
    }
    print(
      'Successfully parsed document ${d.id} with imageId: $imageId, createdAt: $parsedCreatedAt',
    );
    return ImageInfoItem(
      imageId: imageId,
      userId: userId,
      thumb: Uint8List.fromList((thumb).cast<int>()),
      createdAt: parsedCreatedAt,
      updatedAt: parsedUpdatedAt,
    );
  }
}
