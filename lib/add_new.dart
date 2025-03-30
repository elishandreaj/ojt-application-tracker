import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(home: AddApplicationScreen()));
}

class AddApplicationScreen extends StatefulWidget {
  const AddApplicationScreen({super.key});

  @override
  AddApplicationScreenState createState() => AddApplicationScreenState();
}

class AddApplicationScreenState extends State<AddApplicationScreen> {
  final TextEditingController companyController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  String setUp = 'On-site';
  String applicationStatus = 'To Apply';
  List<TextEditingController> requirementsControllers = [];

  void addApplication() async {
    if (companyController.text.isNotEmpty && roleController.text.isNotEmpty) {
      List<String> requirements = requirementsControllers
          .where((controller) => controller.text.isNotEmpty)
          .map((controller) => controller.text)
          .toList();

      await FirebaseFirestore.instance.collection('applications').add({
        'company': companyController.text,
        'role': roleController.text,
        'location': locationController.text,
        'set-up': setUp,
        'status': applicationStatus,
        'date': dateController.text,
        'notes': notesController.text,
        'requirements': requirements,
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  void addRequirementField() {
    setState(() {
      requirementsControllers.add(TextEditingController());
    });
  }

  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add New Application')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: companyController,
                decoration: InputDecoration(labelText: 'Company'),
              ),
              TextField(
                controller: roleController,
                decoration: InputDecoration(labelText: 'Role'),
              ),
              TextField(
                controller: locationController,
                decoration: InputDecoration(labelText: 'Location'),
              ),
              SizedBox(height: 10),
              Text("Set-up"),
              Row(
                children: [
                  Radio(
                    value: 'On-site',
                    groupValue: setUp,
                    onChanged: (value) {
                      setState(() => setUp = value as String);
                    },
                  ),
                  Text("On-site"),
                  Radio(
                    value: 'Online',
                    groupValue: setUp,
                    onChanged: (value) {
                      setState(() => setUp = value as String);
                    },
                  ),
                  Text("Online"),
                  Radio(
                    value: 'Hybrid',
                    groupValue: setUp,
                    onChanged: (value) {
                      setState(() => setUp = value as String);
                    },
                  ),
                  Text("Hybrid"),
                ],
              ),
              TextField(
                controller: dateController,
                readOnly: true,
                onTap: pickDate,
                decoration: InputDecoration(
                  labelText: 'Date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
              ),
              SizedBox(height: 20),
              Text("Requirements", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Column(
                children: List.generate(requirementsControllers.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: TextField(
                      controller: requirementsControllers[index],
                      decoration: InputDecoration(
                        labelText: 'Requirement ${index + 1}',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              requirementsControllers.removeAt(index);
                            });
                          },
                        ),
                      ),
                    ),
                  );
                }),
              ),
              TextButton(
                onPressed: addRequirementField,
                child: Text("+ Add Requirement", style: TextStyle(color: Colors.blue)),
              ),
              SizedBox(height: 20),
              TextField(
                controller: notesController,
                decoration: InputDecoration(labelText: 'Notes'),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: addApplication,
                  child: Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}