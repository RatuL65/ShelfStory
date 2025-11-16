import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../providers/user_provider.dart';
import '../utils/constants.dart';
import '../widgets/bookshelf_view.dart';
import '../widgets/streak_tracker.dart';
import 'add_book_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';
import '../widgets/reading_goal_widget.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});


  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _filterStatus = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


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
        title: _isSearching && _selectedIndex == 0
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search books...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              )
            : Text(
                _selectedIndex == 0 
                    ? "$userName's Bookshelf" 
                    : 'Reading Stats',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
        actions: [
          // Search icon (only on Library tab)
          if (_selectedIndex == 0) ...[
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _searchController.clear();
                    _searchQuery = '';
                  }
                });
              },
              tooltip: _isSearching ? 'Close Search' : 'Search Books',
            ),
          ],
          // Settings icon (both tabs)
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
            tooltip: 'Settings',
          ),
          // Filter menu (only on Library tab when not searching)
          if (_selectedIndex == 0 && !_isSearching) ...[
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
            if (index != 0) {
              // Close search when switching tabs
              _isSearching = false;
              _searchController.clear();
              _searchQuery = '';
            }
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
      const ReadingGoalWidget(isCompact: true),  // ADD THIS LINE
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          _isSearching && _searchQuery.isNotEmpty
              ? '🔍 Search: "$_searchQuery"'
              : _getFilterTitle(),
          style: AppTextStyles.subheading(context),
        ),
      ),
      Expanded(
        child: BookshelfView(searchQuery: _searchQuery),
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
