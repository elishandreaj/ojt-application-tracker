import 'package:flutter/material.dart';
import '../pages/view_app.dart';
import 'application_card.dart';

/// Builds the list of applications based on the selected tab and search query.

class ApplicationsList extends StatelessWidget {
  final Stream<List<Map<String, dynamic>>> applicationStream;
  final String searchQuery;
  final String selectedTab;
  final List<Map<String, dynamic>> Function(List<Map<String, dynamic>>) sortApplications;
  final Function(Map<String, dynamic>) onDelete;
  final Function(Map<String, dynamic>) onEdit;
  final Future<void> Function() onStatusCountsReload;

  const ApplicationsList({
    super.key,
    required this.applicationStream,
    required this.searchQuery,
    required this.selectedTab,
    required this.sortApplications,
    required this.onDelete,
    required this.onEdit,
    required this.onStatusCountsReload,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: applicationStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No applications yet."));
        }

        final filteredApplications = snapshot.data!.where((app) {
          final company = app['company'].toString().toLowerCase();
          final role = app['role'].toString().toLowerCase();
          final location = app['location'].toString().toLowerCase();
          final status = app['status'].toString().toLowerCase();
          final date = app['date'].toString().toLowerCase();
          final setup = app['setup'].toString().toLowerCase();
          final requirements = (app['requirements'] as String?)
              ?.split(',')
              .map((req) => req.trim().toLowerCase())
              .toList() ?? [];

          final matchesRequirements = requirements.any((req) => req.contains(searchQuery.toLowerCase()));

          final matchesSearchQuery = company.contains(searchQuery.toLowerCase()) ||
              role.contains(searchQuery.toLowerCase()) ||
              location.contains(searchQuery.toLowerCase()) ||
              status.contains(searchQuery.toLowerCase()) ||
              date.contains(searchQuery.toLowerCase()) ||
              setup.contains(searchQuery.toLowerCase()) ||
              matchesRequirements;

          final matchesStatus = selectedTab == "Dashboard" || status == selectedTab.toLowerCase();

          return matchesSearchQuery && matchesStatus;
        }).toList();

        if (filteredApplications.isEmpty) {
          return const Center(child: Text("No applications found."));
        }

        final sortedApplications = sortApplications(filteredApplications);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: sortedApplications.map((app) {
            return GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewApplicationPage(application: app),
                  ),
                );
                await onStatusCountsReload();
              },
              child: ApplicationCard(
                application: app,
                onDelete: () => onDelete(app),
                onEdit: () => onEdit(app),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
