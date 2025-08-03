import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:softd/main.dart';
import 'api_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final TextInputFormatter _idFormatter = TextInputFormatter.withFunction((
    oldValue,
    newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < digitsOnly.length && i < 9; i++) {
      buffer.write(digitsOnly[i]);
      if (i == 1 || i == 5) {
        buffer.write('-');
      }
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  });

  @override
  void initState() {
    super.initState();

    // Convert name input to lowercase in real-time
    nameController.addListener(() {
      final currentText = nameController.text;
      final lowerText = currentText.toLowerCase();

      if (currentText != lowerText) {
        final cursorPosition = nameController.selection;
        nameController.value = TextEditingValue(
          text: lowerText,
          selection: cursorPosition,
        );
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    idController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left Panel - Form
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(50),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Sign Up for a Faculty Account',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),

                    _buildTextField('Full Name', nameController),
                    const SizedBox(height: 10),

                    _buildTextField(
                      'ID (e.g. 22-3734-621)',
                      idController,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _idFormatter,
                        LengthLimitingTextInputFormatter(11),
                      ],
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),

                    _buildTextField(
                      'Password',
                      passwordController,
                      obscureText: true,
                    ),
                    const SizedBox(height: 10),

                    _buildTextField(
                      'Confirm Password',
                      confirmPasswordController,
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: 300,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E8B57),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: _handleSignUp,
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Already have an account? Log in',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Right Panel - Info
          Expanded(
            flex: 1,
            child: Container(
              color: const Color(0xFF029e6d),
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Faculty Registration',
                    style: TextStyle(fontSize: 28, color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Fill out your details to request a faculty account.',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String hint,
    TextEditingController controller, {
    bool obscureText = false,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
  }) {
    return SizedBox(
      width: 300,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        inputFormatters: inputFormatters,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 20,
          ),
        ),
      ),
    );
  }

  Future<void> _handleSignUp() async {
    FocusScope.of(context).unfocus(); // Close keyboard

    final name = nameController.text.trim();
    final id = idController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    final idRegex = RegExp(r'^\d{2}-\d{4}-\d{3}$');
    final nameRegex = RegExp(r'^[^0-9]+$');

    if (!idRegex.hasMatch(id)) {
      _showDialog('Invalid ID Format', 'ID must follow the format xx-xxxx-xxx');
      return;
    }

    if (!nameRegex.hasMatch(name)) {
      _showDialog('Invalid Name', 'Name must not contain numbers.');
      return;
    }

    if (password != confirmPassword) {
      _showDialog('Password Error', 'Passwords do not match.');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final nameExists = await ApiService.doesNameExist(name);
      if (nameExists) {
        if (context.mounted) {
          Navigator.of(context, rootNavigator: true).pop(); // close loading
          _showDialog(
            'Duplicate Name',
            'An account with this full name already exists.',
          );
        }
        return;
      }

      final success = await ApiService.signup(name, id, password);

      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();

      if (success) {
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (BuildContext dialogContext) => AlertDialog(
              title: const Text('Success'),
              content: const Text('Account created successfully.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext, rootNavigator: true).pop();
                    Navigator.of(
                      context,
                      rootNavigator: true,
                    ).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => LoginPage()),
                      (route) => false,
                    );
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        if (context.mounted) {
          _showDialog('Signup Failed', 'ID might already exist.');
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // close loading
        _showDialog('Network Error', 'Something went wrong: $e');
      }
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext, rootNavigator: true).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
