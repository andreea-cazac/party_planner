import 'package:intl/intl.dart';
import '../../data/models/party_model.dart';
import '../../data/models/contact_model.dart';

/// Builds a universal invitation message for the given party.
String buildInvitationMessage(Party party) {
  return "You're invited to ${party.name} on ${DateFormat('dd/MM/yyyy HH:mm').format(party.date)}.\n\n${party.description}";
}

/// Represents the result of processing a list of guest contacts.
class GuestEmailResult {
  final List<String> validEmails;
  final List<String> missingEmails;

  GuestEmailResult({required this.validEmails, required this.missingEmails});
}

/// Processes a list of guest contacts, separating those with valid email addresses
/// from those missing an email. Returns a GuestEmailResult.
GuestEmailResult processGuestEmails(List<ContactModel> guests) {
  final validEmails = <String>[];
  final missingEmails = <String>[];

  for (final guest in guests) {
    if (guest.email == null || guest.email!.isEmpty) {
      missingEmails.add(guest.displayName);
    } else {
      validEmails.add(guest.email!);
    }
  }
  return GuestEmailResult(validEmails: validEmails, missingEmails: missingEmails);
}

/// Builds a status message for the current invitation process.
String buildInvitationStatusMessage({
  required List<String> invited,
  required List<String> updated,
  required List<String> missing,
}) {
  // If neither invites nor updates were sent, return a neutral message.
  if (invited.isEmpty && updated.isEmpty) {
    return "No new updates have been done. Update the party if you want to send an update to the invited guests.";
  }

  String message = "";

  if (invited.isNotEmpty) {
    message += "Invitation emails sent to:\n\n${invited.join(', ')}";
  }

  if (updated.isNotEmpty) {
    if (message.isNotEmpty) message += "\n\n";
    message += "Update emails sent to:\n\n${updated.join(', ')}";
  }

  if (missing.isNotEmpty) {
    if (message.isNotEmpty) message += "\n\n";
    message += "No email provided for:\n\n${missing.join(', ')}";
  }

  return message;
}