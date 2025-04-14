import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/db_service.dart';
import '../utils/constants.dart';

class AddApplicationScreen extends StatefulWidget {
  const AddApplicationScreen({super.key});

  @override
  AddApplicationScreenState createState() => AddApplicationScreenState();
}

class AddApplicationScreenState extends State<AddApplicationScreen> {
  /// Controllers for form fields.
  final TextEditingController companyController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  List<TextEditingController> requirementsControllers = [];

  final _formKey = GlobalKey<FormState>();

  String setUp = 'On-site';
  String applicationStatus = 'To Apply';

  @override
  void initState() {
    super.initState();
    addRequirementField();
  }

  @override
  void dispose() {
    // Dispose all controllers to free up resources.
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

  /// Adds a new requirement field.
  void addRequirementField() {
    setState(() {
      requirementsControllers.add(TextEditingController());
    });
  }

    void removeRequirementField(int index) {
    setState(() {
      requirementsControllers[index].dispose();
      requirementsControllers.removeAt(index);
    });
  }

  /// Opens a date picker dialog and sets the selected date in the date field.
  Future<void> pickDate() async {
    DateTime now = DateTime.now();

    DateTime firstDate;
    DateTime lastDate;

    if (['To Apply', 'Interview'].contains(applicationStatus)) {
      firstDate = now;
      lastDate = DateTime(2100);
    } else {
      firstDate = DateTime(2000);
      lastDate = now;
    }

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate,
      lastDate: lastDate,
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

  /// Submits the application by saving it to the database.
  void addApplication() async {
    if (_formKey.currentState!.validate()) {
      // Collect all non-empty requirements.
      List<String> requirements = requirementsControllers
          .where((controller) => controller.text.isNotEmpty)
          .map((controller) => controller.text)
          .toList();

      try {
        // Insert the application into the database.
        await DatabaseService().insertApplication({
          'company': companyController.text,
          'role': roleController.text,
          'location': locationController.text,
          'setup': setUp,
          'status': applicationStatus,
          'date': dateController.text,
          'date_added': DateFormat('yyyy-MM-dd').format(DateTime.now()),
          'requirements': requirements.join(','),
          'notes': notesController.text,
        });

        if (!mounted) return;

        // Show success message and navigate back.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Application added successfully!')),
        );
        Navigator.pop(context);
      } catch (e) {
        // Show error message if the operation fails.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to add application: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add New Application')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Company field.
                TextFormField(
                  key: Key('company'),
                  controller: companyController,
                  decoration: InputDecoration(labelText: 'Company'),
                  autofillHints: [AutofillHints.organizationName],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Company is required';
                    }
                    return null;
                  },
                ),

                /// Role field.
                TextFormField(
                  key: Key('role'),
                  controller: roleController,
                  decoration: InputDecoration(labelText: 'Role'),
                  autofillHints: [AutofillHints.jobTitle],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Role is required';
                    }
                    return null;
                  },
                ),

                /// Location field.
                TextFormField(
                  key: Key('location'),
                  controller: locationController,
                  decoration: InputDecoration(labelText: 'Location'),
                  autofillHints: [AutofillHints.location],
                ),
                SizedBox(height: 10),

                /// Setup type selection (On-site, Online, Hybrid).
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

                /// Application status dropdown.
                Text("Application Status", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                DropdownButton<String>(
                  value: applicationStatus,
                  isExpanded: true,
                  items: kApplicationStatuses
                      .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      applicationStatus = value!;
                    });
                  },
                ),

                SizedBox(height: 10),

                /// Date picker field.
                TextFormField(
                  key: Key('date'),
                  controller: dateController,
                  readOnly: true,
                  onTap: pickDate,
                  decoration: InputDecoration(
                    labelText: 'Date',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Date is required';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 20),

                /// Requirements section.
                Text("Requirements", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Column(
                  children: List.generate(requirementsControllers.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: TextFormField(
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

                /// Notes field.
                TextFormField(
                  key: Key('notes'),
                  controller: notesController,
                  decoration: InputDecoration(labelText: 'Notes'),
                ),

                SizedBox(height: 20),

                /// Submit button.
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
      ),
    );
  }
}