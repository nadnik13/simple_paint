import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

class ImageInfoItem {
  ImageInfoItem({
    required this.imageId,
    required this.userId,
    required this.thumb,
    required this.mime,
    this.createdAt,
  });
  final String imageId;
  final String userId;
  final Uint8List thumb;
  final String mime;
  final DateTime? createdAt;

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
    final mime = m['mime'];
    final createdAt = m['createdAt'];
    
    if (imageId == null || imageId is! String || imageId.isEmpty) {
      throw StateError('Document ${d.id} has invalid imageId: $imageId');
    }
    
    if (userId == null || userId is! String || userId.isEmpty) {
      throw StateError('Document ${d.id} has invalid userId: $userId');
    }
    
    if (thumb == null || thumb is! Uint8List) {
      throw StateError('Document ${d.id} has invalid thumb data: ${thumb.runtimeType}');
    }
    
    if (mime == null || mime is! String || mime.isEmpty) {
      throw StateError('Document ${d.id} has invalid mime: $mime');
    }
    
    // createdAt может быть null, Timestamp или уже DateTime
    DateTime? parsedCreatedAt;
    if (createdAt != null) {
      if (createdAt is Timestamp) {
        parsedCreatedAt = createdAt.toDate();
      } else if (createdAt is DateTime) {
        parsedCreatedAt = createdAt;
      }
    }
    
    print('Successfully parsed document ${d.id} with imageId: $imageId, createdAt: $parsedCreatedAt');
    
    return ImageInfoItem(
      imageId: imageId,
      userId: userId,
      thumb: thumb,
      mime: mime,
      createdAt: parsedCreatedAt,
    );
  }
}
