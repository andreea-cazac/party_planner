import 'dart:io' show Platform;
import 'package:flutter/material.dart';

// Select the font based on the current platform.
final String defaultFontFamily = Platform.isIOS ? 'iOSFont' : 'AndroidFont';

const String appTitle = 'Party Planner';
final ColorScheme colorScheme = ColorScheme.fromSeed(seedColor: Colors.orange);

//global ThemeData that uses the platform-specific font.
final ThemeData appTheme = ThemeData(
  colorScheme: colorScheme,
  fontFamily: defaultFontFamily,
  // You can add additional styling here if needed.
);