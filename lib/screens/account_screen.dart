import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../providers/user_provider.dart';
import '../utils/constants.dart';
import 'email_auth_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _photoController = TextEditingController();
  DateTime? _dob;
  bool _isSaving = false;
  bool _isUploadingPhoto = false;

  File? _localImageFile;
  final _picker = ImagePicker();

  // Genre selection
  final Set<String> _selectedGenres = {};

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
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final appUser = userProvider.user;

    _usernameController.text = appUser?.username ?? '';
    _displayNameController.text = appUser?.name ?? '';
    _bioController.text = appUser?.bio ?? '';
    _photoController.text = appUser?.photoUrl ?? '';
    _dob = appUser?.dob;
    _selectedGenres.addAll(appUser?.favoriteGenres ?? []);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _displayNameController.dispose();
    _bioController.dispose();
    _photoController.dispose();
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
        _photoController.text = url;
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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      await userProvider.updateProfile(
        username: _usernameController.text,
        displayName: _displayNameController.text,
        bio: _bioController.text,
        dob: _dob,
        photoUrl: _photoController.text,
        favoriteGenres: _selectedGenres.toList(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      String message = 'Failed to update profile';
      if (e.toString().contains('username-taken')) {
        message = 'Username is already taken';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _logout() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    await FirebaseAuth.instance.signOut();
    userProvider.clear();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const EmailAuthScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appUser = Provider.of<UserProvider>(context).user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final email = FirebaseAuth.instance.currentUser?.email;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Account'),
      ),
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.backgroundCream,
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
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              )
                            : (_photoController.text.isNotEmpty)
                                ? Image.network(
                                    _photoController.text,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Icon(
                                      Icons.person,
                                      size: 60,
                                      color: AppColors.accentGold,
                                    ),
                                  )
                                : Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: AppColors.accentGold.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.person,
                                      size: 60,
                                      color: AppColors.accentGold,
                                    ),
                                  ),
                      ),
                      if (_isUploadingPhoto)
                        Container(
                          width: 100,
                          height: 100,
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
                            radius: 18,
                            backgroundColor: AppColors.accentGold,
                            child: Icon(
                              Icons.camera_alt,
                              size: 18,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkText : AppColors.darkBrown,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (email != null) ...[
                  Text(
                    'Email',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.primaryBrown,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkText
                          : AppColors.darkBrown,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    helperText: 'Lowercase, numbers, _ and - only',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: _displayNameController,
                  decoration: const InputDecoration(
                    labelText: 'Display name',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value != null && value.length > 40) {
                      return 'Too long';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bioController,
                  decoration: const InputDecoration(
                    labelText: 'Bio',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value != null && value.length > 200) {
                      return 'Bio too long';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // DOB picker
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _dob ?? DateTime(2000, 1, 1),
                      firstDate: DateTime(1900, 1, 1),
                      lastDate: DateTime(DateTime.now().year - 10, 12, 31),
                    );
                    if (picked != null) setState(() => _dob = picked);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date of Birth',
                      border: OutlineInputBorder(),
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
                // Favorite Genres
                Text(
                  'Favorite Genres',
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
                const SizedBox(height: 24),
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
                          'Save profile',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'Account',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.primaryBrown,
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Log out'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
