// admin_dashboard.dart
import 'package:flutter/material.dart';
import 'add_instructor_page.dart';
import 'add_checker.dart';
import 'api_service.dart';
import 'manage_page.dart';
import 'admin_login.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  int checkerCount = 0;
  int instructorCount = 0;
  bool isLoading = true;
  late Future<List<Map<String, dynamic>>> _instructorSummaryFuture;

  final List<String> _titles = [
    'Admin - Dashboard',
    'Admin - Instructors',
    'Admin - Checkers',
    'Admin - Manage',
  ];

  @override
  void initState() {
    super.initState();
    _loadCheckerCount();
    fetchInstructorCount();
    _instructorSummaryFuture = ApiService.getInstructorAttendanceSummary();
  }

  Future<void> refreshInstructorSummary() async {
    final updatedSummary = await ApiService.getInstructorAttendanceSummary();
    if (!mounted) return;
    setState(() {
      _instructorSummaryFuture = Future.value(updatedSummary);
    });
  }

  Future<void> fetchInstructorCount() async {
    try {
      final count = await ApiService.getInstructorCount();
      if (!mounted) return;
      setState(() {
        instructorCount = count;
      });
    } catch (e) {
      print('Failed to fetch instructor count: $e');
    }
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
          fetchInstructorCount();
        }
      });
    }

    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CheckerListPage()),
      ).then((_) {
        if (mounted) {
          setState(() {
            _selectedIndex = 0;
          });
          _loadCheckerCount();
        }
      });
    }

    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ManagePage()),
      ).then((_) {
        if (mounted) {
          setState(() {
            _selectedIndex = 0;
          });
          refreshInstructorSummary(); // 👈 Refresh the summary after coming back
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
          Container(
            width: 200,
            color: Colors.green[800],
            child: Column(
              children: [
                const SizedBox(height: 30),
                _buildNavItem(Icons.dashboard, "Dashboard", 0),
                _buildNavItem(Icons.person, "Instructors", 1),
                _buildNavItem(Icons.check, "Checkers", 2),
                _buildNavItem(Icons.manage_accounts, "Manage", 3),
              ],
            ),
          ),
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
              _buildStatCard(
                "Total Instructors",
                "$instructorCount",
                Icons.person,
              ),
              _buildStatCard(
                "Checkers",
                isLoading ? "..." : "$checkerCount",
                Icons.verified_user,
              ),
            ],
          ),
          const SizedBox(height: 40),
          const Text(
            "Instructor Attendance Summary",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              fontFamily: 'Arial',
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 10),
          _buildInstructorSummaryTable(),
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

  Widget _buildInstructorSummaryTable() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _instructorSummaryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No instructor attendance summary available.'),
          );
        }

        final data = snapshot.data!;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Professor Name')),
              DataColumn(label: Text('Present')),
              DataColumn(label: Text('Absent')),
              DataColumn(label: Text('ODL')),
            ],
            rows: data.map((record) {
              return DataRow(
                cells: [
                  DataCell(Text(record['professor_name'] ?? '')),
                  DataCell(Text(record['present_count'].toString())),
                  DataCell(Text(record['absent_count'].toString())),
                  DataCell(Text(record['odl_count'].toString())),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildCheckerPanel() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: ApiService.getCheckers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No checkers found.'));
        }

        final checkers = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: checkers.length,
          itemBuilder: (context, index) {
            final checker = checkers[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(checker['username']),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDeleteChecker(checker['id']),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeleteChecker(int checkerId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Delete Checker"),
          content: const Text("Are you sure you want to delete this checker?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text("Delete"),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Close the dialog
                final success = await ApiService.deleteUser(checkerId);
                if (success && mounted) {
                  setState(() {});
                  _loadCheckerCount();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to delete checker')),
                  );
                }
              },
            ),
          ],
        );
      },
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
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text("Logout"),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // close dialog

                // Reset to login screen and clear fields
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const AdminLoginScreen(),
                  ),
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
