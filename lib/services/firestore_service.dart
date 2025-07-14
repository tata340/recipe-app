import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUserProfile({
    required String userId,
    required String name,
    required String profileImageUrl,
  }) async {
    await _firestore.collection('users').doc(userId).set({
      'userId': userId,
      'name': name,
      'profileImageUrl': profileImageUrl,
    });
  }

  Future<void> addRecipe({
    required String title,
    required String description,
    required String imageUrl,
    required List<String> tags,
    required String userId,
  }) async {
    await _firestore.collection('recipes').add({
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'tags': tags,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateRecipe({
    required String recipeId,
    required String title,
    required String description,
    required String imageUrl,
    required List<String> tags,
  }) async {
    await _firestore.collection('recipes').doc(recipeId).update({
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'tags': tags,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> fetchRecipes() async {
    final snapshot = await _firestore
        .collection('recipes')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
