import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../providers/user_provider.dart';
import '../utils/constants.dart';
import 'home_screen.dart';

class AccountSetupScreen extends StatefulWidget {
  const AccountSetupScreen({super.key});

  @override
  State<AccountSetupScreen> createState() => _AccountSetupScreenState();
}

class _AccountSetupScreenState extends State<AccountSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _readingGoalController = TextEditingController();

  DateTime? _dob;
  String? _photoUrl;
  File? _localImageFile;
  final _picker = ImagePicker();
  final Set<String> _selectedGenres = {};

  bool _isSaving = false;
  bool _isUploadingPhoto = false;

  // Genre options
  final List<String> _availableGenres = [
    'Fiction',
    'Mystery',
    'Romance',
    'Sci-Fi',
    'Fantasy',
    'Non-Fiction',
    'Biography',
    'Self-Help',
    'Horror',
    'Thriller',
    'Historical',
    'Poetry',
    'Drama',
    'Adventure',
    'Young Adult',
    'Children',
    'Graphic Novel',
    'Philosophy',
    'Science',
    'Technology',
  ];

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    _readingGoalController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      
      if (picked == null) return;

      setState(() {
        _localImageFile = File(picked.path);
        _isUploadingPhoto = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      // Upload to Firebase Storage
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('${user.uid}.jpg');

      await ref.putFile(_localImageFile!);
      final url = await ref.getDownloadURL();

      setState(() {
        _photoUrl = url;
        _isUploadingPhoto = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo uploaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isUploadingPhoto = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload photo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedGenres.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one favorite genre.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      // Update profile with all fields including genres
      await userProvider.updateProfile(
        username: userProvider.user?.username ?? '',
        displayName: _displayNameController.text.trim(),
        bio: _bioController.text.trim(),
        dob: _dob,
        photoUrl: _photoUrl ?? '',
        favoriteGenres: _selectedGenres.toList(),
      );

      // Set reading goal if provided
      if (_readingGoalController.text.isNotEmpty) {
        final goal = int.tryParse(_readingGoalController.text) ?? 0;
        if (goal > 0) {
          await userProvider.setReadingGoal(goal, DateTime.now().year);
        }
      }

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile completed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _skipForNow() async {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.backgroundCream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Picture with Camera Icon
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipOval(
                        child: _localImageFile != null
                            ? Image.file(
                                _localImageFile!,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              )
                            : (_photoUrl != null && _photoUrl!.isNotEmpty)
                                ? Image.network(
                                    _photoUrl!,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Icon(
                                      Icons.person,
                                      size: 80,
                                      color: AppColors.accentGold,
                                    ),
                                  )
                                : Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: AppColors.accentGold.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.person,
                                      size: 80,
                                      color: AppColors.accentGold,
                                    ),
                                  ),
                      ),
                      if (_isUploadingPhoto)
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: _isUploadingPhoto ? null : _pickAndUploadImage,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.accentGold,
                            child: Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Complete Your Profile',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkText : AppColors.darkBrown,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Help us personalize your reading experience',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.primaryBrown,
                  ),
                ),
                const SizedBox(height: 24),

                // 1. Full Name
                TextFormField(
                  controller: _displayNameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Full name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 2. Date of Birth
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2000, 1, 1),
                      firstDate: DateTime(1900, 1, 1),
                      lastDate: DateTime(DateTime.now().year - 10, 12, 31),
                    );
                    if (picked != null) setState(() => _dob = picked);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date of Birth (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.cake_outlined),
                    ),
                    child: Text(
                      _dob == null
                          ? 'Tap to select'
                          : '${_dob!.year}-${_dob!.month.toString().padLeft(2, '0')}-${_dob!.day.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: (_dob == null)
                            ? Colors.grey
                            : (isDark
                                ? AppColors.cream
                                : AppColors.darkBrown),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Bio
                TextFormField(
                  controller: _bioController,
                  maxLines: 3,
                  maxLength: 200,
                  decoration: const InputDecoration(
                    labelText: 'Short Bio (Optional)',
                    hintText: 'Tell us about yourself...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.edit_outlined),
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Favorite Genres (Multi-select chips)
                Text(
                  'Favorite Genres *',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkText : AppColors.darkBrown,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableGenres.map((genre) {
                    final isSelected = _selectedGenres.contains(genre);
                    return FilterChip(
                      label: Text(genre),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedGenres.add(genre);
                          } else {
                            _selectedGenres.remove(genre);
                          }
                        });
                      },
                      selectedColor: AppColors.accentGold.withOpacity(0.3),
                      checkmarkColor: AppColors.darkBrown,
                      backgroundColor: isDark
                          ? AppColors.darkBackground
                          : AppColors.cream,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppColors.darkBrown
                            : (isDark
                                ? AppColors.darkText
                                : AppColors.primaryBrown),
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // 5. Annual Reading Goal
                TextFormField(
                  controller: _readingGoalController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Annual Reading Goal (Optional)',
                    hintText: 'e.g., 24 books',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.track_changes_outlined),
                    suffixText: 'books',
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final number = int.tryParse(value);
                      if (number == null || number < 1) {
                        return 'Enter a valid number';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Save Button
                ElevatedButton(
                  onPressed: (_isSaving || _isUploadingPhoto) ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: AppColors.accentGold,
                    foregroundColor: Colors.black87,
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.black87),
                        )
                      : const Text(
                          'Complete Profile',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 12),

                // Skip Button
                TextButton(
                  onPressed: (_isSaving || _isUploadingPhoto) ? null : _skipForNow,
                  child: Text(
                    'Skip for now',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.primaryBrown,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
