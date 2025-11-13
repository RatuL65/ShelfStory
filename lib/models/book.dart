import 'package:hive/hive.dart';

part 'book.g.dart';

@HiveType(typeId: 0)
class Book extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String author;

  @HiveField(3)
  String genre;

  @HiveField(4)
  double? price;

  @HiveField(5)
  DateTime datePurchased;

  @HiveField(6)
  String? coverImagePath;

  @HiveField(7)
  String readingStatus; // notStarted, reading, finished

  @HiveField(8)
  double? storyRating;

  @HiveField(9)
  double? characterRating;

  @HiveField(10)
  double? writingStyleRating;

  @HiveField(11)
  double? emotionalImpactRating;

  @HiveField(12)
  String? notes;

  @HiveField(13)
  int? totalPages;

  @HiveField(14)
  int? currentPage;

  @HiveField(15)
  DateTime? dateStarted;

  @HiveField(16)
  DateTime? dateFinished;

  @HiveField(17)
  String? isbn;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.genre,
    this.price,
    required this.datePurchased,
    this.coverImagePath,
    this.readingStatus = 'notStarted',
    this.storyRating,
    this.characterRating,
    this.writingStyleRating,
    this.emotionalImpactRating,
    this.notes,
    this.totalPages,
    this.currentPage,
    this.dateStarted,
    this.dateFinished,
    this.isbn,
  });

  double? get averageRating {
    final ratings = [
      storyRating,
      characterRating,
      writingStyleRating,
      emotionalImpactRating,
    ].where((r) => r != null).toList();

    if (ratings.isEmpty) return null;

    double sum = 0;
    for (var rating in ratings) {
      sum += rating!;
    }
    return sum / ratings.length;
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'genre': genre,
      'price': price,
      'datePurchased': datePurchased.toIso8601String(),
      'coverImagePath': coverImagePath,
      'readingStatus': readingStatus,
      'storyRating': storyRating,
      'characterRating': characterRating,
      'writingStyleRating': writingStyleRating,
      'emotionalImpactRating': emotionalImpactRating,
      'notes': notes,
      'totalPages': totalPages,
      'currentPage': currentPage,
      'dateStarted': dateStarted?.toIso8601String(),
      'dateFinished': dateFinished?.toIso8601String(),
      'isbn': isbn,
    };
  }
}
