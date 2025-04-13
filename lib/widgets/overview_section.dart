import 'package:flutter/material.dart';
import '../utils/constants.dart'; 

/// Builds the "Overview" section for the Dashboard tab.
class OverviewSection extends StatelessWidget {
  final Map<String, int> statusCounts;

  const OverviewSection({
    super.key,
    required this.statusCounts,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Align(
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
          children: kApplicationStatuses.map((tag) {
            final color = kStatusColors[tag] ?? Colors.grey;

            return Container(
              width: (MediaQuery.of(context).size.width / 2) - 20 > 0
                  ? (MediaQuery.of(context).size.width / 2) - 20
                  : 0,
              height: 80,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: color, width: 4),
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
}
