import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddSchedulePage extends StatefulWidget {
  const AddSchedulePage({super.key});

  @override
  State<AddSchedulePage> createState() => _AddSchedulePageState();
}

class _AddSchedulePageState extends State<AddSchedulePage> {
  String? selectedProfessor;
  String? selectedRoom;
  String? selectedDay;
  String? selectedStart;
  String? selectedEnd;

  bool _isLoading = false;

  final List<String> days = ['MWF', 'TTHS'];
  final List<String> rooms = ['S213', 'S218', 'S224', 'S242'];

  final List<Map<String, String>> timeSlots = [
    {'start': '07:30', 'end': '08:50'},
    {'start': '08:50', 'end': '09:30'},
    {'start': '09:30', 'end': '10:10'},
    {'start': '10:10', 'end': '11:30'},
    {'start': '11:30', 'end': '12:50'},
    {'start': '12:50', 'end': '14:10'},
    {'start': '14:10', 'end': '15:30'},
    {'start': '15:30', 'end': '16:50'},
    {'start': '16:50', 'end': '18:10'},
    {'start': '18:10', 'end': '19:30'},
  ];

  List<String> instructorNames = [];
  List<dynamic> schedules = [];

  @override
  void initState() {
    super.initState();
    fetchInstructors();
    fetchSchedules();
  }

  Future<void> fetchInstructors() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/get_instructors'),
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          instructorNames = data
              .map((i) => i['professor_name'] as String)
              .toList();
        });
      } else {
        showError('Failed to load instructors');
      }
    } catch (e) {
      showError('Error fetching instructors: $e');
    }
  }

  Future<void> fetchSchedules() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/get_schedules'),
      );
      if (response.statusCode == 200) {
        setState(() {
          schedules = jsonDecode(response.body);
        });
      } else {
        showError('Failed to load schedules');
      }
    } catch (e) {
      showError('Error fetching schedules: $e');
    }
  }

  Future<void> addSchedule() async {
    if (selectedProfessor == null ||
        selectedRoom == null ||
        selectedDay == null ||
        selectedStart == null ||
        selectedEnd == null) {
      showError('Please fill in all fields.');
      return;
    }

    final body = {
      'professor_name': selectedProfessor!.toLowerCase(),
      'room_number': selectedRoom!,
      'day': selectedDay!,
      'starting_time': '$selectedStart:00',
      'ending_time': '$selectedEnd:00',
    };

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/add_schedule'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 201) {
        showSuccess('Schedule added successfully.');
        fetchSchedules(); // refresh after add
      } else {
        showError(
          'Add failed: ${jsonDecode(response.body)['error'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      showError('Error: $e');
    }
  }

  Future<void> deleteSchedule(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:5000/delete_schedule/$id'),
      );
      if (response.statusCode == 200) {
        showSuccess('Deleted successfully');
        fetchSchedules();
      } else {
        showError('Delete failed: ${response.body}');
      }
    } catch (e) {
      showError('Error deleting schedule: $e');
    }
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
      filled: true,
      fillColor: Colors.green.shade50,
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.black),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Manager'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: selectedProfessor,
                decoration: themedInput('Select Professor'),
                items: instructorNames.map((name) {
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
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedRoom,
                decoration: themedInput('Select Room'),
                items: rooms.map((room) {
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
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedDay,
                decoration: themedInput('Select Day'),
                items: days.map((day) {
                  return DropdownMenuItem<String>(value: day, child: Text(day));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDay = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedStart,
                decoration: themedInput('Select Starting Time'),
                items: timeSlots.map((slot) {
                  return DropdownMenuItem<String>(
                    value: slot['start'],
                    child: Text(slot['start']!),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedStart = value;
                    selectedEnd = timeSlots.firstWhere(
                      (slot) => slot['start'] == value,
                    )['end'];
                  });
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                enabled: false,
                decoration: themedInput('Ending Time'),
                controller: TextEditingController(text: selectedEnd),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : addSchedule,
                  icon: const Icon(Icons.schedule),
                  label: Text(_isLoading ? 'Saving...' : 'Add Schedule'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 10),
              const Text(
                'Existing Schedules',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...schedules.map((item) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text('${item['professor_name']} - ${item['day']}'),
                    subtitle: Text(
                      '${item['room_number']} | ${item['starting_time']} to ${item['ending_time']}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteSchedule(item['id']),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
