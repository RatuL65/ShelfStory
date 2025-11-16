import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../providers/user_provider.dart';
import '../utils/constants.dart';

class ReadingGoalWidget extends StatelessWidget {
  final bool isCompact;
  
  const ReadingGoalWidget({
    super.key,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    
    final currentYear = DateTime.now().year;
    final booksFinishedThisYear = bookProvider.books
        .where((book) => 
            book.readingStatus == 'finished' &&
            book.dateFinished != null &&
            book.dateFinished!.year == currentYear)
        .length;
    
    final goal = userProvider.user?.yearlyReadingGoal ?? 0;
    final goalYear = userProvider.user?.goalYear ?? currentYear;
    
    // If no goal set or goal is for different year
    if (goal == 0 || goalYear != currentYear) {
      return _buildSetGoalPrompt(context);
    }
    
    final progress = booksFinishedThisYear / goal;
    final percentage = (progress * 100).clamp(0, 100).toInt();
    
    if (isCompact) {
      return _buildCompactView(context, booksFinishedThisYear, goal, progress, percentage);
    } else {
      return _buildFullView(context, booksFinishedThisYear, goal, progress, percentage);
    }
  }
  
  Widget _buildSetGoalPrompt(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.accentGold.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.flag_outlined,
            color: AppColors.accentGold,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Set Your Reading Goal',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBrown,
                  ),
                ),
                Text(
                  'How many books do you want to read this year?',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryBrown,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _showSetGoalDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentGold,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Set Goal'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCompactView(BuildContext context, int current, int goal, double progress, int percentage) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${DateTime.now().year} Reading Goal',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBrown,
                ),
              ),
              Text(
                '$current / $goal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 12,
              backgroundColor: AppColors.primaryBrown.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                _getProgressColor(percentage),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getMotivationalMessage(current, goal, percentage),
            style: TextStyle(
              fontSize: 12,
              color: AppColors.primaryBrown,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFullView(BuildContext context, int current, int goal, double progress, int percentage) {
    final remaining = (goal - current).clamp(0, goal);
    final daysLeft = DateTime(DateTime.now().year, 12, 31).difference(DateTime.now()).inDays;
    final booksPerMonth = remaining > 0 && daysLeft > 0 
        ? (remaining / (daysLeft / 30)).toStringAsFixed(1) 
        : '0';
    
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${DateTime.now().year} Reading Goal',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBrown,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getMotivationalMessage(current, goal, percentage),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryBrown,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.edit, color: AppColors.primaryBrown),
                onPressed: () => _showSetGoalDialog(context),
                tooltip: 'Edit Goal',
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Progress Circle
          Center(
            child: SizedBox(
              width: 150,
              height: 150,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    strokeWidth: 12,
                    backgroundColor: AppColors.primaryBrown.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getProgressColor(percentage),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$current',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBrown,
                        ),
                      ),
                      Text(
                        'of $goal books',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primaryBrown,
                        ),
                      ),
                      Text(
                        '$percentage%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _getProgressColor(percentage),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.library_books,
                label: 'Remaining',
                value: '$remaining',
                color: Colors.orange,
              ),
              _buildStatItem(
                icon: Icons.calendar_today,
                label: 'Days Left',
                value: '$daysLeft',
                color: Colors.blue,
              ),
              _buildStatItem(
                icon: Icons.speed,
                label: 'Per Month',
                value: booksPerMonth,
                color: Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.darkBrown,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.primaryBrown,
          ),
        ),
      ],
    );
  }
  
  Color _getProgressColor(int percentage) {
    if (percentage >= 75) return Colors.green;
    if (percentage >= 50) return Colors.blue;
    if (percentage >= 25) return Colors.orange;
    return Colors.red;
  }
  
  String _getMotivationalMessage(int current, int goal, int percentage) {
    if (current >= goal) {
      return '🎉 Goal achieved! Keep reading!';
    } else if (percentage >= 75) {
      return '🔥 Almost there! Just ${goal - current} more to go!';
    } else if (percentage >= 50) {
      return '💪 Halfway there! Keep it up!';
    } else if (percentage >= 25) {
      return '📚 Great start! Keep reading!';
    } else if (current > 0) {
      return '🌱 You\'ve started! Keep going!';
    } else {
      return '🎯 Let\'s start your reading journey!';
    }
  }
  
  Future<void> _showSetGoalDialog(BuildContext context) async {
    final controller = TextEditingController();
    final currentGoal = Provider.of<UserProvider>(context, listen: false).user?.yearlyReadingGoal;
    
    if (currentGoal != null && currentGoal > 0) {
      controller.text = currentGoal.toString();
    }
    
    final goal = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set ${DateTime.now().year} Reading Goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'How many books do you want to read this year?',
              style: TextStyle(fontSize: 14, color: AppColors.primaryBrown),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'e.g., 50',
                suffixText: 'books',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.flag),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value > 0) {
                Navigator.pop(context, value);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentGold,
            ),
            child: const Text('Set Goal'),
          ),
        ],
      ),
    );
    
    if (goal != null && goal > 0) {
      if (!context.mounted) return;
      
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.setReadingGoal(goal, DateTime.now().year);
      
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reading goal set to $goal books for ${DateTime.now().year}!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
