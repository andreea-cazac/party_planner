import '../../data/models/party_model.dart';
import '../../data/repositories/party_repository.dart';

//AddPartyUseCase ensures data is formatted correctly before storing it.
//Handles business logic (e.g., validation, rules before saving to DB).
class AddPartyUseCase {
  final PartyRepository _repository;

  AddPartyUseCase(this._repository);

  void execute(Party party, List<Party> existingParties) {
    existingParties.add(party);
    _repository.saveParties(existingParties);
  }
}