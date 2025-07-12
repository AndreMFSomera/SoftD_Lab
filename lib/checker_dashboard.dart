import 'package:flutter/material.dart';

class CheckerDashboard extends StatelessWidget {
  const CheckerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // No dummy class list

    return Scaffold(
      appBar: AppBar(
        title: const Text("Checker Dashboard"),
        backgroundColor: Colors.green[700],
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () {})],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.green[700]),
              child: const Text(
                "Menu",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard, color: Colors.green),
              title: const Text("Dashboard"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Colors.green),
              title: const Text("History"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.green),
              title: const Text("Settings"),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                "Class Attendance",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 20),
              Text(
                "No classes to display.",
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
