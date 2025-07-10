import 'package:flutter/material.dart';

class StyleTextField {
  InputDecoration decoration(
    String hint, {
    required Color bgColor,
    bool enabled = true,
    bool usePadding = false,
    IconData? icon, // ⬅️ Tambahkan icon opsional
  }) {
    return InputDecoration(
      contentPadding: usePadding
          ? const EdgeInsets.only(
              left: 48.0,
              right: 16.0,
              top: 16.0,
              bottom: 16.0,
            )
          : const EdgeInsets.all(16.0),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      enabled: enabled,
      fillColor: bgColor,
      filled: true,
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon) : null, // ⬅️ Tambahkan icon di kiri
    );
  }
}
