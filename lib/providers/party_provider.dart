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
    //_repository.saveParties(_parties);
    notifyListeners();
  }

  Future<Map<String, List<String>>> inviteGuests(Party party) async {
    return await _inviteGuestsUseCase.execute(party);
  }
}