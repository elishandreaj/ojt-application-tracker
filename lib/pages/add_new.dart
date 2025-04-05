import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/db_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  List<TextEditingController> requirementsControllers = [];

  String setUp = 'On-site';
  String applicationStatus = 'To Apply';

  @override
  void initState() {
    super.initState();
    // Start with one empty requirement field
    addRequirementField();
  }

  @override
  void dispose() {
    companyController.dispose();
    roleController.dispose();
    locationController.dispose();
    dateController.dispose();
    notesController.dispose();

    for (var controller in requirementsControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  void addApplication() async {
    if (companyController.text.isEmpty || roleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Company and Role are required!")),
      );
      return;
    }

    List<String> requirements = requirementsControllers
        .where((controller) => controller.text.isNotEmpty)
        .map((controller) => controller.text)
        .toList();

    try {
      await DatabaseService().insertApplication({
        'company': companyController.text,
        'role': roleController.text,
        'location': locationController.text,
        'setup': setUp,
        'status': applicationStatus,
        'date': dateController.text,
        'requirements': requirements.join(','),
        'notes': notesController.text,
      });

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add application: $e")),
      );
    }
  }

  void addRequirementField() {
    setState(() {
      requirementsControllers.add(TextEditingController());
    });
  }

  void removeRequirementField(int index) {
    setState(() {
      requirementsControllers[index].dispose(); // properly dispose
      requirementsControllers.removeAt(index);
    });
  }

  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(10),
            child: child,
          ),
        );
      },
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
                key: Key('company'),
                controller: companyController,
                decoration: InputDecoration(labelText: 'Company'),
                autofillHints: [AutofillHints.organizationName],
              ),
              TextField(
                key: Key('role'),
                controller: roleController,
                decoration: InputDecoration(labelText: 'Role'),
                autofillHints: [AutofillHints.jobTitle],
              ),
              TextField(
                key: Key('location'),
                controller: locationController,
                decoration: InputDecoration(labelText: 'Location'),
                autofillHints: [AutofillHints.location],
              ),
              SizedBox(height: 10),

              Text("Set-up", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Radio(value: 'On-site', groupValue: setUp, onChanged: (value) {
                    setState(() => setUp = value as String);
                  }),
                  Text("On-site"),
                  Radio(value: 'Online', groupValue: setUp, onChanged: (value) {
                    setState(() => setUp = value as String);
                  }),
                  Text("Online"),
                  Radio(value: 'Hybrid', groupValue: setUp, onChanged: (value) {
                    setState(() => setUp = value as String);
                  }),
                  Text("Hybrid"),
                ],
              ),

              SizedBox(height: 10),
              Text("Application Status", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: applicationStatus,
                isExpanded: true,
                items: ["To Apply", "Applied", "Interview", "Accepted", "Rejected"]
                    .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    applicationStatus = value!;
                  });
                },
              ),

              SizedBox(height: 10),
              TextField(
                key: Key('date'),
                controller: dateController,
                readOnly: true,
                onTap: pickDate,
                decoration: InputDecoration(
                  labelText: 'Date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                autofillHints: [AutofillHints.birthday],
              ),

              SizedBox(height: 20),
              Text("Requirements", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Column(
                children: List.generate(requirementsControllers.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: TextField(
                      key: Key('requirement_$index'),
                      controller: requirementsControllers[index],
                      decoration: InputDecoration(
                        labelText: 'Requirement ${index + 1}',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () => removeRequirementField(index),
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
                key: Key('notes'),
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