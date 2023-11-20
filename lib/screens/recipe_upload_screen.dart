import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recipe_and_meal_planner_app/services/recipe_service.dart';

class RecipeUploadScreen extends StatefulWidget {
  @override
  _RecipeUploadScreenState createState() => _RecipeUploadScreenState();
}

class _RecipeUploadScreenState extends State<RecipeUploadScreen> {
  final RecipeService _recipeService = RecipeService();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController ingredientsController = TextEditingController();
  TextEditingController instructionsController = TextEditingController();
  File? _image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Recipe'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _image != null ? Image.file(_image!) : SizedBox(height: 16),
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextFormField(
                controller: ingredientsController,
                decoration: InputDecoration(labelText: 'Ingredients'),
              ),
              TextFormField(
                controller: instructionsController,
                decoration: InputDecoration(labelText: 'Instructions'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await _pickImage();
                },
                child: Text('Pick Image'),
              ),
              ElevatedButton(
                onPressed: () async {
                  String title = titleController.text;
                  String description = descriptionController.text;
                  List<String> ingredients =
                      ingredientsController.text.split(',');
                  List<String> instructions =
                      instructionsController.text.split(',');

                  await _uploadRecipe(
                    title,
                    description,
                    ingredients,
                    instructions,
                  );
                },
                child: Text('Upload Recipe'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadRecipe(
    String title,
    String description,
    List<String> ingredients,
    List<String> instructions,
  ) async {
    try {
      await _recipeService.addRecipe(
        title: title,
        description: description,
        ingredients: ingredients,
        instructions: instructions,
        imageFile: _image,
      );

      print('Recipe uploaded successfully!');
    } catch (e) {
      print('Error uploading recipe: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading recipe. Please try again.'),
        ),
      );
    }
  }
}
