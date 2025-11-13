class UserProfile {
  String name;
  int readingStreak;
  DateTime lastReadingDate;
  int totalBooksRead;
  int longestStreak;

  UserProfile({
    required this.name,
    this.readingStreak = 0,
    DateTime? lastReadingDate,
    this.totalBooksRead = 0,
    this.longestStreak = 0,
  }) : lastReadingDate = lastReadingDate ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'readingStreak': readingStreak,
      'lastReadingDate': lastReadingDate.toIso8601String(),
      'totalBooksRead': totalBooksRead,
      'longestStreak': longestStreak,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'],
      readingStreak: json['readingStreak'] ?? 0,
      lastReadingDate: DateTime.parse(json['lastReadingDate']),
      totalBooksRead: json['totalBooksRead'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
    );
  }
}
