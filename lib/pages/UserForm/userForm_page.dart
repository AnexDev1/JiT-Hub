import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nex_planner/data/department_data.dart';

class UserFormPage extends StatefulWidget {
  @override
  _UserFormPageState createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _selectedDepartment;
  String? _selectedAcademicYear;
  int _currentStep = 0;

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFormFilled', true);
      // Save other user information if needed
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _nextStep() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _currentStep++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
                child: _currentStep == 0
                    ? _buildNameField()
                    : _currentStep == 1
                    ? _buildDepartmentField()
                    : _buildAcademicYearField(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _currentStep < 2 ? _nextStep : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(_currentStep < 2 ? 'Next' : 'Submit', style: TextStyle(color: Colors.white),),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      key: const ValueKey('name'),
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Name',
        labelStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your name';
        }
        return null;
      },
    );
  }

  Widget _buildDepartmentField() {
    return DropdownButtonFormField<String>(
      key: const ValueKey('department'),
      value: _selectedDepartment,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Department',
        labelStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
        ),
      ),
      items: departments.map((String department) {
        return DropdownMenuItem<String>(
          value: department,
          child: Text(
            department,
            style: TextStyle(color: Colors.blue, fontSize: 16),
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedDepartment = newValue;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select your department';
        }
        return null;
      },
    );
  }

  Widget _buildAcademicYearField() {
    return DropdownButtonFormField<String>(
      key: const ValueKey('academicYear'),
      value: _selectedAcademicYear,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Academic Year',
        labelStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
        ),
      ),
      items: [
        'Freshman',
        'Second Year',
        'Third Year',
        'Fourth Year',
        'Fifth Year (GC)'
      ].map((String year) {
        return DropdownMenuItem<String>(
          value: year,
          child: Text(
            year,
            style: TextStyle(color: Colors.blue, fontSize: 16),
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedAcademicYear = newValue;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select your academic year';
        }
        return null;
      },
    );
  }
}