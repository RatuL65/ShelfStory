import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';
import '../providers/user_provider.dart';
import 'setup_screen.dart';
import 'home_screen.dart';

class GoogleSignInScreen extends StatefulWidget {
  const GoogleSignInScreen({super.key});

  @override
  State<GoogleSignInScreen> createState() => _GoogleSignInScreenState();
}

class _GoogleSignInScreenState extends State<GoogleSignInScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: '697134409500-k9obg64qbjla08o25up3ffej2s48l0bv.apps.googleusercontent.com',
  );
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        setState(() => _isLoading = false);
        return;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = 
          await _auth.signInWithCredential(credential);

      // Check if this is a new user
      final User? user = userCredential.user;
      if (user != null) {
        // Check if user document exists in Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          // New user - create Firestore document
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'email': user.email,
            'name': user.displayName,
            'photoUrl': user.photoURL,
            'verificationLevel': 'basic', // Tier 1
            'phoneVerified': false,
            'nidVerified': false,
            'createdAt': FieldValue.serverTimestamp(),
          });

          // Navigate to setup screen for additional info
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const SetupScreen()),
            );
          }
        } else {
          // Existing user - load data and go to home
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          await userProvider.loadUser();

          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      _showError('Authentication failed: ${e.message}');
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('An error occurred: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.backgroundCream,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App Logo
                Icon(
                  Icons.auto_stories,
                  size: 100,
                  color: AppColors.accentGold,
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  'Welcome to ShelfStory',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkText : AppColors.darkBrown,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'Your Personal Book Tracking Companion',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.primaryBrown,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Features list
                _buildFeatureItem(
                  Icons.library_books,
                  'Track your reading journey',
                  isDark,
                ),
                const SizedBox(height: 16),
                _buildFeatureItem(
                  Icons.people,
                  'Connect with fellow readers',
                  isDark,
                ),
                const SizedBox(height: 16),
                _buildFeatureItem(
                  Icons.shopping_bag,
                  'Buy, sell & lend books',
                  isDark,
                ),
                const SizedBox(height: 48),

                // Google Sign In Button
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _signInWithGoogle,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black87,
                          ),
                        )
                      : const Icon(
                          Icons.login,
                          size: 24,
                          color: Colors.black87,
                        ),
                  label: Text(
                    _isLoading ? 'Signing in...' : 'Continue with Google',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Privacy text
                Text(
                  'By continuing, you agree to our Terms of Service\nand Privacy Policy',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.accentGold,
          size: 24,
        ),
        const SizedBox(width: 16),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: isDark ? AppColors.darkText : AppColors.darkBrown,
          ),
        ),
      ],
    );
  }
}
