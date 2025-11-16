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
      // Create new UserProfile with updated name
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
      final newStreak = _user!.readingStreak + 1;
      final newLongest = newStreak > _user!.longestStreak 
          ? newStreak 
          : _user!.longestStreak;
      
      _user = _user!.copyWith(
        readingStreak: newStreak,
        longestStreak: newLongest,
        lastReadingDate: now,
      );
      
      saveUser();
    } else if (difference > 1) {
      // Streak broken
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
}
