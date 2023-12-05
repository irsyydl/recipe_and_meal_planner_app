import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recipe_and_meal_planner_app/services/auth_service.dart';

class ShoppingListService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();

  Future<List<Map<String, String>>> getShoppingList() async {
    try {
      String? userId = await _authService.getCurrentUserId();
      if (userId != null) {
        CollectionReference<Map<String, dynamic>> shoppingListCollection =
            _firestore
                .collection('users')
                .doc(userId)
                .collection('shoppingList');

        QuerySnapshot<Map<String, dynamic>> querySnapshot =
            await shoppingListCollection.get();

        List<Map<String, String>> shoppingList = [];

        for (QueryDocumentSnapshot<Map<String, dynamic>> doc
            in querySnapshot.docs) {
          if (doc.data().containsKey('ingredient')) {
            String ingredient = doc['ingredient'];
            String recipeId = doc.id.split(ingredient)[0];

            shoppingList.add({'recipeId': recipeId, 'ingredient': ingredient});
          }
        }

        return shoppingList;
      } else {
        print('User not authenticated.');
        return [];
      }
    } catch (e) {
      print('Error fetching shopping list: $e');
      return [];
    }
  }

  Future<void> addIngredientsToShoppingList(String recipeId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> recipeDoc =
          await _firestore.collection('recipes').doc(recipeId).get();

      if (recipeDoc.exists) {
        List<String> ingredients =
            List<String>.from(recipeDoc.get('ingredients') ?? []);

        for (String ingredient in ingredients) {
          await _firestore
              .collection('users')
              .doc(_auth.currentUser!.uid)
              .collection('shoppingList')
              .doc(recipeId + ingredient)
              .set({'ingredient': ingredient});
        }

        print('Ingredients added to shopping list successfully.');
      } else {
        print('Recipe not found.');
      }
    } catch (e) {
      print('Error adding ingredients to shopping list: $e');
    }
  }

  Future<void> removeIngredientFromShoppingList(
      String recipeId, String ingredient) async {
    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('shoppingList')
          .doc(recipeId + ingredient)
          .delete();

      print('Ingredient removed from shopping list successfully.');
    } catch (e) {
      print('Error removing ingredient from shopping list: $e');
    }
  }
}
