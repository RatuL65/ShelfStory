import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import 'home_screen.dart';
import '../providers/user_provider.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  
  String _verificationId = '';
  bool _codeSent = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  // Send OTP to phone number
  Future<void> _sendOTP() async {
    if (_phoneController.text.trim().isEmpty) {
      _showMessage('Please enter phone number');
      return;
    }

    setState(() => _isLoading = true);
    
    String phoneNumber = _phoneController.text.trim();
    
    // Add Bangladesh country code if not present
    if (!phoneNumber.startsWith('+')) {
      phoneNumber = '+880$phoneNumber';
    }

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        
        // Auto-verification (Android only)
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          if (mounted) {
            _showMessage('Phone verified automatically!');
            _navigateToHome();
          }
        },
        
        // Verification failed
        verificationFailed: (FirebaseAuthException e) {
          setState(() => _isLoading = false);
          _showMessage('Error: ${e.message}');
        },
        
        // OTP sent successfully
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _codeSent = true;
            _isLoading = false;
          });
          _showMessage('OTP sent to your phone!');
        },
        
        // Auto-retrieval timeout
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showMessage('Error: $e');
    }
  }

  // Verify OTP entered by user
  Future<void> _verifyOTP() async {
    if (_otpController.text.trim().isEmpty) {
      _showMessage('Please enter OTP');
      return;
    }

    setState(() => _isLoading = true);
    
    String otp = _otpController.text.trim();
    
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: otp,
      );
      
      await _auth.signInWithCredential(credential);
      
      if (mounted) {
        _showMessage('Phone verified successfully!');
        _navigateToHome();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showMessage('Invalid OTP. Please try again.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.darkBrown,
      ),
    );
  }

  void _navigateToHome() async {
    // Load user data
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.loadUser();
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.backgroundCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppColors.darkText : AppColors.darkBrown,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
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
                  size: 80,
                  color: AppColors.accentGold,
                ),
                const SizedBox(height: 24),
                
                // Title
                Text(
                  'Welcome to ShelfStory',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkText : AppColors.darkBrown,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                
                Text(
                  'Sign in with your phone number',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.primaryBrown,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                
                // Phone number input
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(
                    color: isDark ? AppColors.darkText : AppColors.darkBrown,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText: '1XXXXXXXXX',
                    prefixText: '+880 ',
                    prefixStyle: TextStyle(
                      color: isDark ? AppColors.darkText : AppColors.darkBrown,
                    ),
                    filled: true,
                    fillColor: isDark ? AppColors.darkSurface : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? AppColors.darkSurface : AppColors.primaryBrown.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.accentGold,
                        width: 2,
                      ),
                    ),
                  ),
                  enabled: !_codeSent && !_isLoading,
                ),
                
                const SizedBox(height: 16),
                
                // OTP input (visible after code sent)
                if (_codeSent) ...[
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    style: TextStyle(
                      color: isDark ? AppColors.darkText : AppColors.darkBrown,
                      fontSize: 24,
                      letterSpacing: 8,
                    ),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      labelText: 'Enter OTP',
                      hintText: '000000',
                      filled: true,
                      fillColor: isDark ? AppColors.darkSurface : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.darkSurface : AppColors.primaryBrown.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.accentGold,
                          width: 2,
                        ),
                      ),
                    ),
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Send OTP or Verify OTP button
                ElevatedButton(
                  onPressed: _isLoading ? null : (_codeSent ? _verifyOTP : _sendOTP),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _codeSent ? 'Verify OTP' : 'Send OTP',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                
                // Change phone number option
                if (_codeSent) ...[
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _isLoading ? null : () {
                      setState(() {
                        _codeSent = false;
                        _otpController.clear();
                      });
                    },
                    child: Text(
                      'Change Phone Number',
                      style: TextStyle(
                        color: isDark ? AppColors.darkPrimary : AppColors.primaryBrown,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
