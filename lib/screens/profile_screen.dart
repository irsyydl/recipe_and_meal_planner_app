import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recipe_and_meal_planner_app/services/auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();
  final _displayNameController = TextEditingController();
  Stream<User?> get userChanges => _auth.userChanges();
  final _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().userChanges,
      builder: (context, snapshot) {
        User? user = snapshot.data;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(user?.uid)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else {
                        if (snapshot.hasError)
                          return Text('Error: ${snapshot.error}');
                        else {
                          String profilePictureUrl =
                              snapshot.data?['profilePictureUrl'] ?? '';
                          return CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(profilePictureUrl),
                          );
                        }
                      }
                    },
                  ),
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(user?.uid)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else {
                        if (snapshot.hasError)
                          return Text('Error: ${snapshot.error}');
                        else {
                          String username = snapshot.data?['username'] ?? 'N/A';
                          return Text('Username: $username');
                        }
                      }
                    },
                  ),
                  Text('Email: ${user?.email ?? 'N/A'}'),
                  ElevatedButton(
                    onPressed: _changeDisplayName,
                    child: const Text('Change Username'),
                  ),
                  ElevatedButton(
                    onPressed: _updateProfilePicture,
                    child: const Text('Change Profile Picture'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await _logout(context);
                    },
                    child: const Text('Logout'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _changeDisplayName() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Username'),
          content: TextField(
            controller: _displayNameController,
            decoration: const InputDecoration(
              labelText: 'New Username',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Update'),
              onPressed: () async {
                await _authService
                    .updateDisplayName(_displayNameController.text);
                User? user = _auth.currentUser;
                if (user != null) {
                  await user.updateDisplayName(_displayNameController.text);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: const Text('Username updated'),
                  ),
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateProfilePicture() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);

      try {
        // Upload the image to Firebase Storage with the user's ID as the filename
        final user = FirebaseAuth.instance.currentUser;
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_pictures/${user?.uid}');
        final uploadTask = storageRef.putFile(imageFile);

        // Wait for the upload to complete
        final taskSnapshot = await uploadTask.whenComplete(() {});
        final profilePictureUrl = await taskSnapshot.ref.getDownloadURL();

        // Update the profilePictureUrl field in the user's document in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .update({
          'profilePictureUrl': profilePictureUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: const Text('Profile picture updated'),
          ),
        );
      } catch (e) {
        print('Error updating profile picture: $e');
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    await _authService.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }
}
