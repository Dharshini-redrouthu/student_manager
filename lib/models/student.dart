import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  String id;
  String name;
  int age;
  String grade;
  String email;
  String phone;
  Timestamp? createdAt; // optional

  Student({
    required this.id,
    required this.name,
    required this.age,
    required this.grade,
    required this.email,
    required this.phone,
    this.createdAt,
  });

  factory Student.fromMap(Map<String, dynamic> data, String documentId) {
    return Student(
      id: documentId,
      name: data['name'] ?? '',
      age: data['age'] ?? 0,
      grade: data['grade'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      createdAt: data['createdAt'], // ⚠ optional
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'grade': grade,
      'email': email,
      'phone': phone,
    };
  }
}
