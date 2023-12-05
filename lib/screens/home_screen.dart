import 'package:flutter/material.dart';
import 'package:recipe_and_meal_planner_app/models/recipe.dart';
import 'package:recipe_and_meal_planner_app/screens/recipe_details_screen.dart';
// import 'package:recipe_and_meal_planner_app/services/auth_service.dart';
import 'package:recipe_and_meal_planner_app/services/recipe_service.dart';
import 'package:recipe_and_meal_planner_app/widgets/app_drawer.dart';
import 'package:recipe_and_meal_planner_app/widgets/recipe_card.dart';

class HomeScreen extends StatelessWidget {
  final RecipeService _recipeService = RecipeService();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      drawer: AppDrawer(),
      body: StreamBuilder<List<Recipe>>(
        stream: _recipeService.getRecipes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Recipe> recipes = snapshot.data ?? [];
            return ListView.builder(
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                return RecipeCard(
                  recipe: recipes[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailsScreen(
                          recipeId: recipes[index].id,
                          recipe: recipes[index],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
