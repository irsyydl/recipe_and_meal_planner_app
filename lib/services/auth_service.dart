import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get userChanges => _auth.userChanges();

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  Future<User?> registerWithEmailAndPassword(
      String email, String password, String displayName) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        final defaultProfilePictureRef = FirebaseStorage.instance.ref().child('profile_pictures/default_pfp.png');
        final defaultProfilePictureUrl = await defaultProfilePictureRef.getDownloadURL();

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'username': displayName,
          'profilePictureUrl': defaultProfilePictureUrl,
        });

        await updateDisplayName(displayName);
      }

      return user;
    } catch (e) {
      print('Error registering: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<String?> getCurrentUserId() async {
    try {
      User? user = _auth.currentUser;
      return user?.uid;
    } catch (e) {
      print('Error getting current user ID: $e');
      return null;
    }
  }

  Future<void> updateDisplayName(String newUsername) async {
    final user = _auth.currentUser;

    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'username': newUsername,
      });
    }
  }
}
