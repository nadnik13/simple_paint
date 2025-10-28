import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simple_paint/data/preview_item.dart';

class GalleryRepo {
  final FirebaseFirestore db;

  GalleryRepo(this.db);

  Future<List<ImageInfoItem>> getPreviews(String userId) async {
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
}
