import 'package:flutter/material.dart';
import 'package:party_planner/presentation/screens/party_screen.dart';
import 'package:provider/provider.dart';
import '../../core/utils/invitation_utils.dart';
import '../../data/models/party_model.dart';
import '../../providers/party_provider.dart';
import '../widgets/party_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {

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
          return PartyCard(
            party: party,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PartyScreen(party: party)),
              );
            },
            onInvitePressed: party.guests.isEmpty
                ? null
                : () async {
              await _sendInvitationsAndShowStatus(party);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context, //it tells flutter where in the widget tree we are
            MaterialPageRoute(builder: (context) => const PartyScreen()), //new page slide effect (navigation animation)
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _sendInvitationsAndShowStatus(Party party) async {
    final invitationResult = await Provider.of<PartyProvider>(context, listen: false)
        .inviteGuests(party);
    final failed = invitationResult["failed"]!;
    final missing = invitationResult["missing"]!;

    // Compute all guest names that have valid emails.
    final List<String> validGuestNames = party.guests
        .where((g) => g.email != null && g.email!.isNotEmpty)
        .map((g) => g.displayName)
        .toList();

    // If sending succeeded (i.e. no failures), assume all valid emails succeeded.
    final List<String> succeeded = failed.isEmpty ? validGuestNames : [];

    // Build the status message using the helper.
    final message = buildInvitationStatusMessage(
      succeeded: succeeded,
      failed: failed,
      missing: missing,
    );

    _showStatusDialog(message);
  }

  void _showStatusDialog(String message) {
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
}