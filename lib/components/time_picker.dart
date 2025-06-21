import 'package:agent_ai_calender/components/styles/button_style.dart';
import 'package:flutter/material.dart';

class TimePickerComponent {
  Map<dynamic, dynamic> schedules = {};

  Widget timeInput({
    required BuildContext context,
    required String label,
    required Function(String) onSelected,
  }) {
    return Container(
      width: 100,
      child: ElevatedButton(
        onPressed: () async {
          TimeOfDay? picked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (picked != null) {
            final hour = picked.hour.toString().padLeft(2, '0');
            final minute = picked.minute.toString().padLeft(2, '0');
            onSelected("$hour.$minute");
          }
        },
        style: StyleButton().decoration(
          bgColor: Color.fromARGB(255, 0, 201, 211),
          padding: EdgeInsets.all(8.0),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.grey[900],
          ),
        ),
      ),
    );
  }
}
