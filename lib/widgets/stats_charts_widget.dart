import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/book.dart';
import '../utils/constants.dart';

class StatsChartsWidget extends StatelessWidget {
  final List<Book> books;
  
  const StatsChartsWidget({
    super.key,
    required this.books,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Genre Distribution Chart
        _buildGenreChart(),
        const SizedBox(height: 16),
        
        // Monthly Reading Chart
        _buildMonthlyReadingChart(),
        const SizedBox(height: 16),
        
        // Rating Distribution Chart
        _buildRatingChart(),
      ],
    );
  }
  
  Widget _buildGenreChart() {
    final genreCount = <String, int>{};
    
    for (var book in books) {
      final genre = book.genre.isEmpty ? 'Unknown' : book.genre;
      genreCount[genre] = (genreCount[genre] ?? 0) + 1;
    }
    
    if (genreCount.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // Get top 5 genres
    final sortedGenres = genreCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topGenres = sortedGenres.take(5).toList();
    
    final colors = [
      AppColors.accentGold,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
    ];
    
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
            'Books by Genre',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.darkBrown,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: PieChart(
                    PieChartData(
                      sections: topGenres.asMap().entries.map((entry) {
                        final index = entry.key;
                        final genre = entry.value.key;
                        final count = entry.value.value;
                        final percentage = (count / books.length * 100).round();
                        
                        return PieChartSectionData(
                          value: count.toDouble(),
                          title: '$percentage%',
                          color: colors[index % colors.length],
                          radius: 60,
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: topGenres.asMap().entries.map((entry) {
                      final index = entry.key;
                      final genre = entry.value.key;
                      final count = entry.value.value;
                      
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: colors[index % colors.length],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '$genre ($count)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.darkBrown,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMonthlyReadingChart() {
    final monthlyCount = <int, int>{};
    final currentYear = DateTime.now().year;
    
    for (var book in books.where((b) => 
        b.readingStatus == 'finished' && 
        b.dateFinished != null &&
        b.dateFinished!.year == currentYear)) {
      final month = book.dateFinished!.month;
      monthlyCount[month] = (monthlyCount[month] ?? 0) + 1;
    }
    
    if (monthlyCount.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final maxCount = monthlyCount.values.reduce((a, b) => a > b ? a : b);
    
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
            'Books Finished This Year',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.darkBrown,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (maxCount + 2).toDouble(),
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const months = ['J', 'F', 'M', 'A', 'M', 'J', 
                                       'J', 'A', 'S', 'O', 'N', 'D'];
                        if (value.toInt() >= 1 && value.toInt() <= 12) {
                          return Text(
                            months[value.toInt() - 1],
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primaryBrown,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value % 1 == 0) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primaryBrown,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.primaryBrown.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(12, (index) {
                  final month = index + 1;
                  final count = monthlyCount[month] ?? 0;
                  
                  return BarChartGroupData(
                    x: month,
                    barRods: [
                      BarChartRodData(
                        toY: count.toDouble(),
                        color: AppColors.accentGold,
                        width: 16,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRatingChart() {
    final ratedBooks = books.where((b) => b.averageRating != null).toList();
    
    if (ratedBooks.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final ratingCount = <int, int>{};
    for (var book in ratedBooks) {
      final rating = book.averageRating!.round();
      ratingCount[rating] = (ratingCount[rating] ?? 0) + 1;
    }
    
    final maxCount = ratingCount.values.isEmpty 
        ? 1 
        : ratingCount.values.reduce((a, b) => a > b ? a : b);
    
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
            'Rating Distribution',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.darkBrown,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (maxCount + 2).toDouble(),
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value >= 1 && value <= 5) {
                          return Text(
                            '${value.toInt()}⭐',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primaryBrown,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value % 1 == 0) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primaryBrown,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.primaryBrown.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(5, (index) {
                  final rating = index + 1;
                  final count = ratingCount[rating] ?? 0;
                  
                  return BarChartGroupData(
                    x: rating,
                    barRods: [
                      BarChartRodData(
                        toY: count.toDouble(),
                        color: _getRatingColor(rating),
                        width: 32,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getRatingColor(int rating) {
    switch (rating) {
      case 5:
        return Colors.green;
      case 4:
        return Colors.lightGreen;
      case 3:
        return Colors.orange;
      case 2:
        return Colors.deepOrange;
      case 1:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
