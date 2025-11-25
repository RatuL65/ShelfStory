class UserProfile {
  final String name;
  final String? username;
  final String? bio;
  final String? photoUrl;
  final DateTime? dob; // <-- Add this line
  final DateTime lastReadingDate;
  final int readingStreak;
  final int longestStreak;
  final int yearlyReadingGoal;
  final int goalYear;
  final int totalBooksRead;

  UserProfile({
    required this.name,
    this.username,
    this.bio,
    this.photoUrl,
    this.dob, // <-- Add this line
    DateTime? lastReadingDate,
    this.readingStreak = 1,
    this.longestStreak = 1,
    this.yearlyReadingGoal = 0,
    this.goalYear = 0,
    this.totalBooksRead = 0,
  }) : lastReadingDate = lastReadingDate ?? DateTime.now();

  UserProfile copyWith({
    String? name,
    String? username,
    String? bio,
    String? photoUrl,
    DateTime? dob, // <-- Add this line
    DateTime? lastReadingDate,
    int? readingStreak,
    int? longestStreak,
    int? yearlyReadingGoal,
    int? goalYear,
    int? totalBooksRead,
  }) {
    return UserProfile(
      name: name ?? this.name,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      photoUrl: photoUrl ?? this.photoUrl,
      dob: dob ?? this.dob, // <-- Add this line
      lastReadingDate: lastReadingDate ?? this.lastReadingDate,
      readingStreak: readingStreak ?? this.readingStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      yearlyReadingGoal: yearlyReadingGoal ?? this.yearlyReadingGoal,
      goalYear: goalYear ?? this.goalYear,
      totalBooksRead: totalBooksRead ?? this.totalBooksRead,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'username': username,
      'bio': bio,
      'photoUrl': photoUrl,
      'dob': dob?.toIso8601String(), // <-- Add this line
      'lastReadingDate': lastReadingDate.toIso8601String(),
      'readingStreak': readingStreak,
      'longestStreak': longestStreak,
      'yearlyReadingGoal': yearlyReadingGoal,
      'goalYear': goalYear,
      'totalBooksRead': totalBooksRead,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? 'Reader',
      username: json['username'],
      bio: json['bio'],
      photoUrl: json['photoUrl'],
      dob: (json['dob'] != null && json['dob'] is String && json['dob'].isNotEmpty)
          ? DateTime.tryParse(json['dob'])
          : null, // <-- Parse safely
      lastReadingDate: DateTime.tryParse(json['lastReadingDate'] ?? '') ??
          DateTime.now(),
      readingStreak: json['readingStreak'] ?? 1,
      longestStreak: json['longestStreak'] ?? 1,
      yearlyReadingGoal: json['yearlyReadingGoal'] ?? 0,
      goalYear: json['goalYear'] ?? 0,
      totalBooksRead: json['totalBooksRead'] ?? 0,
    );
  }
}
