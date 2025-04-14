import 'package:flutter/material.dart';
import '../pages/view_app.dart';
import 'application_card.dart';

/// Builds the list of applications based on the selected tab and search query.

class ApplicationsList extends StatelessWidget {
  //parameters passed to the widget from its parent
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
      //StreamBuilder listens to the applicationStream
      stream: applicationStream,
      //Every time the stream emits new data, it rebuilds the UI.
      builder: (context, snapshot) {
        //If the stream is still loading, show a spinner.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        //If there’s no data, show a message saying no applications exist yet.
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No applications yet."));
        }

        //filters the list based on Search Query and active tabs
        final filteredApplications = snapshot.data!.where((app) {
          //Each field of the application is checked if it contains the search query.
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

          //matchesStatus checks if current tab matches the app's status
          final matchesStatus = selectedTab == "Dashboard" || status == selectedTab.toLowerCase();

          return matchesSearchQuery && matchesStatus;
        }).toList();

        if (filteredApplications.isEmpty) {
          return const Center(child: Text("No applications found."));
        }

        final sortedApplications = sortApplications(filteredApplications);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          //Loops through every sorted application.
          children: sortedApplications.map((app) {
            return GestureDetector(
              //Tapping the card navigates to a details page for that application.
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewApplicationPage(application: app),
                  ),
                );
                //When the user returns, the UI refreshes status counts via a callback.
                await onStatusCountsReload();
              },

              //Each card has its own edit and delete buttons wired up to logic from the parent widget.
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
