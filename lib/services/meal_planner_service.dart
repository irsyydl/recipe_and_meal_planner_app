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
        String formattedDate = "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";

        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('mealPlanner')
            .doc(formattedDate + recipeId)
            .set({
              'date': formattedDate,
              'recipeId': recipeId,
            });

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
        QuerySnapshot mealPlannerSnapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('mealPlanner')
            .get();

        Map<String, List<Map<String, dynamic>>> mealPlanner = {};
        for (var doc in mealPlannerSnapshot.docs) {
          Map<String, dynamic> meal = doc.data() as Map<String, dynamic>;
          String date = meal['date'];
          if (mealPlanner[date] == null) {
            mealPlanner[date] = [meal];
          } else {
            mealPlanner[date]!.add(meal);
          }
        }

        return mealPlanner;
      }
      return {};
    } catch (e) {
      print('Error fetching meal planner: $e');
      return {};
    }
  }

  Future<void> removeFromMealPlanner(String recipeId, String date) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('mealPlanner')
            .doc(date + recipeId)
            .delete();
      }
    } catch (e) {
      print('Error removing from meal planner: $e');
    }
  }
}
