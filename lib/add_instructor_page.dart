import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddInstructorPage extends StatefulWidget {
  const AddInstructorPage({super.key});

  @override
  State<AddInstructorPage> createState() => _AddInstructorPageState();
}

class _AddInstructorPageState extends State<AddInstructorPage> {
  final TextEditingController professorNameController = TextEditingController();
  final TextEditingController idNumberController = TextEditingController();
  final TextEditingController professorEmailController =
      TextEditingController();

  List<dynamic> instructors = [];

  @override
  void initState() {
    super.initState();
    fetchInstructors();
  }

  Future<void> fetchInstructors() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/get_instructors'),
      );
      if (response.statusCode == 200) {
        setState(() {
          instructors = json.decode(response.body);
        });
      } else {
        showError('Failed to load instructors.');
      }
    } catch (e) {
      showError('Error: $e');
    }
  }

  Future<void> addInstructor() async {
    final professorName = professorNameController.text.trim();
    final idNumber = idNumberController.text.trim();
    final professorEmail = professorEmailController.text.trim();

    if (professorName.isEmpty || idNumber.isEmpty || professorEmail.isEmpty) {
      showError('Please fill in all fields.');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/add_instructor'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'professor_name': professorName,
          'id_number': idNumber,
          'professor_email': professorEmail,
        }),
      );

      if (response.statusCode == 201) {
        showSuccess('Instructor added successfully.');
        clearFields();
        fetchInstructors();
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Unknown error';
        showError('Add failed: $error');
      }
    } catch (e) {
      showError('Error: $e');
    }
  }

  Future<void> deleteInstructor(String idNumber) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this instructor?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await http.delete(
        Uri.parse('http://localhost:5000/delete_instructor/$idNumber'),
      );

      if (response.statusCode == 200) {
        showSuccess('Instructor deleted.');
        fetchInstructors();
      } else {
        showError('Delete failed.');
      }
    } catch (e) {
      showError('Error: $e');
    }
  }

  void clearFields() {
    professorNameController.clear();
    idNumberController.clear();
    professorEmailController.clear();
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Instructor'),
        backgroundColor: Colors.brown,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: professorNameController,
              decoration: const InputDecoration(labelText: 'Professor Name'),
            ),
            TextField(
              controller: idNumberController,
              decoration: const InputDecoration(labelText: 'ID Number'),
            ),
            TextField(
              controller: professorEmailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: addInstructor,
              child: const Text('Add Instructor'),
            ),
            const Divider(height: 32),
            const Text(
              'Instructors:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: instructors.length,
                itemBuilder: (context, index) {
                  final instructor = instructors[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(instructor['professor_name']),
                      subtitle: Text(
                        '${instructor['id_number']} • ${instructor['professor_email']}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            deleteInstructor(instructor['id_number']),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
