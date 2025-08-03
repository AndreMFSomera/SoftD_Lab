import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    nameController.addListener(() {
      final currentText = nameController.text;
      if (currentText != currentText.toLowerCase()) {
        nameController.value = nameController.value.copyWith(
          text: currentText.toLowerCase(),
          selection: TextSelection.collapsed(offset: currentText.length),
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

                    // Name field
                    SizedBox(
                      width: 300,
                      child: TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: 'Full Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ID field
                    SizedBox(
                      width: 300,
                      child: TextField(
                        controller: idController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          _idFormatter,
                          LengthLimitingTextInputFormatter(11),
                        ],
                        decoration: InputDecoration(
                          hintText: 'ID (e.g. 22-3734-621)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Password
                    SizedBox(
                      width: 300,
                      child: TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Confirm Password
                    SizedBox(
                      width: 300,
                      child: TextField(
                        controller: confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Confirm Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Sign Up Button
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
                        onPressed: () async {
                          final name = nameController.text.trim();
                          final id = idController.text.trim();
                          final password = passwordController.text.trim();
                          final confirmPassword = confirmPasswordController.text
                              .trim();

                          final idRegex = RegExp(r'^\d{2}-\d{4}-\d{3}$');
                          final nameRegex = RegExp(r'^[^0-9]+$');

                          if (!idRegex.hasMatch(id)) {
                            _showDialog(
                              context,
                              'Invalid ID Format',
                              'ID must follow the format xx-xxxx-xxx',
                            );
                            return;
                          }

                          if (!nameRegex.hasMatch(name)) {
                            _showDialog(
                              context,
                              'Invalid Name',
                              'Name must not contain numbers.',
                            );
                            return;
                          }

                          if (password != confirmPassword) {
                            _showDialog(
                              context,
                              'Password Error',
                              'Passwords do not match.',
                            );
                            return;
                          }

                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );

                          try {
                            // ✅ Check if name already exists in the backend
                            final nameExists = await ApiService.doesNameExist(
                              name,
                            );

                            if (nameExists) {
                              if (context.mounted)
                                Navigator.pop(context); // close loading spinner
                              _showDialog(
                                context,
                                'Duplicate Name',
                                'An account with this full name already exists.',
                              );
                              return;
                            }

                            final success = await ApiService.signup(
                              name,
                              id,
                              password,
                            );
                            if (context.mounted) Navigator.pop(context);

                            if (success) {
                              if (context.mounted) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext dialogContext) =>
                                      AlertDialog(
                                        title: const Text('Success'),
                                        content: const Text(
                                          'Account created successfully.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(
                                                dialogContext,
                                              ); // close dialog
                                            },
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      ),
                                );
                              }
                            } else {
                              if (context.mounted) {
                                _showDialog(
                                  context,
                                  'Signup Failed',
                                  'ID might already exist.',
                                );
                              }
                            }
                          } catch (e) {
                            if (context.mounted) Navigator.pop(context);
                            _showDialog(
                              context,
                              'Network Error',
                              'Something went wrong: $e',
                            );
                          }
                        },

                        child: const Text(
                          'Sign Up',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    TextButton(
                      onPressed: () => Navigator.pop(context),
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

          // Right side panel
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

  void _showDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // close dialog
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
