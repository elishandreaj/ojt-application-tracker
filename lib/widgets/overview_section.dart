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
          spacing: 10,                                            //horizontal spacing between boxes.
          runSpacing: 10,                                         //vertical spacing between boxes
          
          ////Gets the corresponding color for the status tag.
          children: kApplicationStatuses.map((tag) {
            final color = kStatusColors[tag] ?? Colors.grey;    

            //builds a card-like container for each status.
            return Container(
              //Calculates the width for each status box to be half of screen width minus spacing.
              width: (MediaQuery.of(context).size.width / 2) - 20 > 0
                  ? (MediaQuery.of(context).size.width / 2) - 20
                  : 0,
              height: 80,

              //Add colored bar on the left to indicate status type
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: color, width: 4),
                ),
                color: Colors.white,
                boxShadow: const [BoxShadow(color: Colors.grey, blurRadius: 4.0)],
                borderRadius: BorderRadius.circular(10),
              ),
              
              //Vertically stacks the count and label inside the box.
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
          }).toList(),    //Converts the results of .map() into a List<Widget> which is required by Wrap.
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
