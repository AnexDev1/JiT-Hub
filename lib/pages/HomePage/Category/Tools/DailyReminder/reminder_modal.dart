import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nex_planner/model/reminder.dart';
import '../../../../../provider/reminder_provider.dart';

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

  // Category icons and colors mapping with academic focus
  final Map<String, IconData> _categoryIcons = {
    'Assignment': Icons.assignment_outlined,
    'Exam': Icons.quiz_outlined,
    'Study': Icons.menu_book_outlined,
    'Lab Work': Icons.science_outlined,
    'Project': Icons.engineering_outlined,
    'Lecture': Icons.school_outlined,
    'Meeting': Icons.groups_outlined,
  };

  final Map<String, Color> _categoryColors = {
    'Assignment': Color(0xFF1565C0),
    'Exam': Color(0xFFC62828),
    'Study': Color(0xFF2E7D32),
    'Lab Work': Color(0xFF6A1B9A),
    'Project': Color(0xFFE65100),
    'Lecture': Color(0xFF00695C),
    'Meeting': Color(0xFF4527A0),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 10,
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleField(),
                  const SizedBox(height: 20),
                  _buildDescriptionField(),
                  const SizedBox(height: 24),
                  _buildCategorySection(),
                  const SizedBox(height: 24),
                  _buildDateTimeSection(),
                  const SizedBox(height: 24),
                  _buildReminderToggle(),
                  const SizedBox(height: 32),
                  _buildActionButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final Color headerColor = _isEditing
        ? _categoryColors[_selectedCategory]!
        : Theme.of(context).primaryColor;

    return Container(
      decoration: BoxDecoration(
        color: headerColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _isEditing ? Icons.edit_note : Icons.note_add_outlined,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                _isEditing ? 'Edit Reminder' : 'New Reminder',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _isEditing
                ? 'Update the details of your academic task'
                : 'Keep track of your important academic deadlines',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white.withValues(alpha:0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormLabel('Title', Icons.title_outlined),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: 'e.g., Complete Physics Problem Set',
            errorText: _titleError,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            prefixIcon: const Icon(Icons.edit_outlined),
          ),
          style: GoogleFonts.inter(),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormLabel('Description', Icons.description_outlined),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Additional details about this task...',
            contentPadding: const EdgeInsets.all(16),
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
          style: GoogleFonts.inter(),
        ),
      ],
    );
  }

  Widget _buildFormLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormLabel('Category', Icons.category_outlined),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[50],
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: _categoryIcons.keys
                  .map((category) => _buildCategoryCard(category))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

// Modified _buildReminderToggle
  Widget _buildReminderToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: _remindMe
            ? Theme.of(context).primaryColor.withValues(alpha:0.08)
            : Colors.grey[50],
        border: Border.all(
          color: _remindMe
              ? Theme.of(context).primaryColor.withValues(alpha:0.5)
              : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _remindMe
                  ? Theme.of(context).primaryColor.withValues(alpha:0.15)
                  : Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _remindMe
                  ? Icons.notifications_active_outlined
                  : Icons.notifications_off_outlined,
              size: 22,
              color: _remindMe ? Theme.of(context).primaryColor : Colors.grey[600],
            ),
          ),
          const SizedBox(width: 12),
          // Wrap the text with Expanded to allow proper spacing and add overflow settings
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notification',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _remindMe ? 'You will be notified' : 'No notification',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
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

  Widget _buildCategoryCard(String category) {
    final bool isSelected = _selectedCategory == category;
    final Color categoryColor = _categoryColors[category]!;

    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedCategory = category;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 92,
          decoration: BoxDecoration(
            color: isSelected ? categoryColor.withValues(alpha:0.15) : Colors.white,
            border: Border.all(
              color: isSelected ? categoryColor : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: categoryColor.withValues(alpha:0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ]
                : null,
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected ? categoryColor.withValues(alpha:0.2) : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _categoryIcons[category]!,
                  color: isSelected ? categoryColor : Colors.grey[600],
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                category,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? categoryColor : Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormLabel('Schedule', Icons.calendar_today_outlined),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDateSelector(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTimeSelector(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    final bool hasDate = _selectedDate != null;
    final formattedDate = hasDate
        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
        : 'Select Date';

    return InkWell(
      onTap: _presentDatePicker,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(
            color: hasDate ? Theme.of(context).primaryColor : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(12),
          color: hasDate ? Theme.of(context).primaryColor.withValues(alpha:0.05) : Colors.grey[50],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: hasDate
                    ? Theme.of(context).primaryColor.withValues(alpha:0.15)
                    : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_outlined,
                color: hasDate ? Theme.of(context).primaryColor : Colors.grey[600],
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                formattedDate,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: hasDate ? FontWeight.w500 : FontWeight.normal,
                  color: hasDate ? Colors.black : Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector() {
    final bool hasTime = _selectedTime != null;
    final formattedTime = hasTime ? _selectedTime!.format(context) : 'Select Time';

    return InkWell(
      onTap: _presentTimePicker,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(
            color: hasTime ? Theme.of(context).primaryColor : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(12),
          color: hasTime ? Theme.of(context).primaryColor.withValues(alpha:0.05) : Colors.grey[50],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: hasTime
                    ? Theme.of(context).primaryColor.withValues(alpha:0.15)
                    : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.access_time_outlined,
                color: hasTime ? Theme.of(context).primaryColor : Colors.grey[600],
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                formattedTime,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: hasTime ? FontWeight.w500 : FontWeight.normal,
                  color: hasTime ? Colors.black : Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Text(
              'CANCEL',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: _categoryColors[_selectedCategory],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSubmitting
                ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : Text(
              _isEditing ? 'UPDATE REMINDER' : 'SAVE REMINDER',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
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
            colorScheme: ColorScheme.light(primary: _categoryColors[_selectedCategory]!),
            dialogBackgroundColor: Colors.white,
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
            colorScheme: ColorScheme.light(primary: _categoryColors[_selectedCategory]!),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
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
        SnackBar(
          content: Text(
            'Please select a date',
            style: GoogleFonts.inter(),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a time',
            style: GoogleFonts.inter(),
          ),
          behavior: SnackBarBehavior.floating,
        ),
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