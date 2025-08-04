import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softd/api_service.dart';
import 'package:softd/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  String? selectedSubject;
  String? selectedTime;

  List<String> scheduleTimes = [];
  List<String> professorNames = [];
  List<String> roomOptions = [];
  List<String> subjectOptions = [];
  List<Map<String, dynamic>> validSchedules = [];

  String _getDayCode(int weekday) {
    switch (weekday) {
      case DateTime.monday:
      case DateTime.wednesday:
      case DateTime.friday:
        return 'MWF';
      case DateTime.tuesday:
      case DateTime.thursday:
      case DateTime.saturday:
        return 'TTHS';
      default:
        return '';
    }
  }

  bool _isTimeInRange(String currentTime, String startTime, String endTime) {
    int current = _toMinutes(currentTime);
    int start = _toMinutes(startTime);
    int end = _toMinutes(endTime);
    return current >= start && current <= end;
  }

  int _toMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  void loadValidScheduleOptions() async {
    try {
      final schedules = await ApiService.fetchValidSchedules();
      print('Fetched schedules: $schedules');

      DateTime now = DateTime.now();
      String currentDay = _getDayCode(now.weekday).toUpperCase();
      String currentTime =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

      print("System Now: $currentDay $currentTime");

      // Filter schedules strictly by day and time
      final filtered = schedules.where((schedule) {
        String scheduleDay = (schedule['day'] ?? '').trim().toUpperCase();
        String startTime = (schedule['starting_time'] ?? '').substring(0, 5);
        String endTime = (schedule['ending_time'] ?? '').substring(0, 5);

        bool isDayMatch = scheduleDay == currentDay;
        bool isTimeMatch = _isTimeInRange(currentTime, startTime, endTime);

        print(
          "Checking schedule -> Day: $scheduleDay | Start: $startTime | End: $endTime | Room: ${schedule['room_number']}",
        );
        print("   Day match: $isDayMatch | Time match: $isTimeMatch");

        return isDayMatch && isTimeMatch;
      }).toList();

      final validRooms = filtered
          .map((e) => e['room_number'].toString())
          .toSet()
          .toList();

      print("Valid Rooms: $validRooms");

      setState(() {
        validSchedules = List<Map<String, dynamic>>.from(filtered);
        roomOptions = validRooms; // ✅ only valid rooms
        selectedRoom = null; // clear selection if invalid
        professorNames = [];
        subjectOptions = [];
        scheduleTimes = [];
      });
    } catch (e) {
      print("Error loading schedules: $e");
    }
  }

  // ✅ fetchSubjects should be here (outside loadValidScheduleOptions)
  Future<void> fetchSubjects() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.191:5000/get_subjects'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          subjectOptions = data.cast<String>();
        });
      } else {
        print("Failed to fetch subjects");
      }
    } catch (e) {
      print("Error fetching subjects: $e");
    }
  }

  DateTime now = DateTime.now();

  @override
  void initState() {
    super.initState();
    loadValidScheduleOptions(); // Load filtered professors/rooms/subjects based on current time
    fetchSubjects();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    super.dispose();
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
        subjectName: selectedSubject!,
        scheduleTime: selectedTime!, // ⬅️ updated
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

                // ROOM DROPDOWN
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
                      selectedProfessor = null;
                      selectedSubject = null;
                      selectedTime = null;

                      final filtered = validSchedules
                          .where((e) => e['room_number'] == value)
                          .toList();

                      professorNames = filtered
                          .map((e) => e['professor_name'].toString())
                          .toSet()
                          .toList();
                      subjectOptions = [];
                      scheduleTimes = [];
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

                // PROFESSOR DROPDOWN
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
                      selectedSubject = null;
                      selectedTime = null;

                      final filtered = validSchedules
                          .where(
                            (e) =>
                                e['room_number'] == selectedRoom &&
                                e['professor_name'] == value,
                          )
                          .toList();

                      subjectOptions = filtered
                          .map((e) => e['subject_name'].toString())
                          .toSet()
                          .toList();
                      scheduleTimes = [];
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: "Professor",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null ? 'Please select a professor' : null,
                ),
                const SizedBox(height: 12),

                // SUBJECT DROPDOWN
                DropdownButtonFormField<String>(
                  value: selectedSubject,
                  items: subjectOptions.map((subject) {
                    return DropdownMenuItem<String>(
                      value: subject,
                      child: Text(subject),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedSubject = value;
                      selectedTime = null;

                      final filtered = validSchedules
                          .where(
                            (e) =>
                                e['room_number'] == selectedRoom &&
                                e['professor_name'] == selectedProfessor &&
                                e['subject_name'] == value,
                          )
                          .toList();

                      scheduleTimes = filtered
                          .map(
                            (e) =>
                                "${e['starting_time']} - ${e['ending_time']}",
                          )
                          .toSet()
                          .toList();
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: "Subject",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null ? 'Please select a subject' : null,
                ),
                const SizedBox(height: 12),

                // SCHEDULE TIME DROPDOWN
                DropdownButtonFormField<String>(
                  value: selectedTime,
                  items: scheduleTimes.map((time) {
                    return DropdownMenuItem<String>(
                      value: time,
                      child: Text(time),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedTime = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: "Schedule Time",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null ? 'Please select a schedule time' : null,
                ),
                const SizedBox(height: 12),

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

                // ATTENDANCE STATUS DROPDOWN
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

                // SAVE BUTTON
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
