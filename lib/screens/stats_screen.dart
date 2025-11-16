import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/book_provider.dart';
import '../providers/user_provider.dart';
import '../utils/constants.dart';
import '../widgets/reading_goal_widget.dart';
import '../widgets/stats_charts_widget.dart';


class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}


class _StatsScreenState extends State<StatsScreen> {
  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final books = bookProvider.books;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final totalBooks = books.length;
    final booksRead = books.where((b) => b.readingStatus == 'finished').length;
    final booksReading = books.where((b) => b.readingStatus == 'reading').length;
    final booksToRead = books.where((b) => b.readingStatus == 'notStarted').length;

    final totalPages = books.fold<int>(0, (sum, book) => sum + (book.totalPages ?? 0));
    final pagesRead = books
        .where((b) => b.readingStatus == 'finished')
        .fold<int>(0, (sum, book) => sum + (book.totalPages ?? 0));

    final currentStreak = userProvider.user?.readingStreak ?? 0;
    final longestStreak = userProvider.user?.longestStreak ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Statistics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Books Overview Card
            _buildStatCard(
              title: 'Books Overview',
              isDark: isDark,
              children: [
                _buildStatRow('Total Books', totalBooks.toString(), isDark),
                _buildStatRow('Books Read', booksRead.toString(), isDark),
                _buildStatRow('Currently Reading', booksReading.toString(), isDark),
                _buildStatRow('To Read', booksToRead.toString(), isDark),
              ],
            ),
            const SizedBox(height: 16),

            // Reading Progress Card
            _buildStatCard(
              title: 'Reading Progress',
              isDark: isDark,
              children: [
                _buildStatRow('Total Pages', totalPages.toString(), isDark),
                _buildStatRow('Pages Read', pagesRead.toString(), isDark),
                _buildStatRow(
                  'Completion Rate',
                  totalBooks > 0
                      ? '${((booksRead / totalBooks) * 100).toStringAsFixed(1)}%'
                      : '0%',
                  isDark,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Streak Card
            _buildStatCard(
              title: 'Reading Streaks',
              isDark: isDark,
              children: [
                _buildStatRow('Current Streak', '$currentStreak days', isDark),
                _buildStatRow('Longest Streak', '$longestStreak days', isDark),
              ],
            ),
            const SizedBox(height: 16),
            
            const ReadingGoalWidget(isCompact: false),
            const SizedBox(height: 16),

            // Recent Activity Card
            if (books.isNotEmpty) ...[
              _buildStatCard(
                title: 'Recent Activity',
                isDark: isDark,
                children: [
                  _buildStatRow(
                    'Last Book Added',
                    books.last.title,
                    isDark,
                  ),
                  _buildStatRow(
                    'Date Purchased',
                    DateFormat('MMM dd, yyyy').format(books.last.datePurchased),
                    isDark,
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Chart section
            if (books.length >= 3) ...[
              Text(
                'Visual Statistics',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkText : AppColors.darkBrown,
                ),
              ),
              const SizedBox(height: 16),
              StatsChartsWidget(books: books),
            ],

            // Coming Soon Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.cloud_queue,
                        color: isDark ? AppColors.darkText : AppColors.darkBrown,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Cloud Backup',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkText : AppColors.darkBrown,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.primaryBrown,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Cloud backup and sync coming soon in v2.0!',
                          style: TextStyle(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.primaryBrown,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required List<Widget> children,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkText : AppColors.darkBrown,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? AppColors.darkTextSecondary : AppColors.primaryBrown,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkText : AppColors.darkBrown,
            ),
          ),
        ],
      ),
    );
  }
}
