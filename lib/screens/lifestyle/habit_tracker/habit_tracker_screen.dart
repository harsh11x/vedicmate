import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
// import '../../../providers/habit_provider.dart'; // Uncomment when provider is ready

class HabitTrackerScreen extends ConsumerStatefulWidget {
  const HabitTrackerScreen({super.key});

  @override
  ConsumerState<HabitTrackerScreen> createState() => _HabitTrackerScreenState();
}

class _HabitTrackerScreenState extends ConsumerState<HabitTrackerScreen> {
  DateTime _selectedDate = DateTime.now();
  
  // Mock data for UI development
  final List<Map<String, dynamic>> _mockHabits = [
    {'id': '1', 'title': 'Early Rise (Brahma Muhurta)', 'category': 'brahmacharya', 'completed': true},
    {'id': '2', 'title': 'Meditation (Dhyana)', 'category': 'dhyana', 'completed': false},
    {'id': '3', 'title': 'Scripture Reading (Svadhyaya)', 'category': 'svadhyaya', 'completed': false},
  ];

  @override
  Widget build(BuildContext context) {
    // Week generator
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final weekDays = List.generate(7, (index) => startOfWeek.add(Duration(days: index)));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Dinacharya'),
        backgroundColor: AppTheme.primaryOrange,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
        ],
      ),
      body: Column(
        children: [
          // Weekly Calendar Strip
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: weekDays.map((date) {
                final isSelected = date.day == _selectedDate.day && date.month == _selectedDate.month;
                final isToday = date.day == now.day && date.month == now.month;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                  child: Column(
                    children: [
                      Text(
                        DateFormat('E').format(date)[0],
                        style: TextStyle(
                          color: isSelected ? AppTheme.primaryOrange : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryOrange : (isToday ? Colors.grey[200] : Colors.transparent),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          date.day.toString(),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          
          const Divider(),

          // Habits List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _mockHabits.length,
              itemBuilder: (context, index) {
                final habit = _mockHabits[index];
                return _buildHabitCard(habit);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
           // Show add habit dialog
        },
        backgroundColor: AppTheme.primaryOrange,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHabitCard(Map<String, dynamic> habit) {
    bool isCompleted = habit['completed'];
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.yellowPrimary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(_getIconForCategory(habit['category']), color: AppTheme.primaryOrange),
        ),
        title: Text(
          habit['title'],
          style: TextStyle(
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted ? Colors.grey : Colors.black,
          ),
        ),
        trailing: Checkbox(
          value: isCompleted,
          activeColor: AppTheme.primaryOrange,
          onChanged: (val) {
            setState(() {
              habit['completed'] = val;
            });
          },
        ),
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'brahmacharya': return Icons.wb_sunny;
      case 'dhyana': return Icons.self_improvement;
      case 'svadhyaya': return Icons.menu_book;
      default: return Icons.check_circle_outline;
    }
  }
}
