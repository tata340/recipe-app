import 'package:cloud_firestore/cloud_firestore.dart';

class Recipe {
  String id;
  String title;
  String description;
  String cookingTime;
  List<String> ingredients;
  String imageUrl;
  String authorId;
  String authorName;
  int likes;
  List<String> likedBy;
  Timestamp createdAt;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.cookingTime,
    required this.ingredients,
    required this.imageUrl,
    required this.authorId,
    required this.authorName,
    required this.likes,
    required this.likedBy,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'cookingTime': cookingTime,
      'ingredients': ingredients,
      'imageUrl': imageUrl,
      'authorId': authorId,
      'authorName': authorName,
      'likes': likes,
      'likedBy': likedBy,
      'createdAt': createdAt,
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> data, String documentId) {
    return Recipe(
      id: documentId,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      cookingTime: data['cookingTime'] ?? '',
      ingredients: List<String>.from(data['ingredients'] ?? []),
      imageUrl: data['imageUrl'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      likes: data['likes'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}
