import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'add_new.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
  final Map<String, Color> tagColors = {
    "To Apply": Colors.blue,
    "Applied": Colors.purple,
    "Interview": Colors.orange,
    "Accepted": Colors.green,
    "Rejected": Colors.red,
  };

  final Map<String, int> tagCounts = {
    "To Apply": 5,
    "Applied": 3,
    "Interview": 2,
    "Accepted": 4,
    "Rejected": 1,
  };

  Stream<List<Map<String, dynamic>>> fetchApplications() {
  return FirebaseFirestore.instance.collection('applications').snapshots().map((snapshot) {
    return snapshot.docs.map((doc) => doc.data()).toList();
  });
}

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Internship Application Organizer'),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: "Dashboard"),
              Tab(text: "To Apply"),
              Tab(text: "Applied"),
              Tab(text: "Interview"),
              Tab(text: "Accepted"),
              Tab(text: "Rejected"),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    "Overview",
                    style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,  // LORD NAIIYAK NA AKO AYAW NYA MAGPA LEFT!!!
                  ),
                ),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: tagCounts.keys.map((tag) {
                    return Container(
                      width: (MediaQuery.of(context).size.width / 2) - 20,
                      height: 80,
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: tagColors[tag]!, width: 4),
                        ),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(color: Colors.grey, blurRadius: 4.0),
                        ],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            tagCounts[tag].toString(),
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(tag, textAlign: TextAlign.center),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DropdownButton(
                      hint: Text("Sort by"),
                      items: ["Date Added (Ascending)", "Date Added (Descending)", "Alphabetical"].map((String value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {},
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AddApplicationScreen()),
                        );
                      },
                      child: Text("+ Add New"),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: fetchApplications(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final applications = snapshot.data!;
                    if (applications.isEmpty) {
                      return Center(child: Text("No applications yet."));
                    }

                    return SizedBox(
                      height: 300, 
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: BouncingScrollPhysics(),
                        itemCount: applications.length,
                        itemBuilder: (context, index) {
                          final app = applications[index];
                          return ApplicationCard(app);
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ApplicationCard extends StatelessWidget {
  final Map<String, dynamic> application;
  const ApplicationCard(this.application, {super.key});

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

    return Card(
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
    );
  }
}