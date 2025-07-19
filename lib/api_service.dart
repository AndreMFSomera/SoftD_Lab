import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://192.168.1.2:5000'; 

  static Future<void> testApi() async {
    final response = await http.get(Uri.parse('$baseUrl/test'));

    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  static Future<bool> login(String idNumber, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id_number': idNumber, 'password': password}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Login failed: ${response.body}');
      return false;
    }
  }
  static Future<bool> signup(String fullName, String idNumber, String password) async {
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