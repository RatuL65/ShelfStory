import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../providers/user_provider.dart';
import '../utils/constants.dart';
import '../widgets/bookshelf_view.dart';
import '../widgets/streak_tracker.dart';
import 'add_book_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _filterStatus = 'all';

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userName = userProvider.user?.name ?? 'Reader';

    final List<Widget> screens = [
      _buildLibraryScreen(userName),
      const StatsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0 
              ? "$userName's Bookshelf" 
              : 'Reading Stats',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        actions: [
          if (_selectedIndex == 0) ...[
            PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list),
              onSelected: (value) {
                setState(() {
                  _filterStatus = value;
                });
                Provider.of<BookProvider>(context, listen: false)
                    .setFilter(value);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'all',
                  child: Text('All Books'),
                ),
                const PopupMenuItem(
                  value: 'notStarted',
                  child: Text("Haven't Read"),
                ),
                const PopupMenuItem(
                  value: 'reading',
                  child: Text('Currently Reading'),
                ),
                const PopupMenuItem(
                  value: 'finished',
                  child: Text('Finished'),
                ),
              ],
            ),
          ],
        ],
      ),
      body: screens[_selectedIndex],
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddBookScreen(),
                  ),
                );
              },
              backgroundColor: AppColors.accentGold,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add Book',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: AppColors.darkBrown,
        selectedItemColor: AppColors.accentGold,
        unselectedItemColor: AppColors.cream,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
        ],
      ),
    );
  }

  Widget _buildLibraryScreen(String userName) {
    return Column(
      children: [
        const StreakTracker(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _getFilterTitle(),
            style: AppTextStyles.subheading,
          ),
        ),
        const Expanded(
          child: BookshelfView(),
        ),
      ],
    );
  }

  String _getFilterTitle() {
    switch (_filterStatus) {
      case 'reading':
        return '📖 Currently Reading';
      case 'finished':
        return '✅ Finished Books';
      case 'notStarted':
        return '📚 To Read';
      default:
        return '📚 All Books';
    }
  }
}
