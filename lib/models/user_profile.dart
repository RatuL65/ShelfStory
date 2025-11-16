class UserProfile {
  final String name;
  final DateTime joinDate;
  final int readingStreak;
  final int longestStreak;
  final DateTime lastReadingDate;
  final int totalBooksRead;
  final int? yearlyReadingGoal;
  final int? goalYear;
  
  UserProfile({
    required this.name,
    DateTime? joinDate,
    this.readingStreak = 0,
    this.longestStreak = 0,
    DateTime? lastReadingDate,
    this.totalBooksRead = 0,
    this.yearlyReadingGoal,
    this.goalYear,
  }) : joinDate = joinDate ?? DateTime.now(),
       lastReadingDate = lastReadingDate ?? DateTime.now();
  
  Map<String, dynamic> toJson() => {
    'name': name,
    'joinDate': joinDate.toIso8601String(),
    'readingStreak': readingStreak,
    'longestStreak': longestStreak,
    'lastReadingDate': lastReadingDate.toIso8601String(),
    'totalBooksRead': totalBooksRead,
    'yearlyReadingGoal': yearlyReadingGoal,
    'goalYear': goalYear,
  };
  
  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'],
    joinDate: DateTime.parse(json['joinDate']),
    readingStreak: json['readingStreak'] ?? 0,
    longestStreak: json['longestStreak'] ?? 0,
    lastReadingDate: json['lastReadingDate'] != null 
        ? DateTime.parse(json['lastReadingDate'])
        : DateTime.now(),
    totalBooksRead: json['totalBooksRead'] ?? 0,
    yearlyReadingGoal: json['yearlyReadingGoal'],
    goalYear: json['goalYear'],
  );
  
  // Helper method to create a copy with modifications
  UserProfile copyWith({
    String? name,
    DateTime? joinDate,
    int? readingStreak,
    int? longestStreak,
    DateTime? lastReadingDate,
    int? totalBooksRead,
    int? yearlyReadingGoal,
    int? goalYear,
  }) {
    return UserProfile(
      name: name ?? this.name,
      joinDate: joinDate ?? this.joinDate,
      readingStreak: readingStreak ?? this.readingStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastReadingDate: lastReadingDate ?? this.lastReadingDate,
      totalBooksRead: totalBooksRead ?? this.totalBooksRead,
      yearlyReadingGoal: yearlyReadingGoal ?? this.yearlyReadingGoal,
      goalYear: goalYear ?? this.goalYear,
    );
  }
}
