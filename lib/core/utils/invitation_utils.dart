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
  required List<String>? updated,
  required List<String> missing,
}) {

  List<String> messageParts = [];

  // Determine the scenario.
  final bool isUpdateScenario = updated != null;
  final bool hasInvitations = invited.isNotEmpty;
  final bool hasUpdates = updated != null && updated.isNotEmpty;

  if (isUpdateScenario) {
    // Update scenario: updated is non-null.
    if (!hasInvitations && !hasUpdates) {
      // No invitations or updates were sent.
      messageParts.add(
          "No new updates have been done. Update the party if you want to send an update to the invited guests."
      );
    } else {
      if (hasInvitations) {
        messageParts.add("Invitation emails have been created for: ${invited.join(', ')}");
      }
      if (hasUpdates) {
        messageParts.add("Update emails have been created for: ${updated!.join(', ')}");
      }
    }
  } else {
    // New party scenario: updated is null.
    if (hasInvitations) {
      messageParts.add("Invitation emails have been created for: ${invited.join(', ')}");
    }
  }

  // Always add missing email info if present.
  if (missing.isNotEmpty) {
    messageParts.add("No email provided for: ${missing.join(', ')}");
  }

  return messageParts.join("\n\n");
}