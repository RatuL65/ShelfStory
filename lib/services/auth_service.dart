import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Resolve username to email (for login with username)
  Future<String?> resolveUsernameToEmail(String usernameOrEmail) async {
    // If it contains @, it's already an email
    if (usernameOrEmail.contains('@')) {
      return usernameOrEmail;
    }

    // Otherwise, look up username in Firestore
    try {
      final normalized = usernameOrEmail.trim().toLowerCase();
      final usernameDoc = await FirebaseFirestore.instance
          .collection('usernames')
          .doc(normalized)
          .get();

      if (!usernameDoc.exists) {
        return null; // Username not found
      }

      final uid = usernameDoc.data()?['uid'];
      if (uid == null) return null;

      // Get email from users collection
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      return userDoc.data()?['email'];
    } catch (e) {
      print('Error resolving username: $e');
      return null;
    }
  }

  // Sign up with email and password
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw e;
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  // Sign in with email and password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw e;
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw e;
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.delete();
      }
    } on FirebaseAuthException catch (e) {
      throw e;
    } catch (e) {
      throw Exception('Account deletion failed: $e');
    }
  }
}
