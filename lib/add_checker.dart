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
      if (success) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Checker deleted")));
        }
        _loadCheckers();
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Failed to delete")));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5), // light modern grey
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: const Text(
          "Checkers List",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
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

          return ListView.builder(
            itemCount: checkers.length,
            itemBuilder: (context, index) {
              final checker = checkers[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.green[100],
                    child: Icon(Icons.person, color: Colors.green[700]),
                  ),
                  title: Text(
                    checker['full_name'] ?? 'No name',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("ID: ${checker['id_number'] ?? 'N/A'}"),
                        Text("Role: ${checker['role'] ?? 'N/A'}"),
                        Text("Created: ${checker['created_at'] ?? 'N/A'}"),
                      ],
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    tooltip: "Delete Checker",
                    onPressed: () => _deleteChecker(checker['id']),
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
