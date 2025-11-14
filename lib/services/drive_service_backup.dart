import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/book.dart';

class DriveBackupService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['https://www.googleapis.com/auth/drive.file'],
  );

  // Get authentication headers
  Future<Map<String, String>> _getAuthHeaders() async {
    final account = _googleSignIn.currentUser ??
        await _googleSignIn.signInSilently() ??
        await _googleSignIn.signIn();

    if (account == null) throw Exception('Not signed in');

    final auth = await account.authentication;
    return {
      'Authorization': 'Bearer ${auth.accessToken}',
      'Content-Type': 'application/json',
    };
  }

  // Backup to Google Drive
  Future<bool> backupToGoogleDrive() async {
    try {
      // Get all books from Hive
      final booksBox = Hive.box<Book>('books');
      final books = booksBox.values.toList();

      // Convert to JSON using your Book model's actual fields
      final backupData = {
        'timestamp': DateTime.now().toIso8601String(),
        'books': books.map((book) {
          return {
            'id': book.id,
            'title': book.title,
            'author': book.author,
            'genre': book.genre,
            'price': book.price,
            'datePurchased': book.datePurchased.toIso8601String(),
            'coverImagePath': book.coverImagePath,
            'readingStatus': book.readingStatus,
            'storyRating': book.storyRating,
            'characterRating': book.characterRating,
            'writingStyleRating': book.writingStyleRating,
            'emotionalImpactRating': book.emotionalImpactRating,
            'notes': book.notes,
            'totalPages': book.totalPages,
            'currentPage': book.currentPage,
            'dateStarted': book.dateStarted?.toIso8601String(),
            'dateFinished': book.dateFinished?.toIso8601String(),
            'isbn': book.isbn,
          };
        }).toList(),
      };

      final jsonContent = jsonEncode(backupData);

      // Check if backup file already exists
      final existingFileId = await _getFileIdByName('shelfstory_backup.json');

      final headers = await _getAuthHeaders();

      if (existingFileId != null) {
        // Update existing file
        await _updateFile(existingFileId, jsonContent, headers);
      } else {
        // Create new file
        await _createFile(jsonContent, headers);
      }

      return true;
    } catch (e) {
      debugPrint('Backup error: $e');
      return false;
    }
  }

  // Restore from Google Drive
  Future<bool> restoreFromGoogleDrive() async {
    try {
      final fileId = await _getFileIdByName('shelfstory_backup.json');

      if (fileId == null) return false;

      final content = await _downloadFile(fileId);

      if (content == null) return false;

      final backupData = jsonDecode(content) as Map<String, dynamic>;
      final books = backupData['books'] as List<dynamic>;

      // Clear existing books
      final booksBox = Hive.box<Book>('books');
      await booksBox.clear();

      // Restore books using your Book model constructor
      for (var bookData in books) {
        final book = Book(
          id: bookData['id'] as String,
          title: bookData['title'] as String,
          author: bookData['author'] as String,
          genre: bookData['genre'] as String,
          price: (bookData['price'] as num?)?.toDouble(),
          datePurchased: DateTime.parse(bookData['datePurchased'] as String),
          coverImagePath: bookData['coverImagePath'] as String?,
          readingStatus: bookData['readingStatus'] as String? ?? 'notStarted',
          storyRating: (bookData['storyRating'] as num?)?.toDouble(),
          characterRating: (bookData['characterRating'] as num?)?.toDouble(),
          writingStyleRating: (bookData['writingStyleRating'] as num?)?.toDouble(),
          emotionalImpactRating: (bookData['emotionalImpactRating'] as num?)?.toDouble(),
          notes: bookData['notes'] as String?,
          totalPages: bookData['totalPages'] as int?,
          currentPage: bookData['currentPage'] as int?,
          dateStarted: bookData['dateStarted'] != null
              ? DateTime.parse(bookData['dateStarted'] as String)
              : null,
          dateFinished: bookData['dateFinished'] != null
              ? DateTime.parse(bookData['dateFinished'] as String)
              : null,
          isbn: bookData['isbn'] as String?,
        );

        await booksBox.add(book);
      }

      return true;
    } catch (e) {
      debugPrint('Restore error: $e');
      return false;
    }
  }

  // Helper: Get file ID by name
  Future<String?> _getFileIdByName(String fileName) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse(
          'https://www.googleapis.com/drive/v3/files?q=name="$fileName" and trashed=false',
        ),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final files = data['files'] as List<dynamic>;
        if (files.isNotEmpty) {
          return files[0]['id'] as String;
        }
      }
    } catch (e) {
      debugPrint('Error getting file ID: $e');
    }
    return null;
  }

  // Helper: Create file
  Future<void> _createFile(
      String content, Map<String, String> headers) async {
    final metadata = {
      'name': 'shelfstory_backup.json',
      'mimeType': 'application/json',
    };

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
          'https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart'),
    );

    request.headers.addAll(headers);
    request.files.add(
      http.MultipartFile.fromString(
        'metadata',
        jsonEncode(metadata),
        contentType: http.MediaType('application', 'json'),
      ),
    );
    request.files.add(
      http.MultipartFile.fromString('file', content),
    );

    await request.send();
  }

  // Helper: Update existing file
  Future<void> _updateFile(
    String fileId,
    String content,
    Map<String, String> headers,
  ) async {
    await http.patch(
      Uri.parse(
        'https://www.googleapis.com/upload/drive/v3/files/$fileId?uploadType=media',
      ),
      headers: headers,
      body: content,
    );
  }

  // Helper: Download file
  Future<String?> _downloadFile(String fileId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse(
          'https://www.googleapis.com/drive/v3/files/$fileId?alt=media',
        ),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (e) {
      debugPrint('Download error: $e');
    }
    return null;
  }
}
