// lib/widgets/application_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ApplicationCard extends StatelessWidget {
  final Map<String, dynamic> application;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const ApplicationCard({
    super.key,
    required this.application,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final tagColors = {
      "To Apply": Colors.blue,
      "Applied": Colors.purple,
      "Interview": Colors.orange,
      "Accepted": Colors.green,
      "Rejected": Colors.red,
    };

    String displayDate;
    if (application['status'] == "To Apply") {
      displayDate = "Application Deadline: ${application['date']}";
    } else if (application['status'] == "Interview") {
      displayDate = "Interview Schedule: ${application['date']}";
    } else {
      displayDate = "Applied: ${application['date']}";
    }

    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            icon: Icons.edit,
            label: 'Edit',
            backgroundColor: Colors.green,
            borderRadius: BorderRadius.circular(16),
            onPressed: (_) => onEdit(),
          ),
          SlidableAction(
            icon: Icons.delete,
            label: 'Delete',
            backgroundColor: Colors.red,
            borderRadius: BorderRadius.circular(16),
            onPressed: (_) => onDelete(),
            padding: const EdgeInsets.symmetric(horizontal: 10),
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      application['company'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: tagColors[application['status']],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      application['status'],
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "${application['role']} | ${application['location']}",
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 4),
              Text(
                displayDate,
                style: const TextStyle(color: Colors.black87, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
