import 'package:intl/intl.dart';
import '../../core/services/email_sender_service.dart';
import '../../core/utils/invitation_utils.dart';
import '../../data/models/party_model.dart';

class InviteGuestsUseCase {
  final EmailSenderService emailSenderService;
  InviteGuestsUseCase(this.emailSenderService);

  /// Sends a universal invitation email using BCC.
  /// Returns a map with "failed" and "missing" keys (lists of guest display names).
  Future<Map<String, List<String>>> execute(Party party) async {
    final guestResult = processGuestEmails(party.guests);
    final validEmails = guestResult.validEmails;
    final missingEmails = guestResult.missingEmails;
    final details = buildInvitationMessage(party);

    try {
      if (validEmails.isNotEmpty) {
        await emailSenderService.sendInvitationEmail(
          bccRecipients: validEmails,
          subject: "You're Invited to ${party.name}!",
          body: "Hi,\n\n$details",
        );
      }
      return {"failed": [], "missing": missingEmails};
    } catch (error) {
      final failed = party.guests
          .where((g) => g.email != null && g.email!.isNotEmpty)
          .map((g) => g.displayName)
          .toList();
      return {"failed": failed, "missing": missingEmails};
    }
  }
}