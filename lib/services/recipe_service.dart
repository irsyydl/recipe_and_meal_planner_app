import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:recipe_and_meal_planner_app/models/recipe.dart';

class RecipeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String _collectionPath = 'recipes';

  Stream<List<Recipe>> getRecipes() {
    return _firestore.collection(_collectionPath).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Recipe.fromFirestore(doc))
          .where((recipe) => recipe.id.isNotEmpty)
          .toList();
    });
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

  Future<Recipe?> getRecipeById(String recipeId) async {
    try {
      if (recipeId.isEmpty) {
        print('Recipe ID is empty.');
        return null;
      }

      DocumentSnapshot<Map<String, dynamic>> recipeDoc =
          await _firestore.collection(_collectionPath).doc(recipeId).get();

      if (recipeDoc.exists) {
        return Recipe.fromFirestore(recipeDoc);
      } else {}
    } catch (e) {
      print('Error fetching recipe by ID: $e');
      return null;
    }
    return null;
  }

  Future<String?> uploadRecipeImage(String recipeId, File? imageFile) async {
    try {
      if (imageFile == null) {
        print('Image file is null.');
        return 'https://via.placeholder.com/150';
      }

      Reference storageRef =
          _storage.ref().child('recipe_images/$recipeId.jpg');

      await storageRef.putFile(imageFile);

      String imageUrl = await storageRef.getDownloadURL();

      return imageUrl;
    } catch (e) {
      print('Error uploading recipe image: $e');
      return 'https://via.placeholder.com/150';
    }
  }

  Future<void> addRecipe({
    required String title,
    required String description,
    required List<String> ingredients,
    required List<String> instructions,
    required File? imageFile,
  }) async {
    try {
      String? imageUrl = await uploadRecipeImage(title, imageFile);

      await _firestore.collection(_collectionPath).add({
        'title': title,
        'description': description,
        'ingredients': ingredients,
        'instructions': instructions,
        'imageUrl': imageUrl,
      });

      print('Recipe added successfully.');
    } catch (e) {
      print('Error adding recipe: $e');
    }
  }
}
