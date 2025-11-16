import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../models/book.dart';
import '../providers/book_provider.dart';
import '../utils/constants.dart';
import 'add_book_screen.dart';

class BookDetailScreen extends StatelessWidget {
  final Book book;

  const BookDetailScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddBookScreen(book: book),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image Header
            Container(
              width: double.infinity,
              height: 350,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.darkBrown,
                    AppColors.primaryBrown,
                  ],
                ),
              ),
              child: Center(
                child: Hero(
                  tag: 'book_${book.id}',
                  child: Container(
                    width: 200,
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: book.coverImagePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(book.coverImagePath!),
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: AppColors.parchment,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.book,
                              size: 80,
                              color: AppColors.primaryBrown,
                            ),
                          ),
                  ),
                ),
              ),
            ),

            // Book Info
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: AppTextStyles.heading(context),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'by ${book.author}',
                    style: AppTextStyles.vintage(context),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoChip(book.genre, Icons.category),
                  const SizedBox(height: 8),
                  _buildInfoChip(_getStatusText(), Icons.bookmark),
                  const SizedBox(height: 24),

                  // Ratings
                  if (book.averageRating != null) ...[
                    const Divider(),
                    const SizedBox(height: 16),
                    Text('Ratings', style: AppTextStyles.subheading(context)),
                    const SizedBox(height: 16),
                    _buildRatingRow('Story', book.storyRating),
                    _buildRatingRow('Character', book.characterRating),
                    _buildRatingRow('Writing Style', book.writingStyleRating),
                    _buildRatingRow(
                      'Emotional Impact',
                      book.emotionalImpactRating,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text(
                          'Average: ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ...List.generate(
                          5,
                          (index) => Icon(
                            index < (book.averageRating ?? 0).round()
                                ? Icons.star
                                : Icons.star_border,
                            color: AppColors.accentGold,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          book.averageRating!.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accentGold,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Additional Info
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text('Details', style: AppTextStyles.subheading(context)),
                  const SizedBox(height: 16),
                  if (book.price != null)
                    _buildDetailRow('Price', '\$${book.price!.toStringAsFixed(2)}'),
                  _buildDetailRow(
                    'Purchased',
                    '${book.datePurchased.day}/${book.datePurchased.month}/${book.datePurchased.year}',
                  ),
                  if (book.totalPages != null)
                    _buildDetailRow('Pages', book.totalPages.toString()),
                  if (book.isbn != null)
                    _buildDetailRow('ISBN', book.isbn!),

                  // Notes
                  if (book.notes != null && book.notes!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text('Notes', style: AppTextStyles.subheading(context)),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.parchment,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        book.notes!,
                        style: AppTextStyles.body(context),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.accentGold.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accentGold),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.darkBrown),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: AppColors.darkBrown,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingRow(String label, double? rating) {
    if (rating == null) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(label),
          ),
          ...List.generate(
            5,
            (index) => Icon(
              index < rating.round() ? Icons.star : Icons.star_border,
              color: AppColors.accentGold,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.accentGold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _getStatusText() {
    switch (book.readingStatus) {
      case 'reading':
        return 'Currently Reading';
      case 'finished':
        return 'Finished';
      default:
        return "Haven't Read";
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Book'),
        content: const Text('Are you sure you want to delete this book?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<BookProvider>(context, listen: false)
                  .deleteBook(book.id);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
