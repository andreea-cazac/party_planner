import 'package:intl/intl.dart';
import '../../core/services/email_sender_service.dart';
import '../../core/utils/invitation_utils.dart';
import '../../data/models/party_model.dart';

class InviteGuestsUseCase {
  final EmailSenderService emailSenderService;
  InviteGuestsUseCase(this.emailSenderService);

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
  Future<Map<String, List<String>>> execute({
    required Party newParty,
    Party? oldParty,
  }) async {
    // Process guest emails: separate those with valid emails from those missing an email.
    final guestResult = processGuestEmails(newParty.guests);
    final missingEmails = guestResult.missingEmails;

    if (oldParty == null) {
      // **New Party Scenario:**
      // We're dealing with a newly created party.
      final validEmails = newParty.guests
          .where((g) => g.email != null && g.email!.isNotEmpty)
          .map((g) => g.email!)
          .toList();

      // If no valid emails are available, we return a result indicating nothing was triggered.
      if (validEmails.isEmpty) {
        return {"invited": [], "updated": [], "missing": [], "failed": []};
      }

      try {
        if (validEmails.isNotEmpty) {
          // Attempt to send invitation emails to all valid emails.
          await emailSenderService.sendInvitationEmail(
            bccRecipients: validEmails,
            subject: "You're Invited to ${newParty.name}!",
            body: "Hi,\n\n${buildInvitationMessage(newParty)}",
          );
        }
        // Build a list of display names for guests who have a stored email
        final invited = newParty.guests
            .where((g) => g.email != null && g.email!.isNotEmpty)
            .map((g) => g.displayName)
            .toList();
        return {"invited": invited, "updated": [], "missing": missingEmails};
      } catch (error) {
        // If an error occurs, mark the email sending as failed for all valid-email guests.
        final failed = newParty.guests
            .where((g) => g.email != null && g.email!.isNotEmpty)
            .map((g) => g.displayName)
            .toList();
        return {"invited": [], "updated": [], "missing": missingEmails, "failed": failed};
      }
    } else {
      // **Update Scenario:**
      // We have an old party state, so we are editing an existing party.
      // Determine if any of the core details (name, description, date) have changed.
      final detailsChanged = newParty.name != oldParty.name ||
          newParty.description != oldParty.description ||
          newParty.date != oldParty.date;
      if (!detailsChanged) {
        // No changes detected: no update email is sent.
        return {"invited": [], "updated": [], "missing": missingEmails};
      }
      // Build a list of valid email addresses from the new party's guest list.
      final updateEmails = newParty.guests
          .where((g) => g.email != null && g.email!.isNotEmpty)
          .map((g) => g.email!)
          .toList();
      try {
        // Attempt to send update emails to all valid emails.
        await emailSenderService.sendInvitationEmail(
          bccRecipients: updateEmails,
          subject: "UPDATE: ${newParty.name}",
          body: "Hi,\n\nThere were updates to the party you have been invited recently:\n\n${newParty.description}\n\nDate/Time: ${DateFormat('dd/MM/yyyy HH:mm').format(newParty.date)}",
        );
        // Build a list of display names for guests who received the update.
        final updated = newParty.guests
            .where((g) => g.email != null && g.email!.isNotEmpty)
            .map((g) => g.displayName)
            .toList();
        return {"invited": [], "updated": updated, "missing": missingEmails};
      } catch (error) {
        final failed = newParty.guests
            .where((g) => g.email != null && g.email!.isNotEmpty)
            .map((g) => g.displayName)
            .toList();
        return {"invited": [], "updated": [], "missing": missingEmails, "failed": failed};
      }
    }
  }
}