// dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../provider/reminder_provider.dart';
import 'reminder_modal.dart';

class DailyReminder extends StatelessWidget {
  const DailyReminder({super.key});

  @override
  Widget build(BuildContext context) {
    final reminderProvider = Provider.of<ReminderProvider>(context);
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Daily Reminders',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.sort, color: theme.primaryColor),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Sort options coming soon', style: GoogleFonts.inter()),
                behavior: SnackBarBehavior.floating,
              ));
            },
          ),
        ],
      ),
      body: reminderProvider.reminders.isEmpty
          ? _buildEmptyState(context)
          : _buildReminderTimeline(context, reminderProvider),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.primaryColor,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => ReminderModal(
              onAddReminder: reminderProvider.loadReminders,
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_outlined,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Reminders Yet',
            style: GoogleFonts.inter(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Add your first reminder to stay on track with your daily tasks',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 16, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => ReminderModal(
                  onAddReminder: Provider.of<ReminderProvider>(context, listen: false)
                      .loadReminders,
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: Text(
              'Add New Reminder',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderTimeline(BuildContext context, ReminderProvider provider) {
    final Map<String, List<int>> groupedReminders = _groupRemindersByDate(provider.reminders);
    final List<String> dates = groupedReminders.keys.toList()..sort();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Your Schedule',
              style: GoogleFonts.inter(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[800]),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              final dateStr = dates[index];
              final indices = groupedReminders[dateStr]!;
              final DateTime reminderDate =
                  Provider.of<ReminderProvider>(context, listen: false)
                      .reminders[indices.first].date;
              final labelText = _computeLabel(reminderDate);
              return _buildDateSection(context, provider, dateStr, indices, labelText);
            },
            childCount: dates.length,
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 80),
        ),
      ],
    );
  }

// dart
  Widget _buildDateSection(
      BuildContext context,
      ReminderProvider provider,
      String dateStr,
      List<int> indices,
      String labelText,
      ) {
    final theme = Theme.of(context);
    List<Widget> children = [];

    // Add date header if labelText is not "Today", "Tomorrow", and not a "Deadline Passed" message.
    if (labelText != 'Today' &&
        labelText != 'Tomorrow' &&
        !labelText.startsWith('Deadline Passed')) {
      children.add(Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child:Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            labelText,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ),
      ));
    }

    // Build reminder cards.
    children.addAll(indices.map((index) => _buildReminderCard(context, provider, index)));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

// dart
// dart
  Widget _buildReminderCard(BuildContext context, ReminderProvider provider, int index) {
    final reminder = provider.reminders[index];
    final DateFormat timeFormat = DateFormat('h:mm a');
    final bool past = reminder.date.isBefore(DateTime.now());
    final bool isToday = _isSameDate(reminder.date, DateTime.now());
    final bool isTomorrow = _isSameDate(reminder.date, DateTime.now().add(Duration(days: 1)));
    final theme = Theme.of(context);

    // Build the header tag if reminder is today or tomorrow.
    Widget headerTag = const SizedBox.shrink();
    if (isToday || isTomorrow) {
      headerTag = Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: past ? Colors.red[700] : theme.primaryColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              past
                  ? 'Deadline Passed (${timeFormat.format(reminder.date)})'
                  : (isToday ? 'Today' : 'Tomorrow'),
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          if (!past)
            const SizedBox(width: 8),
          if (!past)
            Icon(Icons.circle, size: 8, color: theme.primaryColor),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        headerTag,
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Card(
            elevation: 0,
            color: past ? Colors.grey[100] : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey[200]!, width: 1),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          timeFormat.format(reminder.date).split(' ')[0],
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: past ? Colors.grey[500] : Colors.black87,
                          ),
                        ),
                        Text(
                          timeFormat.format(reminder.date).split(' ')[1],
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: past ? Colors.grey[500] : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      width: 2,
                      height: 70,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(reminder.category).withOpacity(0.6),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  reminder.title,
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: past ? Colors.grey[600] : Colors.black87,
                                  ),
                                ),
                              ),
                              if (reminder.remindMe)
                                Icon(
                                  Icons.notifications_active_rounded,
                                  size: 16,
                                  color: theme.primaryColor,
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (reminder.category.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getCategoryColor(reminder.category).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getCategoryIcon(reminder.category),
                                    size: 14,
                                    color: _getCategoryColor(reminder.category),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    reminder.category,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: _getCategoryColor(reminder.category),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                onPressed: () {},
                                color: Colors.grey[600],
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              const SizedBox(width: 16),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18),
                                onPressed: () => _showDeleteConfirmation(context, provider, index),
                                color: Colors.red[400],
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  Map<String, List<int>> _groupRemindersByDate(List<dynamic> reminders) {
    final Map<String, List<int>> grouped = {};
    final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    for (int i = 0; i < reminders.length; i++) {
      final String key = dateFormat.format(reminders[i].date);
      if (grouped.containsKey(key)) {
        grouped[key]!.add(i);
      } else {
        grouped[key] = [i];
      }
    }
    return grouped;
  }

  void _showDeleteConfirmation(BuildContext context, ReminderProvider provider, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Reminder',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete this reminder? This action cannot be undone.',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: Colors.grey[800]),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              provider.deleteReminder(index);
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.delete_outline, size: 18),
            label: Text(
              'Delete',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return Icons.work;
      case 'personal':
        return Icons.person;
      case 'health':
        return Icons.favorite;
      case 'study':
        return Icons.school;
      case 'meeting':
        return Icons.people;
      case 'bills':
        return Icons.receipt;
      default:
        return Icons.label;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return Colors.blue[700]!;
      case 'personal':
        return Colors.purple[700]!;
      case 'health':
        return Colors.green[700]!;
      case 'study':
        return Colors.orange[700]!;
      case 'meeting':
        return Colors.teal[700]!;
      case 'bills':
        return Colors.red[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  String _computeLabel(DateTime reminderDate) {
    final now = DateTime.now();
    final tomorrow = now.add(Duration(days: 1));
    if (_isSameDate(reminderDate, now)) {
      return 'Today';
    } else if (_isSameDate(reminderDate, tomorrow)) {
      return 'Tomorrow';
    } else if (now.isAfter(reminderDate)) {
      return 'Deadline Passed (${DateFormat("h:mm a").format(reminderDate.toLocal())})';
    } else {
      return DateFormat('EEE, MMM d, yyyy').format(reminderDate.toLocal());
    }
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _deadlinePassed(DateTime reminderDate) {
    return DateTime.now().isAfter(reminderDate);
  }
}