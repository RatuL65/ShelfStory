import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/book_provider.dart';
import '../providers/user_provider.dart';
import '../utils/constants.dart';


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
        backgroundColor: AppColors.darkBrown,
      ),
      backgroundColor: AppColors.backgroundCream,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Books Overview Card
            _buildStatCard(
              title: 'Books Overview',
              children: [
                _buildStatRow('Total Books', totalBooks.toString()),
                _buildStatRow('Books Read', booksRead.toString()),
                _buildStatRow('Currently Reading', booksReading.toString()),
                _buildStatRow('To Read', booksToRead.toString()),
              ],
            ),
            const SizedBox(height: 16),


            // Reading Progress Card
            _buildStatCard(
              title: 'Reading Progress',
              children: [
                _buildStatRow('Total Pages', totalPages.toString()),
                _buildStatRow('Pages Read', pagesRead.toString()),
                _buildStatRow(
                  'Completion Rate',
                  totalBooks > 0
                      ? '${((booksRead / totalBooks) * 100).toStringAsFixed(1)}%'
                      : '0%',
                ),
              ],
            ),
            const SizedBox(height: 16),


            // Streak Card
            _buildStatCard(
              title: 'Reading Streaks',
              children: [
                _buildStatRow('Current Streak', '$currentStreak days'),
                _buildStatRow('Longest Streak', '$longestStreak days'),
              ],
            ),
            const SizedBox(height: 16),


            // Recent Activity Card
            if (books.isNotEmpty) ...[
              _buildStatCard(
                title: 'Recent Activity',
                children: [
                  _buildStatRow(
                    'Last Book Added',
                    books.last.title,
                  ),
                  _buildStatRow(
                    'Date Purchased',
                    DateFormat('MMM dd, yyyy').format(books.last.datePurchased),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],


            // Coming Soon Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cream,
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
                        color: AppColors.darkBrown,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Cloud Backup',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBrown,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primaryBrown,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Cloud backup and sync coming soon in v2.0!',
                          style: TextStyle(
                            color: AppColors.primaryBrown,
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
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cream,
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
              color: AppColors.darkBrown,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }


  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.primaryBrown,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkBrown,
            ),
          ),
        ],
      ),
    );
  }
}
