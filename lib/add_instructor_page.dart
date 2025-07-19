import 'package:flutter/material.dart';

class AddInstructorPage extends StatefulWidget {
  const AddInstructorPage({super.key});

  @override
  State<AddInstructorPage> createState() => _AddInstructorPageState();
}

class _AddInstructorPageState extends State<AddInstructorPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final idController = TextEditingController();
  final emailController = TextEditingController();
  final departmentController = TextEditingController();
  final designationController = TextEditingController();
  final contactController = TextEditingController();

  // Store all instructors
  final List<Map<String, String>> _instructors = [];

  void _saveInstructor() {
    if (_formKey.currentState!.validate()) {
      // Add new instructor to the list
      _instructors.add({
        "name": nameController.text,
        "id": idController.text,
        "email": emailController.text,
        "department": departmentController.text,
        "designation": designationController.text,
        "contact": contactController.text,
      });

      // Clear form
      nameController.clear();
      idController.clear();
      emailController.clear();
      departmentController.clear();
      designationController.clear();
      contactController.clear();

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Instructor saved successfully!")),
      );
    }
  }

  void _removeInstructor(int index) {
    setState(() {
      _instructors.removeAt(index);
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Instructor removed.")));
  }

  InputDecoration _inputDecoration(String label) =>
      InputDecoration(labelText: label, border: const OutlineInputBorder());

  Widget _buildInstructorTable() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green.shade100),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[50],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor:
              MaterialStateColor.resolveWith((states) => Colors.green.shade100),
          columns: const [
            DataColumn(label: Text("Full Name")),
            DataColumn(label: Text("ID Number")),
            DataColumn(label: Text("School Email")),
            DataColumn(label: Text("Department")),
            DataColumn(label: Text("Designation")),
            DataColumn(label: Text("Contact Number")),
            DataColumn(label: Text("Actions")),
          ],
          rows: List.generate(_instructors.length, (index) {
            final instructor = _instructors[index];
            return DataRow(
              cells: [
                DataCell(Text(instructor['name']!)),
                DataCell(Text(instructor['id']!)),
                DataCell(Text(instructor['email']!)),
                DataCell(Text(instructor['department']!)),
                DataCell(Text(instructor['designation']!)),
                DataCell(Text(instructor['contact']!)),
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: "Remove",
                    onPressed: () => _removeInstructor(index),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Instructors"),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: Form
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.green.shade100),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: _inputDecoration("Full Name"),
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: idController,
                        decoration: _inputDecoration("ID Number"),
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: emailController,
                        decoration: _inputDecoration("School Email Address"),
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Required';
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(val)) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: departmentController,
                        decoration: _inputDecoration("Department"),
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: designationController,
                        decoration: _inputDecoration("Designation/Position"),
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: contactController,
                        decoration: _inputDecoration("Contact Number"),
                        keyboardType: TextInputType.phone,
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 300,
                        child: ElevatedButton(
                          onPressed: _saveInstructor,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text("Save Instructor"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 30),

            // Right: Table
            Expanded(
              flex: 2,
              child: _instructors.isEmpty
                  ? const Center(child: Text("No instructors added yet."))
                  : _buildInstructorTable(),
            ),
          ],
        ),
      ),
    );
  }
}
