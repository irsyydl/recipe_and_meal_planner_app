import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:recipe_and_meal_planner_app/models/recipe.dart';
import 'package:recipe_and_meal_planner_app/services/meal_planner_service.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  final MealPlannerService _mealPlannerService = MealPlannerService();

  RecipeCard({required this.recipe, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          child: Column(
            children: <Widget>[
              Image.network(recipe.imageUrl, fit: BoxFit.cover),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(recipe.title, style: const TextStyle(fontSize: 16)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.event),
                    onPressed: () {
                      _showDatePicker(context, recipe);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context, Recipe recipe) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selectedDate != null) {
      _mealPlannerService.addToMealPlanner(recipe.id, selectedDate);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Recipe added to meal planner on ${DateFormat('yyyy-MM-dd').format(selectedDate)}'),
        ),
      );
    }
  }
}
