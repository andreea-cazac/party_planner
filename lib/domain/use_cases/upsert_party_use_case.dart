import '../../data/models/party_model.dart';
import '../../data/repositories/party_repository.dart';

class UpsertPartyUseCase {
  final PartyRepository _repository;

  UpsertPartyUseCase(this._repository);

  /// If a party with the same id exists, update it; otherwise, add it.
  void execute(Party party) {
    List<Party> existingParties = _repository.loadParties();
    final index = existingParties.indexWhere((p) => p.id == party.id);
    if (index == -1) {
      existingParties.add(party);
    } else {
      existingParties[index] = party;
    }
    _repository.saveParties(existingParties);
  }
}