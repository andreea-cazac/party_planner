import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

Route createRoute(Widget page) {
  return Platform.isIOS
      ? CupertinoPageRoute(builder: (context) => page)
      : MaterialPageRoute(builder: (context) => page);
}