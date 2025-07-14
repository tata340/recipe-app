// lib/widgets/recipe_card.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecipeCard extends StatelessWidget {
  final DocumentSnapshot recipe;
  final VoidCallback onTap;

  const RecipeCard({super.key, required this.recipe, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final data = recipe.data() as Map<String, dynamic>;
    final user = FirebaseAuth.instance.currentUser;
    final hasLiked = (data['likedBy'] as List).contains(user?.uid);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with rounded top corners
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: FadeInImage.assetNetwork(
                placeholder: 'assets/images/placeholder.png',
                image: data['imageUrl'] ?? '',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                imageErrorBuilder: (_, __, ___) => Image.asset(
                  'assets/images/placeholder.png',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['title'] ?? 'Untitled',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.timer, size: 18, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(data['cookingTime'] ?? 'N/A'),
                      const Spacer(),
                      GestureDetector(
                        onTap: () async {
                          final uid = user?.uid;
                          if (uid == null) return;
                          await recipe.reference.update({
                            'likedBy': hasLiked
                                ? FieldValue.arrayRemove([uid])
                                : FieldValue.arrayUnion([uid]),
                            'likes': FieldValue.increment(hasLiked ? -1 : 1),
                          });
                        },
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Icon(
                            hasLiked ? Icons.favorite : Icons.favorite_border,
                            key: ValueKey(hasLiked),
                            color: hasLiked ? Colors.red : Colors.grey,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
