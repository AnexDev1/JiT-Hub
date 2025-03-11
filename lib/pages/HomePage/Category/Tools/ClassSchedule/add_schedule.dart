import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddSchedulePage extends StatefulWidget {
  final Function(String, String, String) onAddSchedule;

  const AddSchedulePage({super.key, required this.onAddSchedule});

  @override
  _AddSchedulePageState createState() => _AddSchedulePageState();
}

class _AddSchedulePageState extends State<AddSchedulePage> {
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  TimeOfDay? _selectedTime;
  bool _courseError = false;
  bool _roomError = false;
  bool _timeError = false;

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _timeError = false;
      });
    }
  }

  void _validateAndSubmit() {
    setState(() {
      _courseError = _courseController.text.isEmpty;
      _roomError = _roomController.text.isEmpty;
      _timeError = _selectedTime == null;
    });

    if (!_courseError && !_roomError && !_timeError) {
      widget.onAddSchedule(
        _selectedTime!.format(context),
        _courseController.text,
        _roomController.text,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Add Class',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'New Class Details',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter the information for your class schedule',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Course name field
                  _buildInputLabel('Course Name', Icons.class_outlined),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _courseController,
                    hintText: 'Enter course name',
                    error: _courseError,
                    errorText: 'Please enter a course name',
                    onChanged: (value) {
                      if (value.isNotEmpty && _courseError) {
                        setState(() => _courseError = false);
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  // Room field
                  _buildInputLabel('Room Number', Icons.meeting_room_outlined),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _roomController,
                    hintText: 'Enter room number',
                    error: _roomError,
                    errorText: 'Please enter a room number',
                    onChanged: (value) {
                      if (value.isNotEmpty && _roomError) {
                        setState(() => _roomError = false);
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  // Time selection
                  _buildInputLabel('Class Time', Icons.access_time),
                  const SizedBox(height: 8),
                  _buildTimeSelector(),
                  if (_timeError)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Please select a time',
                        style: GoogleFonts.inter(
                          color: Colors.red[700],
                          fontSize: 12,
                        ),
                      ),
                    ),

                  const SizedBox(height: 40),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _validateAndSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        'ADD TO SCHEDULE',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label, IconData icon) {
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
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required bool error,
    required String errorText,
    required Function(String) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (!error)
            BoxShadow(
              color: Colors.grey.withValues(alpha:0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        style: GoogleFonts.inter(),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.inter(color: Colors.grey),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          errorText: error ? errorText : null,
          errorStyle: GoogleFonts.inter(fontSize: 12),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: error ? Colors.red : Colors.grey[200]!,
              width: error ? 1.5 : 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSelector() {
    return GestureDetector(
      onTap: () => _selectTime(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _timeError ? Colors.red : Colors.grey[200]!,
            width: _timeError ? 1.5 : 1,
          ),
          boxShadow: [
            if (!_timeError)
              BoxShadow(
                color: Colors.grey.withValues(alpha:0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _selectedTime != null
                    ? _selectedTime!.format(context)
                    : 'Select a time',
                style: GoogleFonts.inter(
                  color: _selectedTime != null ? Colors.black87 : Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.access_time,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}