import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import 'add_recipe_screen.dart';
import 'recipe_detail_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userId;

  const HomeScreen({super.key, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> _recipes = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final List<String> _selectedTags = [];

  final List<String> _allTags = ['Vegan', 'Dessert', 'Quick', 'Healthy', 'Dinner'];

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    final allRecipes = await _firestoreService.fetchRecipes();
    setState(() {
      _recipes = allRecipes;
      _isLoading = false;
    });
  }

  void _onRecipeTap(Map<String, dynamic> recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailScreen(
          recipeId: recipe['id'],
          currentTitle: recipe['title'],
          currentDescription: recipe['description'],
          currentImageUrl: recipe['imageUrl'],
          currentTags: List<String>.from(recipe['tags'] ?? []),
        ),
      ),
    );
  }

  void _onAddRecipe() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddRecipeScreen(userId: widget.userId),
      ),
    );
    _loadRecipes();
  }

  List<Map<String, dynamic>> get _filteredRecipes {
    return _recipes.where((recipe) {
      final matchesSearch = recipe['title'].toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesTags = _selectedTags.isEmpty || _selectedTags.any((tag) => (recipe['tags'] ?? []).contains(tag));
      return matchesSearch && matchesTags;
    }).toList();
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.lightBlue[50],
        fontFamily: 'Arial',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 16),
          bodyMedium: TextStyle(fontSize: 14),
          titleLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.purple[50],
          title: const Text('Recipe App', style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadRecipes,
            )
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.green),
                child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(userId: widget.userId),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: _logout,
              ),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadRecipes,
                child: Container(
                  color: Colors.lightBlue[50],
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Search Recipes',
                            prefixIcon: Icon(Icons.search),
                          ),
                          onChanged: (value) => setState(() => _searchQuery = value),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: _allTags.map((tag) => FilterChip(
                                label: Text(tag),
                                selected: _selectedTags.contains(tag),
                                onSelected: (selected) => setState(() {
                                  selected ? _selectedTags.add(tag) : _selectedTags.remove(tag);
                                }),
                              )).toList(),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _filteredRecipes.length,
                            itemBuilder: (context, index) {
                              final recipe = _filteredRecipes[index];
                              final String imageUrl = recipe['imageUrl'] ?? '';
                              final bool isAppwriteFile = !imageUrl.startsWith('http');

                              return Card(
                                color: Colors.purple[50],
                                child: ListTile(
                                  leading: imageUrl.isNotEmpty
                                      ? Image.network(
                                          isAppwriteFile
                                              ? AppwriteHelper.getPreviewUrl(imageUrl)
                                              : imageUrl,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                                        )
                                      : const Icon(Icons.image),
                                  title: Text(recipe['title'], style: const TextStyle(fontWeight: FontWeight.w600)),
                                  subtitle: Text(recipe['description'], style: const TextStyle(fontSize: 13)),
                                  onTap: () => _onRecipeTap(recipe),
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: _onAddRecipe,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class AppwriteHelper {
  static const String endpoint = 'https://cloud.appwrite.io/v1';
  static const String bucketId = '6871be210034a4edc491';

  static String getPreviewUrl(String fileId) {
    return '$endpoint/storage/buckets/$bucketId/files/$fileId/preview';
  }
}
