import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/book.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class BookProvider with ChangeNotifier {
  Box<Book> get _bookBox => Hive.box<Book>('books');
  List<Book> _books = [];
  String _filterStatus = 'all';

  BookProvider() {
    _loadBooks();
  }

  List<Book> get books {
    if (_filterStatus == 'all') {
      return _books;
    }
    return _books.where((book) => book.readingStatus == _filterStatus).toList();
  }

  String get filterStatus => _filterStatus;

  void setFilter(String status) {
    _filterStatus = status;
    notifyListeners();
  }

  void _loadBooks() {
    try {
      _books = _bookBox.values.toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading books: $e');
      _books = [];
    }
  }

  Future<void> addBook(Book book) async {
    try {
      await _bookBox.put(book.id, book);
      _loadBooks();
      debugPrint('✅ Book added: ${book.title}');
    } catch (e) {
      debugPrint('❌ Error adding book: $e');
      rethrow;
    }
  }

  Future<void> updateBook(Book book) async {
    try {
      await _bookBox.put(book.id, book);
      _loadBooks();
      debugPrint('✅ Book updated: ${book.title}');
    } catch (e) {
      debugPrint('❌ Error updating book: $e');
      rethrow;
    }
  }

  Future<void> deleteBook(String bookId) async {
    try {
      await _bookBox.delete(bookId);
      _loadBooks();
      debugPrint('✅ Book deleted: $bookId');
    } catch (e) {
      debugPrint('❌ Error deleting book: $e');
      rethrow;
    }
  }

  // Fetch book info from Google Books API using ISBN
  Future<Map<String, dynamic>?> fetchBookByISBN(String isbn) async {
    try {
      final response = await http.get(
        Uri.parse('https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['totalItems'] > 0) {
          final bookInfo = data['items'][0]['volumeInfo'];
          return {
            'title': bookInfo['title'] ?? '',
            'author': (bookInfo['authors'] as List?)?.first ?? '',
            'genre': (bookInfo['categories'] as List?)?.first ?? 'Unknown',
            'coverUrl': bookInfo['imageLinks']?['thumbnail'] ?? '',
            'pageCount': bookInfo['pageCount'] ?? 0,
          };
        }
      }
    } catch (e) {
      debugPrint('Error fetching book: $e');
    }
    return null;
  }

  // Statistics
  int get totalBooks => _books.length;
  
  int get booksFinished => 
      _books.where((b) => b.readingStatus == 'finished').length;
  
  int get booksReading => 
      _books.where((b) => b.readingStatus == 'reading').length;
  
  int get booksNotStarted => 
      _books.where((b) => b.readingStatus == 'notStarted').length;

  int get totalPagesRead {
    return _books
        .where((b) => b.readingStatus == 'finished' && b.totalPages != null)
        .fold(0, (sum, book) => sum + book.totalPages!);
  }

  String? get topRatedGenre {
    final genreRatings = <String, List<double>>{};
    
    for (var book in _books) {
      if (book.averageRating != null) {
        genreRatings.putIfAbsent(book.genre, () => []);
        genreRatings[book.genre]!.add(book.averageRating!);
      }
    }

    if (genreRatings.isEmpty) return null;

    String? topGenre;
    double topAverage = 0;

    genreRatings.forEach((genre, ratings) {
      final avg = ratings.reduce((a, b) => a + b) / ratings.length;
      if (avg > topAverage) {
        topAverage = avg;
        topGenre = genre;
      }
    });

    return topGenre;
  }

  Map<String, int> get genreDistribution {
    final distribution = <String, int>{};
    for (var book in _books) {
      distribution[book.genre] = (distribution[book.genre] ?? 0) + 1;
    }
    return distribution;
  }
}
