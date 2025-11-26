import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_profile.dart';

class UserProvider with ChangeNotifier {
  UserProfile? _user;
  final Box _userBox = Hive.box('user');

  UserProfile? get user => _user;

  // Carefully merge Firestore data with local data
UserProfile _mergeFirestoreData(Map<String, dynamic> data, UserProfile local) {
  return local.copyWith(
    name: data['displayName']?.isNotEmpty == true ? data['displayName'] : local.name,
    username: data['username']?.isNotEmpty == true ? data['username'] : local.username,
    bio: data['bio']?.isNotEmpty == true ? data['bio'] : local.bio,
    photoUrl: data['photoUrl']?.isNotEmpty == true ? data['photoUrl'] : local.photoUrl,
    dob: (data['dob'] != null && data['dob'].isNotEmpty)
        ? DateTime.tryParse(data['dob']) ?? local.dob
        : local.dob,
    favoriteGenres: data['favoriteGenres'] != null
        ? List<String>.from(data['favoriteGenres'])
        : local.favoriteGenres,
  );
}


  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final fallbackName = prefs.getString('user_name') ?? 'Reader';

    // 1. Always load local data first
    final userData = _userBox.get('profile');
    if (userData != null) {
      _user = UserProfile.fromJson(Map<String, dynamic>.from(userData));
    } else {
      _user = UserProfile(name: fallbackName);
      await saveUser();
    }

    // 2. Try to sync with Firestore (non-blocking)
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        final uid = firebaseUser.uid;
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();

        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          // Merge carefully - keep local data if Firestore has empty fields
          _user = _mergeFirestoreData(data, _user!);
          await saveUser(); // Save merged data back to Hive
        } else {
          // No Firestore doc yet - create one from local data
          if (kDebugMode) {
            print('No Firestore doc found, creating from local data');
          }
          await _createFirestoreDoc(firebaseUser, _user!);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Firestore loadUser error (using local data): $e');
      }
      // Continue with local data - don't crash
    }

    _updateStreak();
    notifyListeners();
  }

Future<void> _createFirestoreDoc(User firebaseUser, UserProfile profile) async {
  try {
    final data = {
      'email': firebaseUser.email,
      'displayName': profile.name,
      'username': profile.username,
      'bio': profile.bio,
      'photoUrl': profile.photoUrl,
      'dob': profile.dob?.toIso8601String(),
      'favoriteGenres': profile.favoriteGenres,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser.uid)
        .set(data, SetOptions(merge: true));
    
    if (kDebugMode) {
      print('Created Firestore doc for user ${firebaseUser.uid}');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Failed to create Firestore doc: $e');
    }
  }
}


  Future<void> saveUser() async {
    if (_user != null) {
      await _userBox.put('profile', _user!.toJson());
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', _user!.name);
    }
  }

  Future<void> updateUserName(String name) async {
    if (_user == null) {
      _user = UserProfile(name: name);
    } else {
      _user = _user!.copyWith(name: name);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await saveUser();
    notifyListeners();
  }

  void _updateStreak() {
    if (_user == null) return;

    final now = DateTime.now();
    final lastDate = _user!.lastReadingDate;
    final difference = now
        .difference(DateTime(lastDate.year, lastDate.month, lastDate.day))
        .inDays;

    if (difference == 0) {
      return;
    } else if (difference == 1) {
      final newStreak = _user!.readingStreak + 1;
      final newLongest =
          newStreak > _user!.longestStreak ? newStreak : _user!.longestStreak;

      _user = _user!.copyWith(
        readingStreak: newStreak,
        longestStreak: newLongest,
        lastReadingDate: now,
      );

      saveUser();
    } else if (difference > 1) {
      _user = _user!.copyWith(
        readingStreak: 1,
        lastReadingDate: now,
      );
      saveUser();
    }
  }

  Future<void> setReadingGoal(int goal, int year) async {
    if (_user != null) {
      _user = _user!.copyWith(
        yearlyReadingGoal: goal,
        goalYear: year,
      );

      await saveUser();
      notifyListeners();
    }
  }

  Future<void> logReadingActivity() async {
    if (_user == null) return;

    _updateStreak();
    notifyListeners();
  }

  Future<void> incrementBooksRead() async {
    if (_user == null) return;

    _user = _user!.copyWith(
      totalBooksRead: _user!.totalBooksRead + 1,
    );

    await saveUser();
    notifyListeners();
  }

 Future<void> updateProfile({
  required String username,
  required String displayName,
  required String bio,
  DateTime? dob,
  String? photoUrl,
  List<String>? favoriteGenres,
}) async {
  final firebaseUser = FirebaseAuth.instance.currentUser;
  final newUsername = username.trim().toLowerCase();
  final newDisplayName = displayName.trim();
  final newBio = bio.trim();
  final newPhotoUrl = photoUrl?.trim();
  final newGenres = favoriteGenres ?? [];

  // Always update local model first
  _user = (_user ?? UserProfile(name: newDisplayName)).copyWith(
    name: newDisplayName,
    username: newUsername,
    bio: newBio,
    photoUrl: newPhotoUrl,
    dob: dob,
    favoriteGenres: newGenres,
  );
  await saveUser();

  if (firebaseUser == null) {
    notifyListeners();
    return;
  }

  try {
    final uid = firebaseUser.uid;
    final db = FirebaseFirestore.instance;

    await db.runTransaction((txn) async {
      final usernameRef = db.collection('usernames').doc(newUsername);
      final userRef = db.collection('users').doc(uid);

      final usernameSnap = await txn.get(usernameRef);
      final userSnap = await txn.get(userRef);
      final existing = userSnap.data() ?? {};
      final oldUsername = (existing['username'] ?? '').toString();

      if (usernameSnap.exists && usernameSnap.data()?['uid'] != uid) {
        throw Exception('username-taken');
      }

      if (oldUsername.isNotEmpty && oldUsername != newUsername) {
        final oldRef = db.collection('usernames').doc(oldUsername);
        txn.delete(oldRef);
      }

      txn.set(usernameRef, {'uid': uid});

      txn.set(
        userRef,
        {
          'email': firebaseUser.email,
          'displayName': newDisplayName,
          'username': newUsername,
          'bio': newBio,
          'photoUrl': newPhotoUrl,
          'dob': dob?.toIso8601String(),
          'favoriteGenres': newGenres,
          'createdAt':
              existing['createdAt'] ?? FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    });

    if (newDisplayName.isNotEmpty) {
      await firebaseUser.updateDisplayName(newDisplayName);
    }
    
    if (kDebugMode) {
      print('Profile updated successfully in Firestore');
    }
  } catch (e) {
    if (e.toString().contains('username-taken')) {
      throw e;
    }
    if (kDebugMode) {
      print('updateProfile error: $e');
    }
  }

  notifyListeners();
}


  void clear() {
    _user = null;
    _userBox.clear();
    notifyListeners();
  }
}
