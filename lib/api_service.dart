import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://192.168.1.191:5000';

  static Future<int> getCheckerCount() async {
    final response = await http.get(Uri.parse('$baseUrl/count_checkers'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['checker_count'];
    } else {
      throw Exception('Failed to fetch checker count');
    }
  }

  static Future<void> testApi() async {
    final response = await http.get(Uri.parse('$baseUrl/test'));

    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  static Future<bool> login(
    String idNumber,
    String password,
    String role,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id_number': idNumber,
        'password': password,
        'role': role,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> signup(
    String fullName,
    String idNumber,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'full_name': fullName,
        'id_number': idNumber,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      print('Signup failed: ${response.body}');
      return false;
    }
  }

  static Future<List<Map<String, String>>> getInstructors() async {
    final response = await http.get(Uri.parse('$baseUrl/get_instructors'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Map<String, String>.from(e)).toList();
    } else {
      return [];
    }
  }

  static Future<bool> addInstructor(
    String name,
    String id,
    String email,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/add_instructor'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'professor_name': name,
        'id_number': id,
        'professor_email': email,
      }),
    );
    return response.statusCode == 201;
  }

  static Future<bool> deleteInstructor(String idNumber) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/delete_instructor/$idNumber'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Delete error: ${response.body}');
      return false;
    }
  }

  static Future<int> getInstructorCount() async {
    final response = await http.get(Uri.parse('$baseUrl/count_instructors'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['instructor_count'];
    } else {
      throw Exception('Failed to fetch instructor count');
    }
  }

  static Future<List<Map<String, dynamic>>> getCheckers() async {
    final response = await http.get(Uri.parse('$baseUrl/checkers'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load checkers');
    }
  }

  static Future<bool> deleteUser(int userId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/delete_checker/$userId'), // 👈 updated route
    );
    return response.statusCode == 200;
  }

  static Future<bool> addUser(
    String username,
    String password,
    String role,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/add_user'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'role': role,
      }),
    );

    return response.statusCode == 200;
  }

  static Future<bool> saveAttendance({
    required String recordedBy,
    required String professorName,
    required String roomNumber,
    required String attendanceStatus,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/save_attendance'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'recorded_by': recordedBy,
        'professor_name': professorName,
        'room_number': roomNumber,
        'attendance_status': attendanceStatus,
      }),
    );

    return response.statusCode == 200;
  }

  static Future<List<Map<String, dynamic>>> getAttendanceRecords() async {
    final response = await http.get(Uri.parse('$baseUrl/attendance_records'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(jsonData);
    } else {
      throw Exception('Failed to load attendance records');
    }
  }

  static Future<bool> deleteAttendanceRecord(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/attendance_records/$id'),
    );
    return response.statusCode == 200;
  }

  static Future<List<Map<String, dynamic>>>
  getInstructorAttendanceSummary() async {
    final response = await http.get(
      Uri.parse('$baseUrl/instructor_attendance_summary'),
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load instructor attendance summary');
    }
  }
}
