import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GoogleSignInService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // REPLACE THIS WITH YOUR ACTUAL WEB CLIENT ID
    serverClientId: '188930821368-3i7lnkq5fi4q30uo5vct7ageit4g1r5k.apps.googleusercontent.com',
  );
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  Future<User?> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return null;
      }
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      final userCredential = await _auth.signInWithCredential(credential);
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
