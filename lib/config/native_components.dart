import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'constants.dart';

/// Returns a native navigation bar based on the current platform.
PreferredSizeWidget buildNativeNavigationBar({required String title}) {
  if (Platform.isIOS) {
    return CupertinoNavigationBar(
      middle: Text(
        title,
        style: TextStyle(
          fontSize: 25, // Increase font size as needed
          color: colorScheme.onPrimary,
        ),
      ),
      backgroundColor: colorScheme.inversePrimary,
    );
  } else {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 30, // Adjust font size for Android
          fontWeight: FontWeight.bold,
          color: colorScheme.onPrimary,
        ),
      ),
      backgroundColor: colorScheme.inversePrimary,
      centerTitle: true,
    );
  }
}

/// Returns a native icon.
/// You can provide the Material icon and the Cupertino icon.
IconData getNativeIcon({required IconData materialIcon, required IconData cupertinoIcon}) {
  return Platform.isIOS ? cupertinoIcon : materialIcon;
}