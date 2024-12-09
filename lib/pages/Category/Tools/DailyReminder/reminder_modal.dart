import 'package:flutter/material.dart';

class AddReminderModal extends StatefulWidget {
  final Function(Map<String, dynamic>) onAddReminder;

  const AddReminderModal({super.key, required this.onAddReminder});

  @override
  _AddReminderModalState createState() => _AddReminderModalState();
}

class _AddReminderModalState extends State<AddReminderModal> {
  final TextEditingController _noteController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _remindMe = false;
  String _selectedCategory = 'Assignment';

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Add Reminder',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: 'Type the note here',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  _selectedDate != null
                      ? 'Date: ${_selectedDate!.toLocal()}'.split(' ')[1]
                      : 'No date selected',
                  style: const TextStyle(color: Colors.black),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () => _selectDate(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  _selectedTime != null
                      ? 'Time: ${_selectedTime!.format(context)}'
                      : 'No time selected',
                ),
              ),
              IconButton(
                icon: const Icon(Icons.access_time),
                onPressed: () => _selectTime(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Remind me'),
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
          const SizedBox(height: 16),
          const Text('Select Category'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCategoryOption('Assignment'),
              _buildCategoryOption('Exam'),
              _buildCategoryOption('Other'),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
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
}
