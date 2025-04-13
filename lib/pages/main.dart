import 'package:flutter/material.dart';
import 'add_new.dart';
import 'update_app.dart';
import 'view_app.dart';
import '../services/db_service.dart';
import '../widgets/application_card.dart';
import '../utils/constants.dart';

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
                  if (_selectedTab == "Dashboard") _buildOverviewSection(),
                  _buildSearchAndSortSection(),
                  const SizedBox(height: 20),
                  _buildApplicationsList(),
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

  /// Builds the "Overview" section for the Dashboard tab.
  Widget _buildOverviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Overview",
            style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: tagColors.keys.map((tag) {
            return Container(
              width: (MediaQuery.of(context).size.width / 2) - 20 > 0
                  ? (MediaQuery.of(context).size.width / 2) - 20
                  : 0,
              height: 80,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: tagColors[tag]!, width: 4),
                ),
                color: Colors.white,
                boxShadow: const [BoxShadow(color: Colors.grey, blurRadius: 4.0)],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${statusCounts[tag] ?? 0}",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(tag, textAlign: TextAlign.center),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
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

  /// Builds the list of applications based on the selected tab and search query.
  Widget _buildApplicationsList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: fetchApplications(),
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

          final matchesRequirements = requirements.any((req) => req.contains(_searchQuery.toLowerCase()));

          // Check if the search query matches any of the fields
          final matchesSearchQuery = company.contains(_searchQuery.toLowerCase()) ||
              role.contains(_searchQuery.toLowerCase()) ||
              location.contains(_searchQuery.toLowerCase()) ||
              status.contains(_searchQuery.toLowerCase()) ||
              date.contains(_searchQuery.toLowerCase()) ||
              setup.contains(_searchQuery.toLowerCase()) ||
              matchesRequirements;

          final matchesStatus = _selectedTab == "Dashboard" || status == _selectedTab.toLowerCase();

          return matchesSearchQuery && matchesStatus;
        }).toList();

        if (filteredApplications.isEmpty) {
          return const Center(child: Text("No applications found."));
        }

        final sortedApplications = _sortApplications(filteredApplications);

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
                if (mounted) {
                  await _loadStatusCounts();
                  setState(() {});
                }
              },
              child: ApplicationCard(
                application: app,
                onDelete: () => _deleteApplication(app),
                onEdit: () => _editApplication(app),
              ),
            );
          }).toList(),
        );
      },
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
