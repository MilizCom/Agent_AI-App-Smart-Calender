import 'package:agent_ai_calender/components/styles/input_decoration.dart';
import 'package:flutter/material.dart';

class TextFieldWithLeading {
  Stack build(
    String title, {
    required TextEditingController controller,
    required Color bgColor,
    required IconData icon,
    bool enabled = true,
    String? validator,
    bool obscureText = false,
  }) {
    return Stack(
      children: [
        TextFormField(
          controller: controller,
          validator: (value) {
            return value == '' ? (validator) : null;
          },
          decoration: StyleTextField().decoration(
            title,
            bgColor: bgColor,
            enabled: enabled,
            usePadding: true,
          ),
          obscureText: obscureText,
        ),
        Positioned(
          left: 16.0,
          top: 16.0,
          child: Icon(icon),
        ),
      ],
    );
  }
}
