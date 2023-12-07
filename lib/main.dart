import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:recipe_and_meal_planner_app/firebase_options.dart';
import 'package:recipe_and_meal_planner_app/screens/authentication/login_screen.dart';
import 'package:recipe_and_meal_planner_app/screens/authentication/registration_screen.dart';
import 'package:recipe_and_meal_planner_app/screens/home_screen.dart';
import 'package:recipe_and_meal_planner_app/screens/introduction_screen.dart';
import 'package:recipe_and_meal_planner_app/screens/meal_planner_screen.dart';
import 'package:recipe_and_meal_planner_app/screens/profile_screen.dart';
import 'package:recipe_and_meal_planner_app/screens/recipe_upload_screen.dart';
import 'package:recipe_and_meal_planner_app/screens/shopping_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Recipe and Meal Planner',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      initialRoute: '/intro',
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegistrationScreen(),
        '/home': (context) => HomeScreen(),
        '/shoppingList': (context) => ShoppingListScreen(),
        '/mealPlanner': (context) => MealPlannerScreen(),
        '/uploadRecipe': (context) => const RecipeUploadScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/intro': (context) => IntroductionScreen(),
      },
    );
  }
}
