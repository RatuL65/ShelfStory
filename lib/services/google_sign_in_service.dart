import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GoogleSignInService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  Future<User?> signInWithGoogle() async {
    try {
      // Sign out first to ensure clean state
      await _googleSignIn.signOut();
      
      // Trigger sign-in
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print('User cancelled sign-in');
        return null;
      }
      
      print('Google user: ${googleUser.email}');
      
      // Get auth details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      
      print('Firebase user: ${userCredential.user?.email}');
      return userCredential.user;
      
    } catch (e) {
      print('Sign-in error: $e');
      return null;
    }
  }
  
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
  
  bool get isSignedIn => _auth.currentUser != null;
  User? get currentUser => _auth.currentUser;
  
  Future<GoogleSignInAccount?> getGoogleAccount() async {
    return await _googleSignIn.signInSilently();
  }
}
