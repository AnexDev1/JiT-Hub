import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nex_planner/model/reminder.dart';
import '../../../../provider/reminder_provider.dart';

class ReminderModal extends StatefulWidget {
  final Function onAddReminder;
  final Reminder? reminderToEdit;

  const ReminderModal({
    Key? key,
    required this.onAddReminder,
    this.reminderToEdit,
  }) : super(key: key);

  @override
  State<ReminderModal> createState() => _ReminderModalState();
}

class _ReminderModalState extends State<ReminderModal> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _remindMe = true;
  String _selectedCategory = 'Assignment';
  bool _isSubmitting = false;
  String? _titleError;
  bool _isEditing = false;

  // Category icons and colors mapping
  final Map<String, IconData> _categoryIcons = {
    'Assignment': Icons.assignment,
    'Exam': Icons.quiz,
    'Study': Icons.menu_book,
    'Lab Work': Icons.science,
    'Project': Icons.engineering,
  };

  final Map<String, Color> _categoryColors = {
    'Assignment': Colors.blue,
    'Exam': Colors.red,
    'Study': Colors.green,
    'Lab Work': Colors.purple,
    'Project': Colors.orange,
  };

  @override
  void initState() {
    super.initState();
    _isEditing = widget.reminderToEdit != null;

    if (_isEditing) {
      final reminder = widget.reminderToEdit!;
      _titleController.text = reminder.title;
      _descriptionController.text = reminder.description;
      _selectedCategory = reminder.category;
      _remindMe = reminder.remindMe;
      _selectedDate = reminder.date;
      _selectedTime = TimeOfDay(
        hour: reminder.date.hour,
        minute: reminder.date.minute,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Text(
                  _isEditing ? 'Edit Academic Reminder' : 'Create Academic Reminder',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Center(
                child: Text(
                  'Plan your academic tasks efficiently',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
              const SizedBox(height: 25),

              // Title Field
              Text(
                'Title',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'e.g., Submit Math Assignment',
                  errorText: _titleError,
                  prefixIcon: const Icon(Icons.title),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Description Field
              Text(
                'Description (Optional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Add details about this task...',
                  prefixIcon: const Icon(Icons.description),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Category Selection
              Text(
                'Category',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 80,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _categoryIcons.keys.map((category) =>
                      _buildCategoryCard(category)
                  ).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Date and Time Row
              Row(
                children: [
                  Expanded(
                    child: _buildDateSelector(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTimeSelector(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Reminder toggle
              _buildReminderToggle(),
              const SizedBox(height: 30),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Text('Cancel', style: TextStyle(color: Colors.grey[800])),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Text(
                      _isEditing ? 'Update Reminder' : 'Add Reminder',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String category) {
    final bool isSelected = _selectedCategory == category;
    final Color categoryColor = _categoryColors[category] ?? Colors.blue;

    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedCategory = category;
          });
        },
        child: Container(
          width: 100,
          decoration: BoxDecoration(
            color: isSelected ? categoryColor.withOpacity(0.15) : Colors.grey[50],
            border: Border.all(
              color: isSelected ? categoryColor : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _categoryIcons[category] ?? Icons.folder,
                color: isSelected ? categoryColor : Colors.grey[600],
                size: 28,
              ),
              const SizedBox(height: 5),
              Text(
                category,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? categoryColor : Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _presentDatePicker,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[50],
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  _selectedDate == null
                      ? 'Select Date'
                      : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                  style: TextStyle(
                    fontSize: 15,
                    color: _selectedDate == null ? Colors.grey[600] : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Time',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _presentTimePicker,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[50],
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  _selectedTime == null
                      ? 'Select Time'
                      : _selectedTime!.format(context),
                  style: TextStyle(
                    fontSize: 15,
                    color: _selectedTime == null ? Colors.grey[600] : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReminderToggle() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(
            Icons.notifications_active,
            color: _remindMe ? Theme.of(context).primaryColor : Colors.grey,
          ),
          const SizedBox(width: 10),
          Text(
            'Remind me',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
          const Spacer(),
          Switch(
            value: _remindMe,
            activeColor: Theme.of(context).primaryColor,
            onChanged: (value) {
              setState(() {
                _remindMe = value;
              });
            },
          ),
        ],
      ),
    );
  }

  void _presentDatePicker() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: Theme.of(context).primaryColor),
          ),
          child: child!,
        );
      },
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
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: Theme.of(context).primaryColor),
          ),
          child: child!,
        );
      },
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  void _submitForm() {
    // Validate inputs
    if (_titleController.text.isEmpty) {
      setState(() {
        _titleError = 'Please enter a title';
      });
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
      return;
    }

    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _titleError = null;
    });

    // Create date with time
    final reminderDate = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final reminderProvider = Provider.of<ReminderProvider>(context, listen: false);

    if (_isEditing && widget.reminderToEdit != null) {
      // Update existing reminder
      final updatedReminder = Reminder(
        uuid: widget.reminderToEdit!.uuid,
        title: _titleController.text,
        category: _selectedCategory,
        date: reminderDate,
        remindMe: _remindMe,
        description: _descriptionController.text,
        isDone: widget.reminderToEdit!.isDone,
      );
      reminderProvider.updateReminder(updatedReminder as int, updatedReminder);
    } else {
      // Create new reminder
      final newReminder = Reminder(
        title: _titleController.text,
        category: _selectedCategory,
        date: reminderDate,
        remindMe: _remindMe,
        description: _descriptionController.text,
      );
      reminderProvider.addReminder(newReminder);
    }

    widget.onAddReminder();
    Navigator.pop(context);
  }
}