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
      Uri.parse('http://localhost:5000/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id_number': idNumber,
        'password': password,
        'role': role, // Send role to API
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
}
