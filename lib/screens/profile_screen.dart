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
      stream: userChanges,
      builder: (context, snapshot) {
        User? user = snapshot.data;
        return Scaffold(
          body: Column(children: [
            AppBar(
              title: Text("Profile"),
              backgroundColor: Colors.transparent,
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  children: [
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(user?.uid)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else {
                          if (snapshot.hasError)
                            return Text('Error: ${snapshot.error}');
                          else {
                            String profilePictureUrl =
                                snapshot.data?['profilePictureUrl'] ?? '';
                            return CircleAvatar(
                              radius: 60,
                              backgroundImage: NetworkImage(profilePictureUrl),
                              backgroundColor: Colors.white,
                            );
                          }
                        }
                      },
                    ),
                    SizedBox(height: 15),
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(user?.uid)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else {
                          if (snapshot.hasError)
                            return Text('Error: ${snapshot.error}');
                          else {
                            String username =
                                snapshot.data?['username'] ?? 'N/A';
                            String userEmail = user?.email ?? 'N/A';
                            return Column(
                              children: [
                                Text(
                                  "Username: $username",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Email: $userEmail",
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            );
                          }
                        }
                      },
                    ),
                    SizedBox(height: 20),
                    _buildProfileButton(context, "Change Username", Icons.edit),
                    _buildProfileButton(
                        context, "Change Profile Picture", Icons.camera_alt),
                    _buildProfileButton(
                        context, "Logout", Icons.logout_outlined),
                  ],
                ),
              ),
            ),
          ]),
        );
      },
    );
  }

  Widget _buildProfileButton(
      BuildContext context, String label, IconData icon) {
    return InkWell(
      onTap: () {
        if (label == "Change Username") {
          _changeDisplayName();
        } else if (label == "Change Profile Picture") {
          _updateProfilePicture();
        } else if (label == "Logout") {
          _logout(context);
        }
      },
      child: Padding(
        padding:
            const EdgeInsets.only(left: 50), // Mengatur jarak dari tepi kiri
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: Colors.transparent),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                icon,
              ),
              SizedBox(width: 10),
              Text(
                label,
              ),
            ],
          ),
        ),
      ),
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
