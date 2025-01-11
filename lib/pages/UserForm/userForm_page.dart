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
      await prefs.setString('userName', _nameController.text);
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text('User Form'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
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
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(_currentStep < 2 ? 'Next' : 'Submit', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      key: const ValueKey('name'),
      children: [
        Icon(Icons.person, size: 100, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 20),
        TextFormField(
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
            filled: true,
            fillColor: Colors.grey[200],
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your name';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDepartmentField() {
    return Column(
      key: const ValueKey('department'),
      children: [
        Icon(Icons.school, size: 100, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 20),
        DropdownButtonFormField<String>(
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
            filled: true,
            fillColor: Colors.grey[200],
          ),
          items: departments.map((String department) {
            return DropdownMenuItem<String>(
              value: department,
              child: Text(
                department,
                style: TextStyle(color: Colors.black, fontSize: 16),
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
        ),
      ],
    );
  }

  Widget _buildAcademicYearField() {
    return Column(
      key: const ValueKey('academicYear'),
      children: [
        Icon(Icons.calendar_today, size: 100, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 20),
        DropdownButtonFormField<String>(
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
            filled: true,
            fillColor: Colors.grey[200],
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
                style: TextStyle(color: Colors.black, fontSize: 16),
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
        ),
      ],
    );
  }
}