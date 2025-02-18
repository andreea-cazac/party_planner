import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/party_provider.dart';
import 'add_party_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    //listen for changes, to update the UI when new parties are added
    final partyProvider = Provider.of<PartyProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Upcoming Parties')),
      body: ListView.builder(
        itemCount: partyProvider.parties.length,
        itemBuilder: (context, index) {
          final party = partyProvider.parties[index];
          return ListTile(
            title: Text(party.name),
            subtitle: Text('${party.description}\n${DateFormat('dd/MM/yyyy HH:mm').format(party.date)}'),
            //isThreeLine: true,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context, //it tells flutter where in the widget tree we are
            MaterialPageRoute(builder: (context) => AddPartyScreen()), //new page slide effect (navigation animation)
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}