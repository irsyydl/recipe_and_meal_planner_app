import 'package:flutter/material.dart';
import 'package:recipe_and_meal_planner_app/services/meal_planner_service.dart';
import 'package:recipe_and_meal_planner_app/services/recipe_service.dart';

class MealPlannerScreen extends StatefulWidget {
  @override
  State<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  final MealPlannerService _mealPlannerService = MealPlannerService();
  final RecipeService _recipeService = RecipeService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Planner'),
      ),
      body: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
        future: _mealPlannerService.getMealPlanner(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error fetching meal planner: ${snapshot.error}'));
          } else {
            Map<String, List<Map<String, dynamic>>> mealPlanner =
                snapshot.data ?? {};

            return ListView.builder(
              itemCount: mealPlanner.length,
              itemBuilder: (context, index) {
                String date = mealPlanner.keys.elementAt(index);
                List<Map<String, dynamic>> recipes = mealPlanner[date]!;

                return ExpansionTile(
                  title: Text(
                    date,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  children: recipes.map((recipe) {
                    return FutureBuilder<String>(
                      future: _recipeService
                          .getRecipeTitle(recipe['recipeId']),
                      builder: (context, titleSnapshot) {
                        if (titleSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (titleSnapshot.hasError) {
                          return const Text('Error fetching recipe title');
                        } else {
                          return GestureDetector(
                            child: ListTile(
                              title: Text(titleSnapshot.data ?? 'Unknown Recipe'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  await _mealPlannerService.removeFromMealPlanner(
                                      recipe['recipeId'], date);
                                  setState(() {});
                                },
                              ),
                            ),
                          );
                        }
                      },
                    );
                  }).toList(),
                );
              },
            );
          }
        },
      ),
    );
  }
}
