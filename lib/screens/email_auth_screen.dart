import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../utils/constants.dart';
import '../providers/user_provider.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'account_setup_screen.dart';

class EmailAuthScreen extends StatefulWidget {
  const EmailAuthScreen({super.key});

  @override
  State<EmailAuthScreen> createState() => _EmailAuthScreenState();
}

class _EmailAuthScreenState extends State<EmailAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailOrUsernameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  bool _checkingUsername = false;
  String? _usernameError;

  bool _showPassword = false;
  bool _showConfirm = false;

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailOrUsernameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<bool> _checkUsernameAvailability(String username) async {
    if (username.trim().isEmpty || username.length < 3) return false;
    
    try {
      final normalized = username.trim().toLowerCase();
      final doc = await FirebaseFirestore.instance
          .collection('usernames')
          .doc(normalized)
          .get();
      return !doc.exists;
    } catch (e) {
      return false;
    }
  }

  void _onUsernameChanged(String value) async {
    final normalized = value.trim().toLowerCase();
    
    // Basic validation
    if (normalized.isEmpty) {
      setState(() {
        _usernameError = null;
        _checkingUsername = false;
      });
      return;
    }

    if (normalized.length < 3) {
      setState(() {
        _usernameError = 'At least 3 characters';
        _checkingUsername = false;
      });
      return;
    }

    final regex = RegExp(r'^[a-z0-9_\-]+$');
    if (!regex.hasMatch(normalized)) {
      setState(() {
        _usernameError = 'Only lowercase, numbers, _ and -';
        _checkingUsername = false;
      });
      return;
    }

    // Check availability
    setState(() => _checkingUsername = true);
    final available = await _checkUsernameAvailability(normalized);
    if (mounted) {
      setState(() {
        _checkingUsername = false;
        _usernameError = available ? null : 'Username taken';
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Extra username check for sign-up
    if (!_isLogin) {
      if (_usernameError != null || _checkingUsername) {
        _showError('Please fix username issues before continuing');
        return;
      }
      
      final usernameAvailable = await _checkUsernameAvailability(
        _usernameController.text
      );
      if (!usernameAvailable) {
        _showError('Username is already taken');
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      User? user;
      if (_isLogin) {
        // Login: resolve username to email if needed
        final input = _emailOrUsernameController.text.trim();
        final email = await _authService.resolveUsernameToEmail(input);
        
        if (email == null) {
          throw FirebaseAuthException(
            code: 'user-not-found',
            message: 'No account found with this username or email.',
          );
        }

        user = await _authService.signInWithEmail(
          email,
          _passwordController.text,
        );
      } else {
        // Sign up with email
        user = await _authService.signUpWithEmail(
          _emailOrUsernameController.text.trim(),
          _passwordController.text,
        );

        if (user != null) {
          // Immediately save username to Firestore
          final username = _usernameController.text.trim().toLowerCase();
          final uid = user.uid;
          
          await FirebaseFirestore.instance.runTransaction((txn) async {
            final usernameRef = FirebaseFirestore.instance
                .collection('usernames')
                .doc(username);
            final userRef = FirebaseFirestore.instance
                .collection('users')
                .doc(uid);

            txn.set(usernameRef, {'uid': uid});
            txn.set(userRef, {
              'email': user!.email,
              'displayName': user.displayName ?? 'Reader',
              'username': username,
              'bio': '',
              'photoUrl': '',
              'dob': null,
              'favoriteGenres': [],
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            });
          });
        }
      }

      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-null',
          message: 'Authentication failed. Please try again.',
        );
      }

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.loadUser();

      if (!mounted) return;

      // Navigate based on login vs sign-up
      if (_isLogin) {
        // Login -> go directly to HomeScreen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        // Sign-up -> go to AccountSetupScreen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AccountSetupScreen()),
        );
      }
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
                    controller: _emailOrUsernameController,
                    keyboardType: _isLogin 
                        ? TextInputType.text 
                        : TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: _isLogin ? 'Email or Username' : 'Email',
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return _isLogin 
                            ? 'Please enter your email or username'
                            : 'Please enter your email';
                      }
                      if (!_isLogin && !value.contains('@')) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  if (!_isLogin) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        helperText: 'Lowercase, numbers, _ and - only',
                        border: const OutlineInputBorder(),
                        errorText: _usernameError,
                        suffixIcon: _checkingUsername
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : (_usernameError == null &&
                                    _usernameController.text.length >= 3)
                                ? const Icon(Icons.check_circle,
                                    color: Colors.green)
                                : null,
                      ),
                      onChanged: _onUsernameChanged,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Username is required';
                        }
                        final v = value.trim().toLowerCase();
                        final regex = RegExp(r'^[a-z0-9_\-]+$');
                        if (!regex.hasMatch(v)) {
                          return 'Only lowercase, numbers, _ and -';
                        }
                        if (v.length < 3) {
                          return 'At least 3 characters';
                        }
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_showPassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() => _showPassword = !_showPassword);
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  if (!_isLogin) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: !_showConfirm,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showConfirm
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() => _showConfirm = !_showConfirm);
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please retype your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ],
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
