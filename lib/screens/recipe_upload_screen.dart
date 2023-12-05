import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recipe_and_meal_planner_app/services/recipe_service.dart';

class RecipeUploadScreen extends StatefulWidget {
  const RecipeUploadScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
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
        title: const Text('Upload Recipe'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => _showPickImageDialog(context),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _image != null
                      ? Image.file(_image!, fit: BoxFit.cover)
                      : Icon(Icons.add_a_photo, color: Colors.grey[800]),
                ),
              ),
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextFormField(
                controller: ingredientsController,
                decoration: const InputDecoration(labelText: 'Ingredients'),
              ),
              TextFormField(
                controller: instructionsController,
                decoration: const InputDecoration(labelText: 'Instructions'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  String title = titleController.text;
                  String description = descriptionController.text;
                  List<String> ingredients = ingredientsController.text.split(',');
                  List<String> instructions = instructionsController.text.split(',');

                  if (title.isEmpty || description.isEmpty || ingredientsController.text.isEmpty || instructionsController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all the fields before uploading the recipe.'))
                    );
                    return;
                  }

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

  void _showPickImageDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return Container(
          height: 150.0,
          color: Colors.transparent,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
              ),
            ),
            child: Center(
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Pick from gallery'),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text('Take a photo'),
                    onTap: () {
                      Navigator.pop(context);
                      _takePhoto();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future _takePhoto() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recipe Uploaded!.'),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Error uploading recipe: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error uploading recipe. Please try again.'),
        ),
      );
    }
  }
}
