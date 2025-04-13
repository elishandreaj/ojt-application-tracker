import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/db_service.dart';
import '../utils/constants.dart';

class UpdateApplicationScreen extends StatefulWidget {
  final int applicationId;

  const UpdateApplicationScreen({super.key, required this.applicationId});

  @override
  UpdateApplicationScreenState createState() => UpdateApplicationScreenState();
}

class UpdateApplicationScreenState extends State<UpdateApplicationScreen> {
  final _formKey = GlobalKey<FormState>();

  /// Controllers for form fields.
  late TextEditingController companyNameController;
  late TextEditingController positionController;
  late TextEditingController locationController;
  late TextEditingController setupController;
  late TextEditingController statusController;
  late TextEditingController dateController;
  late TextEditingController notesController;

  late List<TextEditingController> requirementsControllers = [];

  Map<String, dynamic>? applicationData;
  String setUp = 'On-site';
  String applicationStatus = 'To Apply';

  @override
  void initState() {
    super.initState();
    _fetchApplicationData();
  }

  /// Fetches the application data from the database and initializes the form fields.
  Future<void> _fetchApplicationData() async {
    DatabaseService dbService = DatabaseService();
    List<Map<String, dynamic>> applications = await dbService.fetchApplications();

    // Find the application with the matching ID.
    var appData = applications.firstWhere(
      (app) => app['id'].toString() == widget.applicationId.toString(),
      orElse: () => {},
    );

    if (!mounted) return;

    setState(() {
      applicationData = appData;

      // Initialize controllers with the fetched data.
      companyNameController = TextEditingController(text: appData['company']);
      positionController = TextEditingController(text: appData['role']);
      locationController = TextEditingController(text: appData['location']);
      setupController = TextEditingController(text: appData['setup']);
      statusController = TextEditingController(text: appData['status']);
      dateController = TextEditingController(text: appData['date']);
      notesController = TextEditingController(text: appData['notes']);

      var requirements = appData['requirements'].toString().split(',');
      for (var req in requirements) {
        requirementsControllers.add(TextEditingController(text: req));
      }

      setUp = appData['setup'] ?? 'On-site';
      applicationStatus = appData['status'] ?? 'To Apply';
    });
  }

  /// Updates the application in the database with the modified data.
  void _updateApplication() async {
    if (_formKey.currentState!.validate()) {
            List<String> updatedRequirements = requirementsControllers
          .where((controller) => controller.text.isNotEmpty)
          .map((controller) => controller.text)
          .toList();

      // Prepare the updated data.
      Map<String, dynamic> updatedData = {
        'company': companyNameController.text,
        'role': positionController.text,
        'location': locationController.text,
        'setup': setUp,
        'status': applicationStatus,
        'date': dateController.text,
        'date_added': applicationData!['date_added'],
        'requirements': updatedRequirements.join(','),
        'notes': notesController.text,
      };

      try {
        DatabaseService dbService = DatabaseService();
        await dbService.updateApplication(widget.applicationId, updatedData);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application updated successfully!')),
        );
        Navigator.pop(context);
      }  catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating application: $e')),
        );
      }
    }
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
            padding: const EdgeInsets.all(10),
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
  void dispose() {
    // Dispose all controllers to free up resources.
    companyNameController.dispose();
    positionController.dispose();
    locationController.dispose();
    setupController.dispose();
    statusController.dispose();
    dateController.dispose();
    notesController.dispose();

    for (var controller in requirementsControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (applicationData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Internship Application'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              /// Company Name field.
              TextFormField(
                controller: companyNameController,
                decoration: const InputDecoration(labelText: 'Company Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a company name';
                  }
                  return null;
                },
              ),

              /// Position field.
              TextFormField(
                controller: positionController,
                decoration: const InputDecoration(labelText: 'Position'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a position';
                  }
                  return null;
                },
              ),

              /// Location field.
              TextFormField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),

              /// Setup type selection (On-site, Online, Hybrid).
              Row(
                children: [
                  Radio(
                    value: 'On-site',
                    groupValue: setUp,
                    onChanged: (value) {
                      setState(() {
                        setUp = value as String;
                      });
                    },
                  ),
                  const Text("On-site"),
                  Radio(
                    value: 'Online',
                    groupValue: setUp,
                    onChanged: (value) {
                      setState(() {
                        setUp = value as String;
                      });
                    },
                  ),
                  const Text("Online"),
                  Radio(
                    value: 'Hybrid',
                    groupValue: setUp,
                    onChanged: (value) {
                      setState(() {
                        setUp = value as String;
                      });
                    },
                  ),
                  const Text("Hybrid"),
                ],
              ),

              /// Application status dropdown.
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

              /// Date picker field.
              TextFormField(
                controller: dateController,
                decoration: const InputDecoration(
                  labelText: 'Date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: pickDate,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a date';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 10),

              /// Requirements section.
              const Text("Requirements"),
              ...List.generate(requirementsControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: TextFormField(
                    controller: requirementsControllers[index],
                    decoration: InputDecoration(
                      labelText: 'Requirement ${index + 1}',
                    ),
                  ),
                );
              }),
              TextButton(
                onPressed: () {
                  setState(() {
                    requirementsControllers.add(TextEditingController());
                  });
                },
                child: const Text("+ Add Requirement"),
              ),

              /// Notes field.
              TextFormField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),

              const SizedBox(height: 20),

              /// Submit button.
              ElevatedButton(
                onPressed: _updateApplication,
                child: const Text('Update Application'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}