import 'package:http/http.dart' as http;
import 'dart:convert';


class UserSession {
  static int? id;
  static String? role;
}
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
      final data = jsonDecode(response.body);
      // Store the user session data
      UserSession.id = data['id_number'];
      UserSession.role = data['role'];
      return true;
    } else {
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