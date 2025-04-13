import 'package:flutter/material.dart';
import 'add_new.dart';
import 'update_app.dart';
import '../services/db_service.dart';
import '../utils/constants.dart';
import '../widgets/overview_section.dart';
import '../widgets/applications_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
    routes: {
      '/': (context) => Dashboard(),
    },
  ));
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  final DatabaseService _dbService = DatabaseService();
  List<Map<String, dynamic>> deletedApplications = [];

  final Map<String, Color> tagColors = kStatusColors;

  String _sortOption = "Date Added (Ascending)";
  String _selectedTab = "Dashboard";
  Map<String, int> statusCounts = {};

  /// Controller for the search input field.
  final TextEditingController _searchController = TextEditingController();

  /// Current search query entered by the user.
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadStatusCounts();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  /// Loads the count of applications for each status from the database.
  Future<void> _loadStatusCounts() async {
    final applications = await _dbService.fetchApplications();
    final counts = <String, int>{};

    for (var app in applications) {
      final status = app['status'] as String;
      counts[status] = (counts[status] ?? 0) + 1;
    }

    setState(() {
      statusCounts = counts;
    });
  }

  /// Fetches the list of applications from the database as a stream.
  Stream<List<Map<String, dynamic>>> fetchApplications() {
    return Stream.fromFuture(_dbService.fetchApplications());
  }

  /// Sorts the list of applications based on the selected sorting option.
  List<Map<String, dynamic>> _sortApplications(List<Map<String, dynamic>> apps) {
    switch (_sortOption) {
      case "Date Added (Ascending)":
        apps.sort((a, b) => a['date_added'].compareTo(b['date_added']));
        break;
      case "Date Added (Descending)":
        apps.sort((a, b) => b['date_added'].compareTo(a['date_added']));
        break;
      case "Alphabetical":
        apps.sort((a, b) {
          String companyA = a['company'].toString().toLowerCase();
          String companyB = b['company'].toString().toLowerCase();
          return companyA.compareTo(companyB);
        });
        break;
    }
    return apps;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: Scrollbar(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [   
                /// Builds the "Overview" section for the Dashboard tab.
                  if (_selectedTab == "Dashboard")
                    OverviewSection(statusCounts: statusCounts),
                  _buildSearchAndSortSection(),
                  const SizedBox(height: 20),
                /// Builds the list of applications based on the selected tab and search query.
                  ApplicationsList(
                    applicationStream: fetchApplications(),
                    searchQuery: _searchQuery,
                    selectedTab: _selectedTab,
                    sortApplications: _sortApplications,
                    onDelete: _deleteApplication,
                    onEdit: _editApplication,
                    onStatusCountsReload: _loadStatusCounts,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the AppBar with a TabBar for navigation.
  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Internship Application Organizer'),
      bottom: TabBar(
        isScrollable: true,
        onTap: (index) {
          setState(() {
            if (index == 0) {
              _selectedTab = "Dashboard";
            } else {
              _selectedTab = kApplicationStatuses[index - 1];
            }
          });
        },
        tabs: [
          const Tab(text: "Dashboard"),
          ...kApplicationStatuses.map((status) => Tab(text: status)),
        ],
      ),
    );
  }

  /// Builds the search and sorting section.
  Widget _buildSearchAndSortSection() {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            DropdownButton<String>(
              value: _sortOption,
              hint: const Text("Sort by"),
              items: ["Date Added (Ascending)", "Date Added (Descending)", "Alphabetical"]
                  .map((String value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _sortOption = value!;
                });
              },
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddApplicationScreen()),
                ).then((_) {
                  if (mounted) {
                    _loadStatusCounts();
                  }
                });
              },
              child: const Text("+ Add New"),
            ),
          ],
        ),
      ],
    );
  }

  /// Deletes an application and provides an undo option.
  void _deleteApplication(Map<String, dynamic> app) async {
    bool? shouldDelete = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete this application?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
    if (!mounted) return;

    if (shouldDelete == true) {
      deletedApplications.add(app);
      await _dbService.deleteApplication(app['id']);
      _loadStatusCounts();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Application deleted."),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () async {
                await _dbService.insertApplication(app);
                _loadStatusCounts();
              },
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  /// Navigates to the UpdateApplicationScreen to edit an application.
  void _editApplication(Map<String, dynamic> app) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UpdateApplicationScreen(applicationId: app['id'])),
    ).then((_) {
      if (mounted) {
        _loadStatusCounts();
      }
    });
  }
}
