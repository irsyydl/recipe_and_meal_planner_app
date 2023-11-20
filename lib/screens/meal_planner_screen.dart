import 'package:flutter/material.dart';
import 'package:recipe_and_meal_planner_app/services/meal_planner_service.dart';

class MealPlannerScreen extends StatelessWidget {
  final MealPlannerService _mealPlannerService = MealPlannerService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meal Planner'),
      ),
      body: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
        future: _mealPlannerService.getMealPlanner(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
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

                return ListTile(
                  title: Text(date),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var recipe in recipes)
                        FutureBuilder<String>(
                          future: _mealPlannerService.getRecipeTitle(recipe['recipeId']),
                          builder: (context, titleSnapshot) {
                            if (titleSnapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (titleSnapshot.hasError) {
                              return Text('Error fetching recipe title');
                            } else {
                              return Text(titleSnapshot.data ?? 'Unknown Recipe');
                            }
                          },
                        ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
