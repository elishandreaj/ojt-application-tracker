import 'package:flutter/material.dart';

/// Status options for dropdowns, filtering, etc.
const List<String> kApplicationStatuses = [
  "To Apply",
  "Applied",
  "Interview",
  "Accepted",
  "Rejected",
];

/// Status tag colors for UI indicators
const Map<String, Color> kStatusColors = {
  "To Apply": Colors.blue,
  "Applied": Colors.purple,
  "Interview": Colors.orange,
  "Accepted": Colors.green,
  "Rejected": Colors.red,
};
