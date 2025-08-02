import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softd/api_service.dart'; 
import 'package:softd/main.dart';//OKOK

class CheckerDashboard extends StatefulWidget {
  const CheckerDashboard({super.key});

  @override
  State<CheckerDashboard> createState() => _CheckerDashboardState();
}

class _CheckerDashboardState extends State<CheckerDashboard> {
  int _selectedIndex = 0;

  final _formKey = GlobalKey<FormState>();
  String? selectedProfessor;
  final roomController = TextEditingController();
  String? attendanceStatus;
  DateTime now = DateTime.now();

  final List<Map<String, String>> _attendanceRecords = [];
  List<String> professorNames = [];

  @override
  void initState() {
    super.initState();
    fetchProfessors();
  }

  Future<void> fetchProfessors() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/get_instructors'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          professorNames = data
              .map((item) => item['professor_name'].toString())
              .toList();
        });
      } else {
        throw Exception('Failed to load professor names');
      }
    } catch (e) {
      print('Error fetching professor names: $e');
    }
  }

  void _refreshTime() {
    setState(() {
      now = DateTime.now();
    });
  }

  void _saveAttendance() async{
    if (_formKey.currentState!.validate() && attendanceStatus != null) {
      final prefs = await SharedPreferences.getInstance();
      String? checkerId = prefs.getString('id_number');

      if (checkerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not logged in")),
        );
        return;
      }

      final dateStr = now.toLocal().toString().split(' ')[0];
      final timeStr = now.toLocal().toString().split(' ')[1].split('.').first;

      final success = await ApiService.saveAttendance(
        recordedBy: checkerId,
        professorName: selectedProfessor!,
        roomNumber: roomController.text,
        attendanceStatus: attendanceStatus!,
      );
      if (success) {
        setState(() {
          _attendanceRecords.add({
            'name': selectedProfessor!,
            'room': roomController.text,
            'date': dateStr,
            'time': timeStr,
            'status': attendanceStatus!,
          });

        selectedProfessor = null;
        roomController.clear();
        attendanceStatus = null;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Attendance saved!")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please complete the form")));
    }
  }
  }
  Widget _buildAttendanceForm() {
    final dateStr = now.toLocal().toString().split(' ')[0];
    final timeStr = now.toLocal().toString().split(' ')[1].split('.').first;

    return Center(
      child: Container(
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
            mainAxisSize: MainAxisSize.min,
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
              DropdownButtonFormField<String>(
                value: selectedProfessor,
                items: professorNames.map((name) {
                  return DropdownMenuItem<String>(
                    value: name,
                    child: Text(name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedProfessor = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: "Professor Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null ? 'Please select a professor' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: roomController,
                decoration: const InputDecoration(
                  labelText: "Room",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
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
                          icon: const Icon(Icons.refresh, color: Colors.green),
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
                  DropdownMenuItem(value: "Present", child: Text("Present")),
                  DropdownMenuItem(value: "Absent", child: Text("Absent")),
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
                validator: (value) =>
                    value == null ? 'Please select a status' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveAttendance,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("Save Attendance"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryPage() {
    return Center(
      child: _attendanceRecords.isEmpty
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
                  return DataRow(
                    cells: [
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
                    ],
                  );
                }).toList(),
              ),
            ),
    );
  }

  Widget _getBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildAttendanceForm();
      case 1:
        return _buildHistoryPage();
      default:
        return const Center(child: Text("Page Not Found"));
    }
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const MyApp()),
                (route) => false,
              );
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Checker Dashboard"),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _confirmLogout),
        ],
      ),
      body: Row(
        children: [
          Container(
            width: 180,
            color: Colors.green[700],
            child: NavigationRail(
              backgroundColor: Colors.green[700],
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              extended: true,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard, color: Colors.white),
                  selectedIcon: Icon(Icons.dashboard, color: Colors.white),
                  label: Text(
                    "Dashboard",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.history, color: Colors.white),
                  selectedIcon: Icon(Icons.history, color: Colors.white),
                  label: Text("History", style: TextStyle(color: Colors.white)),
                ),
              ],
              selectedLabelTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelTextStyle: const TextStyle(color: Colors.white70),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: _getBody()),
        ],
      ),
    );
  }
}
