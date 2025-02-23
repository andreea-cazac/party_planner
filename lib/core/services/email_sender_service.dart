import 'package:flutter_email_sender/flutter_email_sender.dart';

class EmailSenderService {
  Future<void> sendInvitationEmail({
    required List<String> bccRecipients,
    required String subject,
    required String body,
  }) async {
    final Email email = Email(
      body: body,
      subject: subject,
      bcc: bccRecipients,
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
    } catch (error) {
      rethrow;
    }
  }
}