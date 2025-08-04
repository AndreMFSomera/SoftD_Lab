import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softd/api_service.dart';
import 'package:softd/main.dart';

class CheckerDashboard extends StatefulWidget {
  const CheckerDashboard({super.key});

  @override
  State<CheckerDashboard> createState() => _CheckerDashboardState();
}

class _CheckerDashboardState extends State<CheckerDashboard> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController scheduleTimeController = TextEditingController();

  String? selectedProfessor;
  String? selectedRoom;
  String? attendanceStatus;

  List<String> professorNames = [];
  List<String> roomOptions = [];

  DateTime now = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchProfessors();
    fetchRooms();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    super.dispose();
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

  Future<void> fetchRooms() async {
    try {
      final rooms = await ApiService.getRooms();
      setState(() {
        roomOptions = rooms;
      });
    } catch (e) {
      print('Error fetching rooms: $e');
    }
  }

  void _refreshTime() {
    setState(() {
      now = DateTime.now();
    });
  }

  void _saveAttendance() async {
    if (_formKey.currentState!.validate() &&
        attendanceStatus != null &&
        _subjectController.text.isNotEmpty) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Confirm Submission"),
          content: const Text(
            "Make sure your inputs are correct.\nIf there's a mistake, consult the admin.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Confirm"),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      final prefs = await SharedPreferences.getInstance();
      String? checkerId = prefs.getString('id_number');

      if (checkerId == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("User not logged in")));
        return;
      }

      final success = await ApiService.saveAttendance(
        recordedBy: checkerId,
        professorName: selectedProfessor!,
        roomNumber: selectedRoom!,
        attendanceStatus: attendanceStatus!,
        subjectName: _subjectController.text,
      );

      if (success) {
        setState(() {
          selectedProfessor = null;
          selectedRoom = null;
          attendanceStatus = null;
          _subjectController.clear();
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Attendance saved!")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to save attendance")),
        );
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please complete the form")));
    }
  }

  Widget _buildAttendanceForm() {
    final dateStr = now.toLocal().toString().split(' ')[0];
    final timeStr = now.toLocal().toString().split(' ')[1].split('.').first;

    return Center(
      child: SingleChildScrollView(
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

                // ROOM
                DropdownButtonFormField<String>(
                  value: selectedRoom,
                  items: roomOptions.map((room) {
                    return DropdownMenuItem<String>(
                      value: room,
                      child: Text(room),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedRoom = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: "Room",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null ? 'Please select a room' : null,
                ),
                const SizedBox(height: 12),

                // PROFESSOR
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

                // SUBJECT
                TextFormField(
                  controller: _subjectController,
                  decoration: const InputDecoration(
                    labelText: "Subject",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter a subject'
                      : null,
                ),
                const SizedBox(height: 12),

                // TIME
                TextFormField(
                  controller: scheduleTimeController,
                  decoration: const InputDecoration(
                    labelText: "Schedule Time",
                    border: OutlineInputBorder(),
                    hintText: "e.g. 1:00 PM - 2:00 PM",
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter schedule time'
                      : null,
                ),

                const SizedBox(height: 16),

                // DATE + TIME DISPLAY
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
                      child: TextFormField(
                        readOnly: true,
                        controller: TextEditingController(text: timeStr),
                        decoration: const InputDecoration(
                          labelText: "Time",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _refreshTime,
                      icon: const Icon(Icons.refresh, color: Colors.green),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ATTENDANCE STATUS
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
      ),
    );
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
        centerTitle: true,
        backgroundColor: Colors.green[700],
        title: const Text(
          "CHECKER DASHBOARD",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontFamily: 'Arial',
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _confirmLogout),
        ],
      ),
      body: Container(
        width: double.infinity,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        color: Colors.grey[100],
        child: _buildAttendanceForm(),
      ),
    );
  }
}
