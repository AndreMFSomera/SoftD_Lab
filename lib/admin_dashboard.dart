import 'package:flutter/material.dart';
import 'add_instructor_page.dart';
import 'api_service.dart'; // <-- Make sure this exists and has getCheckerCount()

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  int checkerCount = 0;
  bool isLoading = true;

  final List<String> _titles = [
    'Admin - Dashboard',
    'Admin - Instructors',
    'Admin - Manage',
  ];

  @override
  void initState() {
    super.initState();
    _loadCheckerCount();
  }

  void _loadCheckerCount() async {
    try {
      final count = await ApiService.getCheckerCount();
      if (!mounted) return;
      setState(() {
        checkerCount = count;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching checker count: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

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
        if (mounted) {
          setState(() {
            _selectedIndex = 0;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.green[700],
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(fontFamily: 'Arial'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutConfirmation(context),
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 200,
            color: Colors.green[800],
            child: Column(
              children: [
                const SizedBox(height: 30),
                _buildNavItem(Icons.dashboard, "Dashboard", 0),
                _buildNavItem(Icons.person, "Instructors", 1),
                _buildNavItem(Icons.check, "Manage", 2),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _selectedIndex == 0
                  ? _buildDashboardContent()
                  : _selectedIndex == 2
                  ? _buildCheckerPanel()
                  : _buildPlaceholder(),
            ),
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
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green[600] : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
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
          Text(
            "Overview",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
              fontFamily: 'Arial',
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.start,
            children: [
              _buildStatCard("Total Instructors", "0", Icons.person),
              _buildStatCard(
                "Checkers",
                isLoading ? "..." : "$checkerCount",
                Icons.verified_user,
              ),
            ],
          ),
          const SizedBox(height: 40),
          const Text(
            "Recent Activities",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              fontFamily: 'Arial',
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "No recent activities.",
            style: TextStyle(color: Colors.black54, fontFamily: 'Arial'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.green[700]),
            const SizedBox(height: 10),
            Text(
              count,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Arial',
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                fontFamily: 'Arial',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckerPanel() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _buildPanel("Instructors", ["Instructor 1", "Instructor 2"]),
          const SizedBox(width: 16),
          _buildPanel("Subjects", ["Subject A", "Subject B"]),
          const SizedBox(width: 16),
          _buildPanel("Checkers", ["Checker X", "Checker Y"]),
        ],
      ),
    );
  }

  Widget _buildPanel(String title, List<String> items) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Arial',
              ),
            ),
            const Divider(),
            ...items.map((e) => ListTile(title: Text(e))),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Text(
        "Feature not yet implemented.",
        style: TextStyle(fontSize: 18, color: Colors.grey, fontFamily: 'Arial'),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text("Logout"),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // close dialog
                if (Navigator.canPop(context)) {
                  Navigator.of(context).pop(); // go back to login
                }
              },
            ),
          ],
        );
      },
    );
  }
}
