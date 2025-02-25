import 'package:flutter/material.dart';
import 'package:party_planner/core/services/email_sender_service.dart';
import 'package:party_planner/core/utils/invitation_utils.dart';
import '../data/models/contact_model.dart';
import '../data/models/party_model.dart';
import '../data/repositories/party_repository.dart';
import '../domain/use_cases/upsert_party_use_case.dart';
import '../domain/use_cases/invite_guests_use_case.dart';

//PartyProvider stores the list of parties and updates the UI when changes happen.
//Handles state management and notifies UI of changes.
//ChangeNotifier is used for state management
class PartyProvider with ChangeNotifier {
  final PartyRepository _repository;
  final UpsertPartyUseCase _upsertPartyUseCase;
  final InviteGuestsUseCase _inviteGuestsUseCase;
  //final EmailSenderService _emailSenderService;
  List<Party> _parties = [];
  // Track the last invited state for each party by its ID.
  final Map<String, Party> _lastInvitedParties = {};

  PartyProvider(this._repository, EmailSenderService emailSenderService)
      : _upsertPartyUseCase = UpsertPartyUseCase(_repository),
        _inviteGuestsUseCase = InviteGuestsUseCase(emailSenderService) {
    //method executed when the constructor is called
    _loadParties();
  }

  //getter
  List<Party> get parties => _parties;

  void _loadParties() {
    _parties = _repository.loadParties();
    notifyListeners(); ////“Hey, something changed! Rebuild all widgets that use this provider.”
  }

  void upsertParty(Party party) {
    _upsertPartyUseCase.execute(party);
    notifyListeners();
  }

  Future<Map<String, List<String>?>> inviteGuests(Party party) async {
    Party? oldParty = _lastInvitedParties[party.id];
    final result = await _inviteGuestsUseCase.execute(newParty: party, oldParty: oldParty);

    // For both new invites and update emails, update the stored state.
    if ((result["invited"] != null && result["invited"]!.isNotEmpty) ||
        (result["updated"] != null && result["updated"]!.isNotEmpty)) {
      _lastInvitedParties[party.id] = party;
    }
    return result;
  }
}