import 'package:firebase_auth/firebase_auth.dart';

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
      await updateDisplayName(displayName);
      return result.user;
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

  Future<void> updateDisplayName(String displayName) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await user.updateDisplayName(displayName);
      await user.reload();
    }
  }
}
