import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_recipe_screen.dart';
import 'screens/edit_recipe_screen.dart';
import 'screens/recipe_detail_screen.dart';
import 'firebase_options.dart'; // Ensure this is generated via `flutterfire configure`


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      initialRoute: FirebaseAuth.instance.currentUser == null ? '/login' : '/home',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) {
          final userId = FirebaseAuth.instance.currentUser?.uid;
          return userId != null
              ? HomeScreen(userId: userId)
              : const LoginScreen();
        },
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/add') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => AddRecipeScreen(userId: args['userId']),
          );
        } else if (settings.name == '/edit') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => EditRecipeScreen(
              recipeId: args['recipeId'],
              currentTitle: args['currentTitle'],
              currentDescription: args['currentDescription'],
              currentImageUrl: args['currentImageUrl'],
              currentTags: args['currentTags'],
            ),
          );
        } else if (settings.name == '/details') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => RecipeDetailScreen(
              recipeId: args['recipeId'],
              currentTitle: args['currentTitle'],
              currentDescription: args['currentDescription'],
              currentImageUrl: args['currentImageUrl'],
              currentTags: args['currentTags'],
            ),
          );
        }
        return null;
      },
    );
  }
}
