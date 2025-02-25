import 'package:intl/intl.dart';
import '../../core/services/email_sender_service.dart';
import '../../core/utils/invitation_utils.dart';
import '../../data/models/party_model.dart';

class InviteGuestsUseCase {
  final EmailSenderService emailSenderService;
  InviteGuestsUseCase(this.emailSenderService);

  // Helper: returns a list of valid emails from the party's guests.
  List<String> _getValidEmails(Party party) {
    return party.guests
        .where((g) => g.email != null && g.email!.isNotEmpty)
        .map((g) => g.email!)
        .toList();
  }

  // Helper: returns a list of display names for guests with valid emails.
  List<String> _getValidDisplayNames(Party party) {
    return party.guests
        .where((g) => g.email != null && g.email!.isNotEmpty)
        .map((g) => g.displayName)
        .toList();
  }

  /// Sends invitations or update emails for a party.
  ///
  /// - If [oldParty] is null, sends invitations to all guests with valid emails.
  /// - If [oldParty] is provided (editing):
  ///    • If party details (name, description, date) have not changed, no email is sent.
  ///    • Otherwise, sends an update email to all valid emails.
  ///
  /// Returns a map with keys:
  ///   "invited": list of display names for invites (for new parties),
  ///   "updated": list of display names for update emails (for edited parties),
  ///   "missing": list of display names for guests missing an email.
  Future<Map<String, List<String>?>> execute({
    required Party newParty,
    Party? oldParty,
  }) async {
    // Process guest emails: separate valid from missing.
    final guestResult = processGuestEmails(newParty.guests);
    final missingEmails = guestResult.missingEmails;

    // New Party Scenario.
    if (oldParty == null) {
      final validEmails = _getValidEmails(newParty);
      // If no valid emails are available, return early.
      if (validEmails.isEmpty) {
        return {
          "invited": [],
          "updated": null,
          "missing": missingEmails,
          "failed": []
        };
      }

      try {
        // Attempt to send invitation emails.
        await emailSenderService.sendInvitationEmail(
          bccRecipients: validEmails,
          subject: "You're Invited to ${newParty.name}!",
          body: "Hi,\n\n${buildInvitationMessage(newParty)}",
        );
        final invited = _getValidDisplayNames(newParty);
        return {"invited": invited, "updated": null, "missing": missingEmails};
      } catch (error) {
        final failed = _getValidDisplayNames(newParty);
        return {"invited": [], "updated": null, "missing": missingEmails, "failed": failed};
      }
    } else {
      // Update Scenario.
      final detailsChanged = newParty.name != oldParty.name ||
          newParty.description != oldParty.description ||
          newParty.date != oldParty.date;
      if (!detailsChanged) {
        // No changes detected.
        return {"invited": [], "updated": [], "missing": missingEmails};
      }

      final updateEmails = _getValidEmails(newParty);
      try {
        // Attempt to send update emails.
        await emailSenderService.sendInvitationEmail(
          bccRecipients: updateEmails,
          subject: "UPDATE: ${newParty.name}",
          body: "Hi,\n\nThere were updates to the party you have been invited recently:\n\n${newParty.description}\n\nDate/Time: ${DateFormat('dd/MM/yyyy HH:mm').format(newParty.date)}",
        );
        final updated = _getValidDisplayNames(newParty);
        return {"invited": [], "updated": updated, "missing": missingEmails};
      } catch (error) {
        final failed = _getValidDisplayNames(newParty);
        return {"invited": [], "updated": [], "missing": missingEmails, "failed": failed};
      }
    }
  }
}