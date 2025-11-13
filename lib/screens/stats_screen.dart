import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../providers/book_provider.dart';
import '../providers/user_provider.dart';
import '../utils/constants.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reading Streak Card
          _buildStreakCard(userProvider),
          const SizedBox(height: 24),

          // Stats Grid
          Text('Your Statistics', style: AppTextStyles.heading),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildStatCard(
                'Total Books',
                bookProvider.totalBooks.toString(),
                Icons.library_books,
                AppColors.accentGold,
              ),
              _buildStatCard(
                'Finished',
                bookProvider.booksFinished.toString(),
                Icons.check_circle,
                Colors.green,
              ),
              _buildStatCard(
                'Currently Reading',
                bookProvider.booksReading.toString(),
                Icons.auto_stories,
                Colors.blue,
              ),
              _buildStatCard(
                'To Read',
                bookProvider.booksNotStarted.toString(),
                Icons.bookmark,
                Colors.orange,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Fun Facts
          Text('Reading Insights', style: AppTextStyles.heading),
          const SizedBox(height: 16),
          _buildInsightCard(
            context,
            '📚 You\'ve finished ${bookProvider.booksFinished} books this year!',
          ),
          if (bookProvider.totalPagesRead > 0)
            _buildInsightCard(
              context,
              '📖 That\'s ${bookProvider.totalPagesRead} pages read!',
            ),
          _buildInsightCard(
            context,
            _getReadingGoalInsight(bookProvider.booksFinished),
          ),
          if (bookProvider.topRatedGenre != null)
            _buildInsightCard(
              context,
              '⭐ Your top-rated genre: ${bookProvider.topRatedGenre}',
            ),
          if (userProvider.user != null)
            _buildInsightCard(
              context,
              '🔥 Longest reading streak: ${userProvider.user!.longestStreak} days',
            ),

          const SizedBox(height: 24),

          // Genre Distribution
          if (bookProvider.genreDistribution.isNotEmpty) ...[
            Text('Genre Distribution', style: AppTextStyles.heading),
            const SizedBox(height: 16),
            ...bookProvider.genreDistribution.entries.map(
              (entry) => _buildGenreBar(
                entry.key,
                entry.value,
                bookProvider.totalBooks,
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Export Button
          Center(
            child: ElevatedButton.icon(
              onPressed: () => _exportData(context, bookProvider),
              icon: const Icon(Icons.download),
              label: const Text('Export Library Data'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(UserProvider userProvider) {
    final streak = userProvider.user?.readingStreak ?? 0;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.accentGold, AppColors.darkGold],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '🔥 Reading Streak',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '$streak',
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Text(
            'consecutive days',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _getStreakMessage(streak),
            style: const TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.parchment,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.body,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(BuildContext context, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.parchment,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.accentGold),
      ),
      child: Text(
        text,
        style: AppTextStyles.body.copyWith(fontSize: 16),
      ),
    );
  }

  Widget _buildGenreBar(String genre, int count, int total) {
    final percentage = (count / total * 100).toInt();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(genre, style: AppTextStyles.body),
              Text(
                '$count books ($percentage%)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: count / total,
              minHeight: 12,
              backgroundColor: AppColors.backgroundCream,
              valueColor: AlwaysStoppedAnimation(AppColors.accentGold),
            ),
          ),
        ],
      ),
    );
  }

  String _getStreakMessage(int streak) {
    if (streak == 0) return 'Start reading to begin your streak!';
    if (streak < 3) return 'Great start! Keep it up!';
    if (streak < 7) return 'You\'re on fire! 🔥';
    if (streak < 14) return 'Amazing consistency!';
    if (streak < 30) return 'You\'re a reading machine!';
    return 'Legendary reader status! 📚';
  }

  String _getReadingGoalInsight(int booksRead) {
    final booksToNapoleon = 15 - booksRead;
    if (booksToNapoleon > 0) {
      return '📚 Only $booksToNapoleon more books till you reach Napoleon-level reading habits!';
    }
    return '👑 You\'ve surpassed Napoleon\'s reading habits!';
  }

  Future<void> _exportData(
    BuildContext context,
    BookProvider bookProvider,
  ) async {
    try {
      // Create CSV data
      List<List<dynamic>> rows = [
        [
          'Title',
          'Author',
          'Genre',
          'Status',
          'Date Purchased',
          'Price',
          'Pages',
          'Story Rating',
          'Character Rating',
          'Writing Style Rating',
          'Emotional Impact Rating',
          'Average Rating',
          'Notes',
        ],
      ];

      for (var book in bookProvider.books) {
        rows.add([
          book.title,
          book.author,
          book.genre,
          book.readingStatus,
          book.datePurchased.toIso8601String(),
          book.price ?? '',
          book.totalPages ?? '',
          book.storyRating ?? '',
          book.characterRating ?? '',
          book.writingStyleRating ?? '',
          book.emotionalImpactRating ?? '',
          book.averageRating?.toStringAsFixed(2) ?? '',
          book.notes ?? '',
        ]);
      }

      String csv = const ListToCsvConverter().convert(rows);

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/shelf_story_export_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File(path);
      await file.writeAsString(csv);

      if (!context.mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data exported to:\n$path'),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {},
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }
}
