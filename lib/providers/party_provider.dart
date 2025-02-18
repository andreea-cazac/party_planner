import 'package:flutter/material.dart';
import '../data/models/party_model.dart';
import '../data/repositories/party_repository.dart';
import '../domain/use_cases/add_party_use_case.dart';

//PartyProvider stores the list of parties and updates the UI when changes happen.
//Handles state management and notifies UI of changes.
//ChangeNotifier is used for state management
class PartyProvider with ChangeNotifier {
  final PartyRepository _repository;
  final AddPartyUseCase _addPartyUseCase;
  List<Party> _parties = [];

  PartyProvider(this._repository) : _addPartyUseCase = AddPartyUseCase(_repository) {
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

  void addParty(String name, String description, DateTime date) {
    final party = Party(
      id: Party.generateId(),
      name: name,
      description: description,
      date: date,
    );

    _addPartyUseCase.execute(party, _parties);
    notifyListeners();
  }

  //editParty()

  //addGuest()

  //send invite()
}