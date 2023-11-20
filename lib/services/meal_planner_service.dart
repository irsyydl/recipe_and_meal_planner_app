import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recipe_and_meal_planner_app/services/shopping_list_service.dart';

class MealPlannerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ShoppingListService _shoppingListService = ShoppingListService();

  Future<void> addToMealPlanner(String recipeId, DateTime selectedDate) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String formattedDate =
            "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";

        Map<String, List<Map<String, dynamic>>> mealPlanner =
            await getMealPlanner();

        mealPlanner.putIfAbsent(formattedDate, () => []);
        mealPlanner[formattedDate]!.add({'recipeId': recipeId});
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('mealPlanner')
            .doc('planner')
            .set(mealPlanner);

        await _shoppingListService.addIngredientsToShoppingList(recipeId);
      }
    } catch (e) {
      print('Error adding to meal planner: $e');
    }
  }

  Future<Map<String, List<Map<String, dynamic>>>> getMealPlanner() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot mealPlannerDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('mealPlanner')
            .doc('planner')
            .get();

        if (mealPlannerDoc.exists) {
          Map<String, dynamic> rawMealPlanner =
              mealPlannerDoc.data() as Map<String, dynamic>;
          Map<String, List<Map<String, dynamic>>> mealPlanner = {};

          rawMealPlanner.forEach((key, value) {
            if (value is List) {
              mealPlanner[key] = List<Map<String, dynamic>>.from(
                  value.map((entry) => Map<String, dynamic>.from(entry)));
            }
          });

          return mealPlanner;
        } else {
          return {};
        }
      }
      return {};
    } catch (e) {
      print('Error fetching meal planner: $e');
      return {};
    }
  }

  Future<List<String>> getMealPlannerRecipeIds(String recipeId) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        Map<String, List<Map<String, dynamic>>> mealPlanner =
            await getMealPlanner();

        List<String> recipeIds = [];
        mealPlanner.forEach((date, recipes) {
          recipes.forEach((recipe) {
            String recipeId = recipe['recipeId'];
            if (recipeId.isNotEmpty && !recipeIds.contains(recipeId)) {
              recipeIds.add(recipeId);
            }
          });
        });

        return recipeIds;
      }
      return [];
    } catch (e) {
      print('Error fetching meal planner recipe IDs: $e');
      return [];
    }
  }

  Future<String> getRecipeTitle(String recipeId) async {
    try {
      DocumentSnapshot recipeDoc =
          await _firestore.collection('recipes').doc(recipeId).get();

      if (recipeDoc.exists) {
        return recipeDoc.get('title') ?? 'Unknown Recipe';
      } else {
        return 'Unknown Recipe';
      }
    } catch (e) {
      print('Error fetching recipe title: $e');
      return 'Unknown Recipe';
    }
  }
}
