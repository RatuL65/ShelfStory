import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:io';
import '../models/book.dart';
import '../providers/book_provider.dart';
import '../providers/user_provider.dart';
import '../utils/constants.dart';

class AddBookScreen extends StatefulWidget {
  final Book? book;
  
  const AddBookScreen({super.key, this.book});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _genreController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();
  final _pagesController = TextEditingController();
  final _isbnController = TextEditingController();
  
  String? _coverImagePath;
  DateTime _datePurchased = DateTime.now();
  String _readingStatus = 'notStarted';
  double _storyRating = 0;
  double _characterRating = 0;
  double _writingStyleRating = 0;
  double _emotionalRating = 0;

  @override
  void initState() {
    super.initState();
    if (widget.book != null) {
      _loadBookData();
    }
  }

  void _loadBookData() {
    final book = widget.book!;
    _titleController.text = book.title;
    _authorController.text = book.author;
    _genreController.text = book.genre;
    _priceController.text = book.price?.toString() ?? '';
    _notesController.text = book.notes ?? '';
    _pagesController.text = book.totalPages?.toString() ?? '';
    _isbnController.text = book.isbn ?? '';
    _coverImagePath = book.coverImagePath;
    _datePurchased = book.datePurchased;
    _readingStatus = book.readingStatus;
    _storyRating = book.storyRating ?? 0;
    _characterRating = book.characterRating ?? 0;
    _writingStyleRating = book.writingStyleRating ?? 0;
    _emotionalRating = book.emotionalImpactRating ?? 0;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _genreController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    _pagesController.dispose();
    _isbnController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _coverImagePath = image.path;
      });
    }
  }

  Future<void> _scanBarcode() async {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          height: 400,
          child: MobileScanner(
            onDetect: (capture) async {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  Navigator.pop(context);
                  await _fetchBookInfo(barcode.rawValue!);
                  break;
                }
              }
            },
          ),
        ),
      ),
    );
  }

  Future<void> _fetchBookInfo(String isbn) async {
    _isbnController.text = isbn;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final bookProvider = Provider.of<BookProvider>(context, listen: false);
    final bookInfo = await bookProvider.fetchBookByISBN(isbn);
    
    if (!mounted) return;
    Navigator.pop(context);

    if (bookInfo != null) {
      setState(() {
        _titleController.text = bookInfo['title'] ?? '';
        _authorController.text = bookInfo['author'] ?? '';
        _genreController.text = bookInfo['genre'] ?? '';
        _pagesController.text = bookInfo['pageCount']?.toString() ?? '';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book info fetched successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not fetch book info')),
      );
    }
  }

  void _saveBook() async {
    if (_formKey.currentState!.validate()) {
      final book = Book(
        id: widget.book?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        author: _authorController.text,
        genre: _genreController.text,
        price: double.tryParse(_priceController.text),
        datePurchased: _datePurchased,
        coverImagePath: _coverImagePath,
        readingStatus: _readingStatus,
        storyRating: _storyRating > 0 ? _storyRating : null,
        characterRating: _characterRating > 0 ? _characterRating : null,
        writingStyleRating: _writingStyleRating > 0 ? _writingStyleRating : null,
        emotionalImpactRating: _emotionalRating > 0 ? _emotionalRating : null,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        totalPages: int.tryParse(_pagesController.text),
        isbn: _isbnController.text.isEmpty ? null : _isbnController.text,
        dateStarted: _readingStatus == 'reading' ? DateTime.now() : null,
        dateFinished: _readingStatus == 'finished' ? DateTime.now() : null,
      );

      final bookProvider = Provider.of<BookProvider>(context, listen: false);
      if (widget.book == null) {
        await bookProvider.addBook(book);
      } else {
        await bookProvider.updateBook(book);
      }

      // Update reading streak
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.logReadingActivity();

      if (_readingStatus == 'finished') {
        await userProvider.incrementBooksRead();
      }

      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book == null ? 'Add Book' : 'Edit Book'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _scanBarcode,
            tooltip: 'Scan Barcode',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Cover Image
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 150,
                  height: 220,
                  decoration: BoxDecoration(
                    color: AppColors.parchment,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _coverImagePath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(_coverImagePath!),
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 48,
                              color: AppColors.primaryBrown,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add Cover',
                              style: TextStyle(
                                color: AppColors.primaryBrown,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ISBN
            TextFormField(
              controller: _isbnController,
              decoration: const InputDecoration(
                labelText: 'ISBN (Optional)',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.numbers),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Author
            TextFormField(
              controller: _authorController,
              decoration: const InputDecoration(
                labelText: 'Author *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an author';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Genre
            TextFormField(
              controller: _genreController,
              decoration: const InputDecoration(
                labelText: 'Genre *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a genre';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Price and Pages Row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      border: OutlineInputBorder(),
                      prefixText: '\$ ',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _pagesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Total Pages',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Date Purchased
            ListTile(
              title: const Text('Date Purchased'),
              subtitle: Text(
                '${_datePurchased.day}/${_datePurchased.month}/${_datePurchased.year}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _datePurchased,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _datePurchased = date;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Reading Status
            DropdownButtonFormField<String>(
              value: _readingStatus,
              decoration: const InputDecoration(
                labelText: 'Reading Status',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'notStarted',
                  child: Text("Haven't Read"),
                ),
                DropdownMenuItem(
                  value: 'reading',
                  child: Text('Currently Reading'),
                ),
                DropdownMenuItem(
                  value: 'finished',
                  child: Text('Finished'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _readingStatus = value!;
                });
              },
            ),
            const SizedBox(height: 24),

            // Ratings Section
            Text(
              'Ratings (Optional)',
              style: AppTextStyles.heading(context),

            ),
            const SizedBox(height: 16),
            _buildRatingSlider('Story', _storyRating, (value) {
              setState(() {
                _storyRating = value;
              });
            }),
            _buildRatingSlider('Character', _characterRating, (value) {
              setState(() {
                _characterRating = value;
              });
            }),
            _buildRatingSlider('Writing Style', _writingStyleRating, (value) {
              setState(() {
                _writingStyleRating = value;
              });
            }),
            _buildRatingSlider('Emotional Impact', _emotionalRating, (value) {
              setState(() {
                _emotionalRating = value;
              });
            }),
            const SizedBox(height: 24),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: _saveBook,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                widget.book == null ? 'Add Book' : 'Update Book',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSlider(
    String label,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(
              value > 0 ? value.toStringAsFixed(1) : 'Not Rated',
              style: TextStyle(
                color: AppColors.accentGold,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: 0,
          max: 5,
          divisions: 10,
          activeColor: AppColors.accentGold,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
