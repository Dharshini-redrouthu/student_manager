import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';

class FirestoreService {
  final CollectionReference _studentsCollection =
      FirebaseFirestore.instance.collection('students');

  // 🔹 Stream to fetch students (for real-time updates)
  Stream<List<Student>> getStudents() {
    return _studentsCollection.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Student.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  // ✅ UPDATED: Add student with createdAt timestamp
  Future<void> addStudent(Student student) async {
    await _studentsCollection.add({
      'name': student.name,
      'age': student.age,
      'grade': student.grade,
      'email': student.email,
      'phone': student.phone,
      'createdAt': FieldValue.serverTimestamp(), // 🔹 Added this
    });
  }

  // 🔹 Update existing student
  Future<void> updateStudent(Student student) async {
    await _studentsCollection.doc(student.id).update(student.toMap());
  }

  // 🔹 Delete student by ID
  Future<void> deleteStudent(String id) async {
    await _studentsCollection.doc(id).delete();
  }
}
