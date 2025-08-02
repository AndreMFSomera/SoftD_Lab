import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _isLoading = false;

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
    String professorName = professorNameController.text.trim();
    final idNumber = idNumberController.text.trim();
    final professorEmail = professorEmailController.text.trim();

    if (professorName.isEmpty || idNumber.isEmpty || professorEmail.isEmpty) {
      showError('Please fill in all fields.');
      return;
    }

    // Check if full name is numeric only
    if (RegExp(r'^\d+$').hasMatch(professorName)) {
      showError('Full name cannot be only numbers.');
      return;
    }

    // Convert professor name to lowercase
    professorName = professorName.toLowerCase();

    final idRegex = RegExp(r'^\d{2}-\d{4}-\d{3}$');
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!idRegex.hasMatch(idNumber)) {
      showError('ID number must be in the format xx-xxxx-xxx.');
      return;
    }

    if (!emailRegex.hasMatch(professorEmail)) {
      showError('Please enter a valid email address.');
      return;
    }

    final duplicate = instructors.any(
      (instructor) =>
          instructor['professor_name'].toString().toLowerCase() ==
              professorName ||
          instructor['id_number'].toString() == idNumber ||
          instructor['professor_email'].toString().toLowerCase() ==
              professorEmail.toLowerCase(),
    );

    if (duplicate) {
      showError(
        'Instructor already exists (name, ID, or email is already used).',
      );
      return;
    }

    setState(() => _isLoading = true);

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

      setState(() => _isLoading = false);

      if (response.statusCode == 201) {
        showSuccess('Instructor added successfully.');
        clearFields();
        fetchInstructors();
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Unknown error';
        showError('Add failed: $error');
      }
    } catch (e) {
      setState(() => _isLoading = false);
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
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
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

  InputDecoration themedInput(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.green),
      filled: true,
      fillColor: Colors.green.shade50,
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.green),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.green, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Instructor'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: professorNameController,
              decoration: themedInput('Professor Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: idNumberController,
              decoration: themedInput('ID Number (xx-xxxx-xxx)'),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(9),
                _CustomIdFormatter(),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: professorEmailController,
              decoration: themedInput('Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : addInstructor,
                icon: const Icon(Icons.person_add),
                label: Text(_isLoading ? 'Adding...' : 'Add Instructor'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Instructors',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: instructors.length,
                itemBuilder: (context, index) {
                  final instructor = instructors[index];
                  return Card(
                    color: Colors.green.shade50,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.person, color: Colors.green),
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

// Formatter for ID: xx-xxxx-xxx
class _CustomIdFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      if (i == 1 || i == 5) buffer.write('-');
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
