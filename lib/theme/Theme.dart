import 'dart:ffi';

import 'package:flutter/material.dart';

class Themes {
  static final light = ThemeData.light().copyWith(
    backgroundColor: Colors.white,
    primaryColor: Colors.purple,
    accentColor: Colors.purple[300],
    iconTheme: IconThemeData(color: Colors.purple),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return Colors.grey; // Disabled color
          }
          return Colors.white; // Regular color
        }),
        foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return Colors.white; // Disabled color
          }
          return Colors.purple; // Regular color
        }),
        elevation: MaterialStateProperty.resolveWith<double>((states) {
          return 10.0;
        })
      )
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(),
      focusedBorder: OutlineInputBorder(),
    ),
  );
}