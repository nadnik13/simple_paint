import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simple_paint/data/preview_item.dart';

class GalleryRepo {
  final FirebaseFirestore db;

  GalleryRepo(this.db);

  Future<List<ImageInfoItem>> getPreviews(String userId) async {
    if (userId.isEmpty) {
      return Future.error('User ID cannot be empty');
    }

    try {
      final querySnapshot =
          await db
              .collection('preview_images')
              .where('userId', isEqualTo: userId)
              .get();

      final items = <ImageInfoItem>[];
      for (final doc in querySnapshot.docs) {
        try {
          final item = ImageInfoItem.fromDoc(doc);
          items.add(item);
        } catch (e) {
          continue;
        }
      }

      items.sort((a, b) {
        if (a.updatedAt != null && b.updatedAt != null) {
          return b.updatedAt!.compareTo(a.updatedAt!);
        }
        if (a.updatedAt != null && b.createdAt == null) {
          return -1;
        }
        if (a.updatedAt == null && b.updatedAt != null) {
          return 1;
        }
        if (a.createdAt != null && b.createdAt != null) {
          return b.createdAt!.compareTo(a.createdAt!);
        }
        return b.imageId.compareTo(a.imageId);
      });
      return items;
    } catch (e) {
      return Future.error('Ошибка создания превью: $e');
    }
  }
}
