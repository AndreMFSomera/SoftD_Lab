import 'package:flutter/material.dart';
import 'api_service.dart'; // Make sure this points to your actual ApiService file

class InstructorAttendanceSummaryPage extends StatefulWidget {
  const InstructorAttendanceSummaryPage({super.key});

  @override
  State<InstructorAttendanceSummaryPage> createState() =>
      _InstructorAttendanceSummaryPageState();
}

class _InstructorAttendanceSummaryPageState
    extends State<InstructorAttendanceSummaryPage> {
  late Future<List<Map<String, dynamic>>> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _summaryFuture = ApiService.getInstructorAttendanceSummary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instructor Attendance Summary'),
        backgroundColor: Colors.brown,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _summaryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No attendance summary found.'));
          }

          final data = snapshot.data!;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal, // 🔄 Enables horizontal scrolling
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.brown.shade100),
              columns: const [
                DataColumn(
                  label: Text(
                    'Professor Name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(label: Text('Present')),
                DataColumn(label: Text('Absent')),
                DataColumn(label: Text('ODL')),
              ],
              rows: data.map((item) {
                return DataRow(
                  cells: [
                    DataCell(Text(item['professor_name'] ?? '')),
                    DataCell(Text(item['present_count'].toString())),
                    DataCell(Text(item['absent_count'].toString())),
                    DataCell(Text(item['odl_count'].toString())),
                  ],
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
