import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';
import '../services/auth_service.dart';
import 'edit_student_screen.dart';
import 'add_student_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CollectionReference _studentsRef =
      FirebaseFirestore.instance.collection('students');

  String _selectedGradeFilter = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  Color _getGradeColor(String grade) {
    switch (grade.toUpperCase()) {
      case 'A':
        return Colors.green.shade200;
      case 'B':
        return Colors.blue.shade200;
      case 'C':
        return Colors.orange.shade200;
      default:
        return Colors.red.shade200;
    }
  }

  Future<void> _confirmDelete(
      BuildContext context, String studentId, String name) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _studentsRef.doc(studentId).delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted "$name" successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Logout — Provider-based AuthWrapper will redirect automatically
              await AuthService().signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Total Students
            StreamBuilder<QuerySnapshot>(
              stream: _studentsRef.snapshots(),
              builder: (context, snapshot) {
                int total = snapshot.hasData ? snapshot.data!.docs.length : 0;
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Total Students: $total',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),

            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
            ),
            const SizedBox(height: 10),

            // Grade Filter Dropdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter by Grade:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                DropdownButton<String>(
                  value: _selectedGradeFilter,
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All')),
                    DropdownMenuItem(value: 'A', child: Text('A')),
                    DropdownMenuItem(value: 'B', child: Text('B')),
                    DropdownMenuItem(value: 'C', child: Text('C')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedGradeFilter = value!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Student List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _studentsRef.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No students found'));
                  }

                  var students = snapshot.data!.docs
                      .map((doc) => Student.fromMap(
                          doc.data() as Map<String, dynamic>, doc.id))
                      .toList();

                  // Apply grade filter
                  if (_selectedGradeFilter != 'All') {
                    students = students
                        .where((s) =>
                            s.grade.toUpperCase() ==
                            _selectedGradeFilter.toUpperCase())
                        .toList();
                  }

                  // Apply search filter
                  if (_searchQuery.isNotEmpty) {
                    students = students
                        .where((s) =>
                            s.name.toLowerCase().contains(_searchQuery) ||
                            s.email.toLowerCase().contains(_searchQuery))
                        .toList();
                  }

                  // Sort by createdAt (oldest first)
                  students.sort((a, b) {
                    if (a.createdAt == null && b.createdAt == null) return 0;
                    if (a.createdAt == null) return -1;
                    if (b.createdAt == null) return 1;
                    return a.createdAt!.compareTo(b.createdAt!);
                  });

                  if (students.isEmpty) {
                    return const Center(
                      child: Text('No matching students found'),
                    );
                  }

                  return ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final s = students[index];
                      return Card(
                        color: _getGradeColor(s.grade),
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text('${s.name} (${s.grade})'),
                          subtitle: Text(
                              'Age: ${s.age}\nEmail: ${s.email}\nPhone: ${s.phone}'),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          EditStudentScreen(student: s),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () =>
                                    _confirmDelete(context, s.id, s.name),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // Add Student Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddStudentScreen()),
          );
        },
        label: const Text('Add Student'),
        icon: const Icon(Icons.person_add),
      ),
    );
  }
}
