import 'package:flutter/material.dart';

class ReminderModal extends StatefulWidget {
  final Function onAddReminder;
  final Function onAddReminderCallback;

  ReminderModal(
      {required this.onAddReminder, required this.onAddReminderCallback});

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
        title: const Text('Add Reminder'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: 'Note'),
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDate == null
                        ? 'No date chosen!'
                        : 'Picked Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
                  ),
                ),
                TextButton(
                  onPressed: _presentDatePicker,
                  child: const Text('Choose Date'),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedTime == null
                        ? 'No time chosen!'
                        : 'Picked Time: ${_selectedTime!.format(context)}',
                  ),
                ),
                TextButton(
                  onPressed: _presentTimePicker,
                  child: const Text('Choose Time'),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Text('Remind Me'),
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
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_noteController.text.isNotEmpty &&
                  _selectedDate != null &&
                  _selectedTime != null) {
                widget.onAddReminder({
                  'note': _noteController.text,
                  'date': _selectedDate!.toLocal().toString().split(' ')[0],
                  'time': _selectedTime!.format(context),
                  'remindMe': _remindMe,
                  'category': _selectedCategory,
                });
                Navigator.pop(context);
                // widget.onAddReminderCallback(); // Call the callback function
              }
            },
            child: const Text('Add'),
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
        Text(category),
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
