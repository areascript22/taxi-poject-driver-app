import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData.light().copyWith(
  scaffoldBackgroundColor: Colors.white,
  brightness: Brightness.light,
  cardColor: const Color(0xFFE2F4FF),
  colorScheme: const ColorScheme.light(
    inversePrimary: Colors.black,
    primary: Color(0xFFF5F5F5),
    secondary: Colors.blue,
    tertiary: Colors.purple,
  ),

  textSelectionTheme: TextSelectionThemeData(
    cursorColor: Colors.black, // Set the cursor color to white
    selectionColor:
        Colors.black.withOpacity(0.4), // Color for selected text background
    selectionHandleColor: Colors.black, // Color of the selection handles
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFF5F5F5),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(
        color: Colors.black,
        width: 2,
      ),
      borderRadius: BorderRadius.circular(10),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(
        color: Colors.white,
        width: 2,
      ),
      borderRadius: BorderRadius.circular(10),
    ),
  ),
  //Elevated button
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.purple, // Blue background
      foregroundColor: Colors.white, // White text color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corners
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      elevation: 0, // Shadow effect
    ),
  ),
);

ThemeData darkMode = ThemeData.dark().copyWith(
  scaffoldBackgroundColor: Colors.black,
  brightness: Brightness.dark,
  cardColor: const Color(0xFF0C4769),
  colorScheme: const ColorScheme.dark(
    inversePrimary: Colors.white, //For icon (select profile image)
    primary: Color(0xFF323943),
    secondary: Color(0xFF252527),
    tertiary: Color(0xFF252527),
  ),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: Colors.white, // Set the cursor color to white
    selectionColor:
        Colors.white.withOpacity(0.4), // Color for selected text background
    selectionHandleColor: Colors.white, // Color of the selection handles
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xff3F4042),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(
        color: Colors.white,
        width: 2,
      ),
      borderRadius: BorderRadius.circular(10),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(
        color: Color(0xFF141414),
        width: 2,
      ),
      borderRadius: BorderRadius.circular(10),
    ),
  ),

  //Elevatted button
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.purple, // Slightly darker blue for dark mode
      foregroundColor: Colors.white, // White text color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corners
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      elevation: 0, // Shadow effect
    ),
  ),
);
