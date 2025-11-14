import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class GoogleSignInService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  Future<User?> signInWithGoogle() async {
    try {
      debugPrint('═══════════════════════════════════════');
      debugPrint('🟦 STEP 1: Starting Google Sign-In Process');
      debugPrint('═══════════════════════════════════════');
      
      // Clear any cached account
      debugPrint('🟦 STEP 2: Signing out of previous session...');
      await _googleSignIn.signOut();
      debugPrint('✅ Signed out successfully');
      
      debugPrint('🟦 STEP 3: Opening Google account selector...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        debugPrint('⚠️ RESULT: User cancelled sign-in (pressed back)');
        debugPrint('═══════════════════════════════════════');
        return null;
      }
      
      debugPrint('✅ STEP 3 SUCCESS: User selected account');
      debugPrint('   📧 Email: ${googleUser.email}');
      debugPrint('   👤 Name: ${googleUser.displayName}');
      debugPrint('   🆔 ID: ${googleUser.id}');
      
      debugPrint('🟦 STEP 4: Requesting authentication tokens...');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      debugPrint('🟦 STEP 5: Checking tokens...');
      debugPrint('   Access Token: ${googleAuth.accessToken != null ? "✅ Present (${googleAuth.accessToken!.substring(0, 20)}...)" : "❌ MISSING"}');
      debugPrint('   ID Token: ${googleAuth.idToken != null ? "✅ Present (${googleAuth.idToken!.substring(0, 20)}...)" : "❌ MISSING"}');
      
      if (googleAuth.accessToken == null) {
        debugPrint('❌ FAILED: Access token is null');
        debugPrint('   ⚠️ This means OAuth client is not configured properly');
        debugPrint('   💡 Solution: Check Firebase Console → Authentication → Google');
        debugPrint('═══════════════════════════════════════');
        return null;
      }
      
      if (googleAuth.idToken == null) {
        debugPrint('❌ FAILED: ID token is null');
        debugPrint('   ⚠️ This means SHA-1 fingerprint is missing or wrong');
        debugPrint('   💡 Solution: Add debug keystore SHA-1 to Firebase Console');
        debugPrint('═══════════════════════════════════════');
        return null;
      }
      
      debugPrint('✅ STEP 5 SUCCESS: Both tokens received');
      
      debugPrint('🟦 STEP 6: Creating Firebase credential...');
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      debugPrint('✅ STEP 6 SUCCESS: Credential created');
      
      debugPrint('🟦 STEP 7: Signing in to Firebase...');
      final userCredential = await _auth.signInWithCredential(credential);
      
      debugPrint('✅✅✅ COMPLETE SUCCESS! ✅✅✅');
      debugPrint('   Firebase User ID: ${userCredential.user?.uid}');
      debugPrint('   Email: ${userCredential.user?.email}');
      debugPrint('   Display Name: ${userCredential.user?.displayName}');
      debugPrint('═══════════════════════════════════════');
      
      return userCredential.user;
      
    } on FirebaseAuthException catch (e) {
      debugPrint('❌❌❌ FIREBASE AUTH ERROR ❌❌❌');
      debugPrint('   Error Code: ${e.code}');
      debugPrint('   Message: ${e.message}');
      debugPrint('   Details: ${e.stackTrace}');
      debugPrint('═══════════════════════════════════════');
      return null;
      
    } catch (e, stackTrace) {
      debugPrint('❌❌❌ UNEXPECTED ERROR ❌❌❌');
      debugPrint('   Error: $e');
      debugPrint('   Type: ${e.runtimeType}');
      debugPrint('   Stack: $stackTrace');
      debugPrint('═══════════════════════════════════════');
      return null;
    }
  }
  
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    debugPrint('✅ Signed out from Google and Firebase');
  }
  
  bool get isSignedIn => _auth.currentUser != null;
  User? get currentUser => _auth.currentUser;
  
  Future<GoogleSignInAccount?> getGoogleAccount() async {
    return await _googleSignIn.signInSilently();
  }
}
