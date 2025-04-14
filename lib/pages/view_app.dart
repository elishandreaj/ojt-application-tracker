import 'package:flutter/material.dart';
import '../services/db_service.dart';
import 'update_app.dart';
import '../utils/constants.dart'; 

class ViewApplicationPage extends StatelessWidget {
  final Map<String, dynamic> application;

  const ViewApplicationPage({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    final List<String> requirements = (application['requirements'] as String?)
        ?.split(',') // Split by commas instead of newline
        .map((r) => r.trim()) // Trim any extra spaces around each requirement
        .where((r) => r.isNotEmpty) // Filter out empty strings if any
        .toList() ?? [];

    // Get the status color from the constants
    final String status = application['status'] ?? 'To Apply';
    final statusBackgroundColor = kStatusColors[status] ?? Colors.blue;

    return Scaffold(
      appBar: AppBar(
        title: Text(application['company']),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12, top: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusBackgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Details Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow("Company", application['company']),
                _infoRow("Role", application['role']),
                _infoRow("Location", application['location']),
                _infoRow("Setup", application['setup']),
              ],
            ),
            const SizedBox(height: 12),

            // Dates Section
            Text(
              _getDateLabel(application['status']) + (application['date'] ?? '-'),
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            Text(
              'Date Added: ${application['date_added'] ?? '-'}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 20),

            // Requirements Section
            Text(
              'Requirements',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: requirements.map((req) => Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  children: [
                    const Text("• ", style: TextStyle(fontSize: 16)),
                    Expanded(
                      child: Text(req, style: const TextStyle(fontSize: 15)),
                    ),
                  ],
                ),
              )).toList(),
            ),
            const SizedBox(height: 20),

            // Notes Section
            Text(
              'Notes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 6),
            Card(
              elevation: 2,
              color: Colors.grey.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SingleChildScrollView(
                  child: Text(
                    application['notes'] ?? '-',
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Edit and Delete Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UpdateApplicationScreen(applicationId: application['id']),
                        ),
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text("Edit", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      bool? shouldDelete = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Confirm Deletion"),
                          content: const Text("Are you sure you want to delete this application?"),
                          actions: [
                            TextButton(
                              child: const Text("Cancel"),
                              onPressed: () => Navigator.of(context).pop(false),
                            ),
                            TextButton(
                              child: const Text("Delete"),
                              onPressed: () => Navigator.of(context).pop(true),
                            ),
                          ],
                        ),
                      );

                      if (shouldDelete == true) {
                        await DatabaseService().deleteApplication(application['id']);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Application deleted.")),
                          );
                          Navigator.pop(context); // Go back to refresh the list
                        }
                      }
                    },
                    icon: const Icon(Icons.delete, color: Colors.white),
                    label: const Text("Delete", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getDateLabel(String? status) {
    switch (status) {
      case "To Apply":
        return "Application Deadline: ";
      case "Interview":
        return "Interview Schedule: ";
      default:
        return "Date of Application: ";
    }
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Flexible(
            child: Text(
              value ?? '-',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}