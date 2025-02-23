// File: lib/pages/Category/Tools/DailyReminder/reminder_modal.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nex_planner/model/reminder.dart';
import '../../../../provider/reminder_provider.dart';

class ReminderModal extends StatefulWidget {
  final Function onAddReminder;
  final Function onAddReminderCallback;

  const ReminderModal({
    super.key,
    required this.onAddReminder,
    required this.onAddReminderCallback,
  });

  @override
  _ReminderModalState createState() => _ReminderModalState();
}

class _ReminderModalState extends State<ReminderModal> {
  final TextEditingController _noteController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _remindMe = false;
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        backgroundColor: Colors.white,
        title: Text(
          'Add Reminder',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: 'Note',
                labelStyle: TextStyle(
                  color: Colors.grey[700],
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 15.0),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _selectedDate == null
                          ? 'No date chosen!'
                          : 'Picked Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: _presentDatePicker,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: BorderSide(color: Theme.of(context).primaryColor),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: const Text(
                    'Choose Date',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15.0),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _selectedTime == null
                          ? 'No time chosen!'
                          : 'Picked Time: ${_selectedTime!.format(context)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: _presentTimePicker,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: BorderSide(color: Theme.of(context).primaryColor),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: const Text(
                    'Choose Time',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15.0),
            Row(
              children: [
                const Text('Remind Me', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 10),
                Switch(
                  value: _remindMe,
                  onChanged: (value) {
                    setState(() {
                      _remindMe = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 15.0),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Select Category',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            _buildCategoryOption('Assignment'),
            _buildCategoryOption('Exam'),
            _buildCategoryOption('Study'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 16),
            ),
          ),
          TextButton(
            onPressed: () {
              if (_noteController.text.isNotEmpty &&
                  _selectedDate != null &&
                  _selectedTime != null) {
                final newReminder = Reminder(
                  title: _noteController.text,
                  date: DateTime(
                    _selectedDate!.year,
                    _selectedDate!.month,
                    _selectedDate!.day,
                    _selectedTime!.hour,
                    _selectedTime!.minute,
                  ),
                  category: _selectedCategory ?? 'Uncategorized',
                  remindMe: _remindMe,
                );
                final reminderProvider = Provider.of<ReminderProvider>(context, listen: false);
                reminderProvider.addReminder(newReminder);
                widget.onAddReminder();
                widget.onAddReminderCallback();
                Navigator.pop(context);
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text(
              'Add',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryOption(String category) {
    return Row(
      children: [
        Radio<String>(
          value: category,
          groupValue: _selectedCategory,
          onChanged: (value) {
            setState(() {
              _selectedCategory = value!;
            });
          },
        ),
        Text(category, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  void _presentDatePicker() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _presentTimePicker() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }
}