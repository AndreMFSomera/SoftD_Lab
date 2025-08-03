import 'package:flutter/material.dart';
import 'api_service.dart';

class CheckerListPage extends StatefulWidget {
  const CheckerListPage({super.key});

  @override
  State<CheckerListPage> createState() => _CheckerListPageState();
}

class _CheckerListPageState extends State<CheckerListPage> {
  late Future<List<Map<String, dynamic>>> _checkersFuture;

  @override
  void initState() {
    super.initState();
    _loadCheckers();
  }

  void _loadCheckers() {
    setState(() {
      _checkersFuture = ApiService.getCheckers();
    });
  }

  void _deleteChecker(int userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Delete Checker"),
        content: const Text("Are you sure you want to delete this checker?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[600]),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ApiService.deleteUser(userId);
      if (success && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Checker deleted")));
        _loadCheckers();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Failed to delete")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: const Text(
          "Checkers List",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white, // 👈 AppBar title in white
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ), // 👈 Back button in white
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _checkersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No checkers found.",
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
            );
          }

          final checkers = snapshot.data!;

          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                scrollDirection: Axis.vertical,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    columnSpacing: 24,
                    headingRowColor: MaterialStateProperty.all(
                      Colors.green[200],
                    ),
                    columns: const [
                      DataColumn(
                        label: Text(
                          "Name",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "ID",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Role",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Created At",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Action",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    rows: checkers.map((checker) {
                      return DataRow(
                        cells: [
                          DataCell(Text(checker['full_name'] ?? '')),
                          DataCell(Text(checker['id_number'] ?? '')),
                          DataCell(Text(checker['role'] ?? '')),
                          DataCell(
                            Text(checker['created_at']?.split('T').first ?? ''),
                          ),
                          DataCell(
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteChecker(checker['id']),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
