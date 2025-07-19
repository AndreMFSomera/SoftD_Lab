import 'package:flutter/material.dart';

class CheckerDashboard extends StatefulWidget {
  const CheckerDashboard({super.key});

  @override
  State<CheckerDashboard> createState() => _CheckerDashboardState();
}

class _CheckerDashboardState extends State<CheckerDashboard> {
  final _formKey = GlobalKey<FormState>();
  final professorNameController = TextEditingController();
  final roomController = TextEditingController();
  String? attendanceStatus;

  DateTime now = DateTime.now();

  final List<Map<String, String>> _attendanceRecords = [];

  void _refreshTime() {
    setState(() {
      now = DateTime.now();
    });
  }

  void _saveAttendance() {
    if (_formKey.currentState!.validate() && attendanceStatus != null) {
      final dateStr = now.toLocal().toString().split(' ')[0];
      final timeStr =
          now.toLocal().toString().split(' ')[1].split('.').first;

      setState(() {
        _attendanceRecords.add({
          'name': professorNameController.text,
          'room': roomController.text,
          'date': dateStr,
          'time': timeStr,
          'status': attendanceStatus!,
        });

        professorNameController.clear();
        roomController.clear();
        attendanceStatus = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Attendance saved!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete the form")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = now.toLocal().toString().split(' ')[0];
    final timeStr = now.toLocal().toString().split(' ')[1].split('.').first;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Checker Dashboard"),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () {}),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.green[700]),
              child: const Text(
                "Menu",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard, color: Colors.green),
              title: const Text("Dashboard"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Colors.green),
              title: const Text("History"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.green),
              title: const Text("Settings"),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Class Attendance",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 500,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: professorNameController,
                      decoration: const InputDecoration(
                        labelText: "Professor Name",
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: roomController,
                      decoration: const InputDecoration(
                        labelText: "Room",
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            readOnly: true,
                            controller: TextEditingController(text: dateStr),
                            decoration: const InputDecoration(
                              labelText: "Date",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  readOnly: true,
                                  controller: TextEditingController(text: timeStr),
                                  decoration: const InputDecoration(
                                    labelText: "Time",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: _refreshTime,
                                icon: const Icon(Icons.refresh,
                                    color: Colors.green),
                                tooltip: "Refresh Time",
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: attendanceStatus,
                      items: const [
                        DropdownMenuItem(
                            value: "Present", child: Text("Present")),
                        DropdownMenuItem(
                            value: "Absent", child: Text("Absent")),
                        DropdownMenuItem(value: "ODL", child: Text("ODL")),
                      ],
                      decoration: const InputDecoration(
                        labelText: "Attendance Status",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          attendanceStatus = value;
                        });
                      },
                      validator: (val) =>
                          val == null ? 'Please select attendance' : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveAttendance,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text("Save Attendance"),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Saved Attendance",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _attendanceRecords.isEmpty
                ? const Text("No attendance records yet.")
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text("Name")),
                        DataColumn(label: Text("Room")),
                        DataColumn(label: Text("Date")),
                        DataColumn(label: Text("Time")),
                        DataColumn(label: Text("Status")),
                        DataColumn(label: Text("Actions")),
                      ],
                      rows: _attendanceRecords.asMap().entries.map((entry) {
                        final index = entry.key;
                        final record = entry.value;
                        return DataRow(cells: [
                          DataCell(Text(record['name']!)),
                          DataCell(Text(record['room']!)),
                          DataCell(Text(record['date']!)),
                          DataCell(Text(record['time']!)),
                          DataCell(Text(record['status']!)),
                          DataCell(
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: "Delete record",
                              onPressed: () {
                                setState(() {
                                  _attendanceRecords.removeAt(index);
                                });
                              },
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
