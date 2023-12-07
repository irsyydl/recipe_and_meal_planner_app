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
  List<TextEditingController> ingredientControllers = [TextEditingController()];
  List<TextEditingController> instructionControllers = [
    TextEditingController()
  ];
  File? _image;

  void addIngredientField() {
    setState(() {
      ingredientControllers.add(TextEditingController());
    });
  }

  void addInstructionField() {
    setState(() {
      instructionControllers.add(TextEditingController());
    });
  }

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
              const SizedBox(height: 10),
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2.0),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2.0),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              for (int i = 0; i < ingredientControllers.length; i++)
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: ingredientControllers[i],
                            decoration: const InputDecoration(
                              labelText: 'Ingredient',
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.blue, width: 2.0),
                              ),
                            ),
                          ),
                        ),
                        if (i != 0)
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                ingredientControllers.removeAt(i);
                              });
                            },
                          ),
                      ],
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ElevatedButton(
                onPressed: addIngredientField,
                child: Text('Add new ingredient'),
              ),
              SizedBox(height: 10),
              for (int i = 0; i < instructionControllers.length; i++)
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: instructionControllers[i],
                            decoration: const InputDecoration(
                              labelText: 'Instruction',
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.blue, width: 2.0),
                              ),
                            ),
                          ),
                        ),
                        if (i != 0)
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                instructionControllers.removeAt(i);
                              });
                            },
                          ),
                      ],
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ElevatedButton(
                onPressed: addInstructionField,
                child: Text('Add new instruction'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  String title = titleController.text;
                  String description = descriptionController.text;
                  List<String> ingredients = ingredientControllers
                      .map((controller) => controller.text)
                      .toList();
                  List<String> instructions = instructionControllers
                      .map((controller) => controller.text)
                      .toList();

                  if (title.isEmpty ||
                      description.isEmpty ||
                      ingredients.any((ingredient) => ingredient.isEmpty) ||
                      instructions.any((instruction) => instruction.isEmpty)) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            'Please fill all the fields before uploading the recipe.')));
                    return;
                  }

                  await _uploadRecipe(
                    title,
                    description,
                    ingredients,
                    instructions,
                  );
                },
                child: const Text('Upload Recipe'),
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
