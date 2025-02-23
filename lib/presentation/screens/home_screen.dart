import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/models/party_model.dart';
import '../../providers/party_provider.dart';
import 'add_party_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  Future<void> _sendInvitationsAndShowStatus(Party party) async {
    final invitationResult = await Provider.of<PartyProvider>(context, listen: false)
        .sendInvitationsForParty(party);
    final failed = invitationResult["failed"]!;
    final missing = invitationResult["missing"]!;

    // Compute all guest names that have valid emails.
    final List<String> validGuestNames = party.guests
        .where((g) => g.email != null && g.email!.isNotEmpty)
        .map((g) => g.displayName)
        .toList();

    // If sending succeeded (i.e. no failures), assume all valid emails succeeded.
    final List<String> succeeded = failed.isEmpty ? validGuestNames : [];

    String message = "";
    if (succeeded.isNotEmpty && failed.isEmpty && missing.isEmpty) {
      message = "All invitations were sent successfully!";
    } else {
      if (succeeded.isNotEmpty) {
        message += "Invitations sent successfully to: ${succeeded.join(', ')}.\n\n";
      }
      if (failed.isNotEmpty) {
        message += "Failed to send invitation to: ${failed.join(', ')}, because of a error of our system.\n\n";
      }
      if (missing.isNotEmpty) {
        message += "Failed to send invitation to: ${missing.join(', ')}, because no email have been provided by the contact.\n\n";
      }
    }

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Invitation Status"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

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
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(party.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${party.description}\n${DateFormat('dd/MM/yyyy HH:mm').format(party.date)}',
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    party.guests.isNotEmpty
                        ? "Guests: ${party.guests.map((g) => g.displayName).join(", ")}"
                        : "No guests added",
                    style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[700]),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.email),
                onPressed: party.guests.isEmpty
                    ? null
                    : () async {
                  // Send invitations using the PartyProvider method.
                  await _sendInvitationsAndShowStatus(party);
                },
              ),
            ),
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