import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recipe_and_meal_planner_app/models/recipe.dart';
import 'package:recipe_and_meal_planner_app/models/comment.dart';

class RecipeDetailsScreen extends StatefulWidget {
  final Recipe recipe;
  final String recipeId;

  RecipeDetailsScreen({required this.recipe, required this.recipeId});

  @override
  _RecipeDetailsScreenState createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  final _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                widget.recipe.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              const Text('Description:',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(widget.recipe.description),
              const Text('Ingredients:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              for (var ingredient in widget.recipe.ingredients)
                Text(ingredient),
              const Text('Instructions:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              for (var instruction in widget.recipe.instructions)
                Text(instruction),
              TextField(
                controller: _commentController,
                decoration: const InputDecoration(labelText: 'Add a comment'),
              ),
              ElevatedButton(
                onPressed: _submitComment,
                child: const Text('Submit Comment'),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('recipes')
                    .doc(widget.recipeId)
                    .collection('comments')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  return Column(
                    children: snapshot.data!.docs.map((doc) {
                      final comment = Comment.fromFirestore(doc);

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(comment.userId)
                            .get(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          }

                          final userDoc = snapshot.data;

                          if (userDoc == null || !userDoc.exists) {
                            return const Text('User not found');
                          }

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(userDoc['profilePictureUrl']),
                            ),
                            title: Text(userDoc['username']),
                            subtitle: Text(comment.text),
                          );
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitComment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final comment = Comment(
        userId: user.uid,
        text: _commentController.text,
        timestamp: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('recipes')
          .doc(widget.recipeId)
          .collection('comments')
          .add(comment.toJson());

      _commentController.clear();
    }
  }
}
