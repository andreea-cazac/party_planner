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

/// Builds a status message for the invitation process.
String buildInvitationStatusMessage({
  required List<String> succeeded,
  required List<String> failed,
  required List<String> missing,
}) {
  String message = "";
  if (succeeded.isNotEmpty && failed.isEmpty && missing.isEmpty) {
    message = "Invitations sent successfully to everyone!";
  } else {
    if (succeeded.isNotEmpty) {
      message += "Invitations sent successfully to:\n\n${succeeded.join(', ')}\n\n";
    }
    if (failed.isNotEmpty) {
      message += "Failed to send invitation to:\n\n${failed.join(', ')}\n\n";
    }
    if (missing.isNotEmpty) {
      message += "Failed to send invitation to:\n\n${missing.join(', ')} because no email was provided by the contact.";
    }
  }
  return message;
}