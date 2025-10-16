import 'package:flutter/material.dart';
import '../models/student.dart';
import '../services/firestore_service.dart';

class EditStudentScreen extends StatefulWidget {
  final Student student;
  const EditStudentScreen({required this.student, super.key});

  @override
  State<EditStudentScreen> createState() => _EditStudentScreenState();
}

class _EditStudentScreenState extends State<EditStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _gradeController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  final FirestoreService _firestoreService = FirestoreService();

  String _selectedCountry = 'India';
  String _countryCode = '+91';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.student.name);
    _ageController = TextEditingController(text: widget.student.age.toString());
    _gradeController = TextEditingController(text: widget.student.grade);
    _emailController = TextEditingController(text: widget.student.email);

    // Parse country code if exists
    final phone = widget.student.phone;
    if (phone.startsWith('+1')) {
      _selectedCountry = 'USA';
      _countryCode = '+1';
      _phoneController = TextEditingController(text: phone.replaceAll('+1 ', ''));
    } else {
      _selectedCountry = 'India';
      _countryCode = '+91';
      _phoneController = TextEditingController(text: phone.replaceAll('+91 ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Student')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              buildTextField(_nameController, 'Name', false),
              buildTextField(_ageController, 'Age', true),
              buildTextField(_gradeController, 'Grade', false),
              buildTextField(_emailController, 'Email', false),
              const SizedBox(height: 10),

              // Country and phone field row
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _selectedCountry,
                      decoration: const InputDecoration(
                        labelText: 'Country',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'India', child: Text('🇮🇳 India (+91)')),
                        DropdownMenuItem(
                            value: 'USA', child: Text('🇺🇸 USA (+1)')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCountry = value!;
                          _countryCode = value == 'India' ? '+91' : '+1';
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone ($_countryCode)',
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Phone number is required';
                        } else if (value.length != 10) {
                          return 'Enter exactly 10 digits';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Update Button
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Update Student'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final updatedStudent = Student(
                      id: widget.student.id,
                      name: _nameController.text.trim(),
                      age: int.parse(_ageController.text),
                      grade: _gradeController.text.trim().toUpperCase(),
                      email: _emailController.text.trim(),
                      phone: '$_countryCode ${_phoneController.text.trim()}',
                    );

                    await _firestoreService.updateStudent(updatedStudent);
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
      TextEditingController controller, String label, bool isNumber) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label is required';
          }
          return null;
        },
      ),
    );
  }
}
