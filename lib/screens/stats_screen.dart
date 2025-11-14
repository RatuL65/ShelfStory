import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/book_provider.dart';
import '../providers/user_provider.dart';
import '../utils/constants.dart';
import '../services/google_sign_in_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final GoogleSignInService _googleSignInService = GoogleSignInService();
  bool _isBackingUp = false;
  bool _isRestoring = false;

  Future<void> _backupToGoogleDrive() async {
    if (!_googleSignInService.isSignedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in with Google first from Setup')),
      );
      return;
    }

    setState(() => _isBackingUp = true);

    // TODO: Implement actual backup once Drive service is fixed
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _isBackingUp = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Backup feature coming soon!'),
      ),
    );
  }

  Future<void> _restoreFromGoogleDrive() async {
    if (!_googleSignInService.isSignedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in with Google first from Setup')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore from Backup?'),
        content: const Text(
          'This will replace all current books with backed up data. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isRestoring = true);

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _isRestoring = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Restore feature coming soon!'),
      ),
    );
  }

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

            // Google Drive Backup Section
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
                        'Google Drive Backup',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBrown,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Sign-in status
                  if (_googleSignInService.isSignedIn) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Signed in with Google',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
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
                            'Sign in with Google to enable backup',
                            style: TextStyle(
                              color: AppColors.primaryBrown,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Backup button
                  ElevatedButton.icon(
                    onPressed: _isBackingUp ? null : _backupToGoogleDrive,
                    icon: _isBackingUp
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.cloud_upload),
                    label: Text(_isBackingUp ? 'Backing up...' : 'Backup to Google Drive'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentGold,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Restore button
                  OutlinedButton.icon(
                    onPressed: _isRestoring ? null : _restoreFromGoogleDrive,
                    icon: _isRestoring
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.darkBrown,
                              ),
                            ),
                          )
                        : const Icon(Icons.cloud_download),
                    label: Text(_isRestoring
                        ? 'Restoring...'
                        : 'Restore from Google Drive'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.darkBrown,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      side: BorderSide(
                        color: AppColors.primaryBrown.withOpacity(0.3),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  // Sign out button (if signed in)
                  if (_googleSignInService.isSignedIn) ...[
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () async {
                        await _googleSignInService.signOut();
                        setState(() {});
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Signed out from Google')),
                        );
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Sign out from Google'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryBrown,
                      ),
                    ),
                  ],
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
