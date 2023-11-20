import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recipe_and_meal_planner_app/services/auth_service.dart';

class ShoppingListService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();

  Future<void> addToShoppingList(String recipeId) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('shoppingList')
            .doc(recipeId)
            .set({});
      }
    } catch (e) {
      print('Error adding to shopping list: $e');
    }
  }

  Future<List<String>> getShoppingList() async {
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

        List<String> shoppingList = [];

        for (QueryDocumentSnapshot<Map<String, dynamic>> doc
            in querySnapshot.docs) {
          // Check if the document contains an 'ingredients' array
          if (doc.data().containsKey('ingredients')) {
            List<dynamic> ingredients = doc['ingredients'];

            // Add each ingredient to the shopping list
            shoppingList
                .addAll(ingredients.map((ingredient) => ingredient.toString()));
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

        await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .collection('shoppingList')
            .doc(recipeId)
            .set({'ingredients': ingredients});

        print('Ingredients added to shopping list successfully.');
      } else {
        print('Recipe not found.');
      }
    } catch (e) {
      print('Error adding ingredients to shopping list: $e');
    }
  }
}