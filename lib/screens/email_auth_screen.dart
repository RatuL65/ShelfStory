import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../utils/constants.dart';
import '../providers/user_provider.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class EmailAuthScreen extends StatefulWidget {
  const EmailAuthScreen({super.key});

  @override
  State<EmailAuthScreen> createState() => _EmailAuthScreenState();
}

class _EmailAuthScreenState extends State<EmailAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      User? user;
      if (_isLogin) {
        user = await _authService.signInWithEmail(
          _emailController.text,
          _passwordController.text,
        );
      } else {
        user = await _authService.signUpWithEmail(
          _emailController.text,
          _passwordController.text,
        );
      }

      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-null',
          message: 'Authentication failed. Please try again.',
        );
      }

      // Load user data (same pattern as other auth flows)
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.loadUser();

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Authentication failed.');
    } catch (e) {
      _showError('An error occurred: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.backgroundCream,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.auto_stories,
                    size: 80,
                    color: AppColors.accentGold,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isLogin
                        ? 'Log in to ShelfStory'
                        : 'Create a ShelfStory account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkText : AppColors.darkBrown,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: AppColors.accentGold,
                      foregroundColor: Colors.black87,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.black87),
                          )
                        : Text(
                            _isLogin ? 'Log In' : 'Sign Up',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            setState(() => _isLogin = !_isLogin);
                          },
                    child: Text(
                      _isLogin
                          ? "Don't have an account? Sign up"
                          : 'Already have an account? Log in',
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 12),
                  const Text(
                    'More sign-in options coming soon',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
