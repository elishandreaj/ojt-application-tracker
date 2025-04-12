import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';   
import 'add_new.dart';
import 'update_app.dart';
import 'view_app.dart';
import '../services/db_service.dart';

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

  final Map<String, Color> tagColors = {
    "To Apply": Colors.blue,
    "Applied": Colors.purple,
    "Interview": Colors.orange,
    "Accepted": Colors.green,
    "Rejected": Colors.red,
  };

  String _sortOption = "Date Added (Ascending)";
  String _selectedTab = "Dashboard"; 
  Map<String, int> statusCounts = {};
  final TextEditingController _searchController = TextEditingController();
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

  Stream<List<Map<String, dynamic>>> fetchApplications() {
    return Stream.fromFuture(_dbService.fetchApplications());
  }

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
        appBar: AppBar(
          title: const Text('Internship Application Organizer'),
          bottom: TabBar(
            isScrollable: true,
            onTap: (index) {
              setState(() {
                switch (index) {
                  case 0:
                    _selectedTab = "Dashboard";
                    break;
                  case 1:
                    _selectedTab = "To Apply";
                    break;
                  case 2:
                    _selectedTab = "Applied";
                    break;
                  case 3:
                    _selectedTab = "Interview";
                    break;
                  case 4:
                    _selectedTab = "Accepted";
                    break;
                  case 5:
                    _selectedTab = "Rejected";
                    break;
                }
              });
            },
            tabs: const [
              Tab(text: "Dashboard"),
              Tab(text: "To Apply"),
              Tab(text: "Applied"),
              Tab(text: "Interview"),
              Tab(text: "Accepted"),
              Tab(text: "Rejected"),
            ],
          ),
        ),
        body: Scrollbar(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectedTab == "Dashboard") ...[
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
                  const SizedBox(height: 20),

                  StreamBuilder<List<Map<String, dynamic>>>(
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

                        final matchesSearchQuery = company.contains(_searchQuery.toLowerCase()) ||
                            role.contains(_searchQuery.toLowerCase()) ||
                            location.contains(_searchQuery.toLowerCase()) ||
                            status.contains(_searchQuery.toLowerCase()) ||
                            date.contains(_searchQuery.toLowerCase());

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
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ViewApplicationPage(application: app),
                                ),
                              );
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _deleteApplication(Map<String, dynamic> app) async {
  bool? shouldDelete = await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Confirm Deletion"),
        content: Text("Are you sure you want to delete this application?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text("Delete"),
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

class ApplicationCard extends StatelessWidget {
  final Map<String, dynamic> application;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const ApplicationCard({
    super.key, 
    required this.application, 
    required this.onDelete, 
    required this.onEdit
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

    String displayDate = application['status'] == "To Apply"
        ? "Deadline: ${application['date']}"
        : "Applied: ${application['date']}";

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
            padding: EdgeInsets.symmetric(horizontal: 10), 
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