import 'package:flutter/material.dart';

class RecipeDetailScreen extends StatelessWidget {
  final String recipeId;
  final String currentTitle;
  final String currentDescription;
  final String currentImageUrl;
  final List<String> currentTags;

 const RecipeDetailScreen({
  super.key,
  required this.recipeId,
  required this.currentTitle,
  required this.currentDescription,
  required this.currentImageUrl,
  required this.currentTags,
});


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Detail'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (currentImageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  currentImageUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.broken_image,
                    size: 100,
                    color: Colors.grey,
                  ),
                ),
              )
            else
              const Icon(
                Icons.image,
                size: 100,
                color: Colors.grey,
              ),
            const SizedBox(height: 16),
            Text(
              currentTitle,
              style: theme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              currentDescription,
              style: theme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: currentTags
                  .map((tag) => Chip(
                        label: Text(tag),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
