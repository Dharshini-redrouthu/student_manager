import 'package:flutter/material.dart';
import '../models/student.dart';
import '../services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _gradeController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Student')),
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
              buildTextField(_phoneController, 'Phone', false),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('Add Student'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final student = Student(
                      id: '',
                      name: _nameController.text,
                      age: int.parse(_ageController.text),
                      grade: _gradeController.text,
                      email: _emailController.text,
                      phone: _phoneController.text,
                      createdAt: Timestamp.now(), // 🔹 Add timestamp here
                    );
                    await _firestoreService.addStudent(student);
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

  Widget buildTextField(TextEditingController controller, String label, bool isNumber) {
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
