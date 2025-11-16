import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/user_provider.dart';
import '../utils/constants.dart';
import 'home_screen.dart';


class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});


  @override
  State<SetupScreen> createState() => _SetupScreenState();
}


class _SetupScreenState extends State<SetupScreen> {
  final _nameController = TextEditingController();
  bool _isValid = false;


  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }


  Future<void> _saveName() async {
    if (_nameController.text.trim().isNotEmpty) {
      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', _nameController.text.trim());


      // Update UserProvider using the proper method
      if (!mounted) return;
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.updateUserName(_nameController.text.trim());


      if (!mounted) return;


      // Navigate to home
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBrown,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.auto_stories,
                size: 80,
                color: AppColors.accentGold,
              ),
              const SizedBox(height: 32),
              Text(
                'Welcome to ShelfStory',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.cream,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Your personal vintage library awaits',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.cream.withOpacity(0.8),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "What's your name?",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkBrown,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _nameController,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.darkBrown,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter your name',
                        hintStyle: TextStyle(
                          color: AppColors.primaryBrown.withOpacity(0.5),
                        ),
                        filled: true,
                        fillColor: AppColors.backgroundCream,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _isValid = value.trim().isNotEmpty;
                        });
                      },
                      onSubmitted: (_) => _isValid ? _saveName() : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isValid ? _saveName : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isValid
                            ? AppColors.accentGold
                            : Colors.grey,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Start Reading',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
