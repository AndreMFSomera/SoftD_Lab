import 'package:flutter/material.dart';
import 'api_service.dart';

class SignupPage extends StatelessWidget {
  SignupPage({super.key});

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              // Signup form (left side)
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(50),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Sign Up for a Faculty Account',
                        style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 300,
                        child: TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            hintText: 'Full Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 300,
                        child: TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            hintText: 'Faculty Email or ID',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
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
                            contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
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
                            contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                          ),
                        ),
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
                          onPressed: () async{
                            final name = nameController.text.trim();
                            final emailOrId = emailController.text.trim();
                            final password = passwordController.text.trim();
                            final confirmPassword = confirmPasswordController.text.trim();

                            if (password != confirmPassword) {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                   title: Text('Error'),
                                   content: Text('Passwords do not match'),
                                   actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))],
                                ),
                              );
                              return;
                          }

                          final success = await ApiService.signup(name, emailOrId, password);

                           if (success) {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text('Success'),
                                content: Text('Account created successfully. You can now log in.'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context); // Close dialog
                                      Navigator.pop(context); // Go back to login screen
                                    },
                                    child: Text('OK'),
                                  ),
                                ],
                              ),
                            );
                           }else {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text('Error'),
                                content: Text('Signup failed. Email/ID might already exist.'),
                                actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))],
                              ),
                            );
                           }
                          },                                                                                                             
                          child: const Text('Sign Up', style: TextStyle(fontSize: 18)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Go back to login page
                        },
                        child: const Text('Already have an account? Log in', style: TextStyle(color: Colors.blue)),
                      ),
                    ],
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
          // Logo and system name
          Positioned(
            top: 20,
            left: 20,
            child: Row(
              children: [
                Image.asset('assets/UC_Official_Seal.png', height: 100),
                const SizedBox(width: 10),
                const Text(
                  'FACULTY ATTENDANCE MANAGEMENT SYSTEM (FAMS)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
