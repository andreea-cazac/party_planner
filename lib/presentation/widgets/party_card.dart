import 'package:flutter/material.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/party_model.dart';

class PartyCard extends StatelessWidget {
  final Party party;
  final VoidCallback onTap;
  final VoidCallback? onInvitePressed;

  const PartyCard({
    super.key,
    required this.party,
    required this.onTap,
    this.onInvitePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        onTap: onTap,
        title: Text(party.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${party.description}\n${formatPartyDate(party)}'),
            const SizedBox(height: 4.0),
            Text(
              party.guests.isNotEmpty
                  ? "Guests: ${party.guests.map((g) => g.displayName).join(', ')}"
                  : "No guests added",
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[700]),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.email),
          onPressed: party.guests.isEmpty ? null : onInvitePressed,
        ),
      ),
    );
  }
}