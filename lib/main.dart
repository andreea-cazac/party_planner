import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/constants.dart';
import 'presentation/screens/home_screen.dart';
import 'providers/party_provider.dart';
import 'data/repositories/party_repository.dart';

void main() {
  runApp(

    //MultiProvider is used to set up state management.
    MultiProvider(
      providers: [

        //ChangeNotifierProvider creates and provides the PartyProvider instance to the entire app.
        ChangeNotifierProvider(create: (context) => PartyProvider(PartyRepository())),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  //avoid unnecessary rebuilds
  const MyApp({super.key});

  //MaterialApp is the root, provides global settings
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme,
      ),
      home: const MyHomePage(title: appTitle), //home is for navigation
    );
  }
}

class MyHomePage extends StatelessWidget {
  //avoid unnecessary rebuilds
  const MyHomePage({super.key, required this.title});

  final String title;

  //Scaffold is the layout structure for single pages
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.inversePrimary,
        title: Text(title),
        centerTitle: true, // Center the title for Android
      ),
      body: HomeScreen(), // body is for UI content
    );
  }
}