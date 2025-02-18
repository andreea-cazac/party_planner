import '../models/party_model.dart';

class PartyRepository {
  List<Party> _parties = []; // Store parties in memory

  List<Party> loadParties() {
    return _parties; // Return current list
  }

  void saveParties(List<Party> parties) {
    _parties = parties; // Overwrite list with new parties
  }
}