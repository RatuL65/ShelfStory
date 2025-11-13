import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class UserProvider with ChangeNotifier {
  UserProfile? _user;
  final Box _userBox = Hive.box('user');

  UserProfile? get user => _user;

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? 'Reader';
    
    final userData = _userBox.get('profile');
    if (userData != null) {
      _user = UserProfile.fromJson(Map<String, dynamic>.from(userData));
    } else {
      _user = UserProfile(name: name);
      await saveUser();
    }
    
    _updateStreak();
    notifyListeners();
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
      _user!.name = name;
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
    final difference = now.difference(DateTime(
      lastDate.year,
      lastDate.month,
      lastDate.day,
    )).inDays;

    if (difference == 0) {
      // Same day, no change
      return;
    } else if (difference == 1) {
      // Consecutive day, increment streak
      _user!.readingStreak++;
      _user!.lastReadingDate = now;
      
      if (_user!.readingStreak > _user!.longestStreak) {
        _user!.longestStreak = _user!.readingStreak;
      }
      
      saveUser();
    } else if (difference > 1) {
      // Streak broken
      _user!.readingStreak = 1;
      _user!.lastReadingDate = now;
      saveUser();
    }
  }

  Future<void> logReadingActivity() async {
    if (_user == null) return;
    
    _updateStreak();
    notifyListeners();
  }

  Future<void> incrementBooksRead() async {
    if (_user == null) return;
    
    _user!.totalBooksRead++;
    await saveUser();
    notifyListeners();
  }
}
