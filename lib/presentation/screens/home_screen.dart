import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:party_planner/presentation/screens/party_screen.dart';
import 'package:provider/provider.dart';
import '../../config/native_components.dart';
import '../../core/utils/invitation_utils.dart';
import '../../data/models/party_model.dart';
import '../../providers/party_provider.dart';
import '../../routes/app_router.dart';
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
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: const Text(
            'Upcoming Parties',
            style: TextStyle(
              color: Colors.orange, // Title color set to orange.
              fontSize: 20,          // Android-specific font size.
            ),
          ),
        ),
        centerTitle: true, // Centers the title on Android.
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: ListView.builder(
        itemCount: partyProvider.parties.length,
        itemBuilder: (context, index) {
          final party = partyProvider.parties[index];
          return PartyCard(
            party: party,
            onTap: () {
              Navigator.of(context).push(createRoute(PartyScreen(party: party)));
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
          Navigator.of(context).push(createRoute(PartyScreen()));
        },
        child: Icon(getNativeIcon(
          materialIcon: Icons.add_circle_outline,
          cupertinoIcon: CupertinoIcons.add,
        )),
      ),
    );
  }

  Future<void> _sendInvitationsAndShowStatus(Party party) async {
    final result = await Provider.of<PartyProvider>(context, listen: false)
        .inviteGuests(party);

    // Cast each returned list to List<String>.
    final List<String> invited = List<String>.from(result["invited"] ?? []);
    final List<String>? updated = result["updated"];
    final List<String> missing = List<String>.from(result["missing"] ?? []);

    // Build the status message using our helper.
    final message = buildInvitationStatusMessage(
      invited: invited,
      updated: updated,
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