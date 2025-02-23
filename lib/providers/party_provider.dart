import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:party_planner/core/services/email_sender_service.dart';
import '../data/models/contact_model.dart';
import '../data/models/party_model.dart';
import '../data/repositories/party_repository.dart';
import '../domain/use_cases/add_party_use_case.dart';

//PartyProvider stores the list of parties and updates the UI when changes happen.
//Handles state management and notifies UI of changes.
//ChangeNotifier is used for state management
class PartyProvider with ChangeNotifier {
  final PartyRepository _repository;
  final AddPartyUseCase _addPartyUseCase;
  final EmailSenderService _emailSenderService;
  List<Party> _parties = [];

  PartyProvider(this._repository, this._emailSenderService) : _addPartyUseCase = AddPartyUseCase(_repository) {
    //method executed when the constructor is called
    _loadParties();
  }

  //getter
  List<Party> get parties => _parties;

  void _loadParties() {
    _parties = _repository.loadParties();

    //“Hey, something changed! Rebuild all widgets that use this provider.”
    notifyListeners();
  }

  void addParty(String name, String description, DateTime date, {List<ContactModel>? guests}) {
    final party = Party(
      id: Party.generateId(),
      name: name,
      description: description,
      date: date,
      guests: guests ?? [], // Default to an empty list if guests is null. Because guests is optional
    );

    _addPartyUseCase.execute(party, _parties);
    notifyListeners();
  }

  /// Sends one universal invitation email using BCC.
  /// Returns a Map with two keys:
  ///   "failed": a list of guest display names for whom the invitation failed (e.g. if sending throws an error),
  ///   "missing": a list of guest display names that have no email.
  Future<Map<String, List<String>>> sendInvitationsForParty(Party party) async {
    // Separate guests based on email availability.
    final List<String> validEmails = [];
    final List<String> missingEmails = [];
    for (final guest in party.guests) {
      if (guest.email == null || guest.email!.isEmpty) {
        missingEmails.add(guest.displayName);
      } else {
        validEmails.add(guest.email!);
      }
    }

    // Build a universal invitation message from the party details.
    final details = "You're invited to ${party.name} on ${DateFormat('dd/MM/yyyy HH:mm').format(party.date)}.\n\n${party.description}";

    try {
      if (validEmails.isNotEmpty) {
        await _emailSenderService.sendInvitationEmail(
          bccRecipients: validEmails,
          subject: "You're Invited to ${party.name}!",
          body: "Hi,\n\n$details",
        );
      }
      // If sending succeeds, no failures occur.
      return {"failed": [], "missing": missingEmails};
    } catch (error) {
      // If sending fails, assume that all valid-email guests failed.
      final failed = party.guests
          .where((g) => g.email != null && g.email!.isNotEmpty)
          .map((g) => g.displayName)
          .toList();
      return {"failed": failed, "missing": missingEmails};
    }
  }
}