import 'package:flutter/material.dart';
import 'add_instructor_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<String> _titles = [
    'Admin - Dashboard',
    'Admin - Instructors',
    'Admin - Checkers',
    'Admin - Reports',
  ];

  void _onNavTap(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddInstructorPage()),
      ).then((_) {
        setState(() {
          _selectedIndex = 0;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: Text(_titles[_selectedIndex]),
        leading: const Icon(Icons.arrow_back),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // TODO: Add logout logic
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Left Navigation – placed below the AppBar now
          Container(
            width: 200,
            color: Colors.green[800],
            child: Column(
              children: [
                const SizedBox(height: 20), // spacing under AppBar
                _buildNavItem(Icons.dashboard, "Dashboard", 0),
                _buildNavItem(Icons.person, "Instructors", 1),
                _buildNavItem(Icons.check, "Checkers", 2),
                _buildNavItem(Icons.bar_chart, "Reports", 3),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: _selectedIndex == 0
                ? _buildDashboardContent()
                : _buildPlaceholder(),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onNavTap(index),
      child: Container(
        color: isSelected ? Colors.green[600] : Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: ListView(
        children: [
          Center(
            child: Text(
              "Overview",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: [
                _buildStatCard("Total Instructors", "0", Icons.person),
                _buildStatCard("Checkers", "0", Icons.verified_user),
              ],
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            "Recent Activities",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "No recent activities.",
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 160,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: Colors.green),
            const SizedBox(height: 10),
            Text(
              count,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Text(
        "Feature not yet implemented.",
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }
}
