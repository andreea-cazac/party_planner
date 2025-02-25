import 'package:flutter/material.dart';
import 'package:party_planner/core/services/email_sender_service.dart';
import 'package:provider/provider.dart';
import 'config/constants.dart';
import 'config/native_components.dart';
import 'presentation/screens/home_screen.dart';
import 'providers/party_provider.dart';
import 'data/repositories/party_repository.dart';
import 'dart:io' show Platform;

void main() {
  runApp(

    //MultiProvider is used to set up state management.
    MultiProvider(
      providers: [
        //ChangeNotifierProvider creates and provides the PartyProvider instance to the entire app.
        ChangeNotifierProvider(create: (context) => PartyProvider(PartyRepository(), EmailSenderService())),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  //avoid unnecessary rebuilds
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: const MyHomePage(title: appTitle), //home is for navigation
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  //Scaffold is the layout structure for single pages
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildNativeNavigationBar(title: title),
      body: const HomeScreen(),
    );
  }
}