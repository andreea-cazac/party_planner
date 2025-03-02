import '../../core/services/calendar_service.dart';
import '../../data/models/party_model.dart';
import '../../data/repositories/party_repository.dart';

class UpsertPartyUseCase {
  final PartyRepository _repository;
  final CalendarService _calendarService;

  UpsertPartyUseCase(this._repository, this._calendarService);

  /// If a party with the same id exists, update it; otherwise, add it.
  // Future<void> execute(Party party) async {
  //   // 1. Create or update the event in the phone's calendar
  //   final eventId = await _calendarService.addOrUpdateCalendarEvent(party);
  //   if (eventId != null) {
  //     party.calendarEventId = eventId; // store the event ID
  //   }
  //
  //   // 2. Upsert in local repository
  //   List<Party> existingParties = _repository.loadParties();
  //   final index = existingParties.indexWhere((p) => p.id == party.id);
  //   if (index == -1) {
  //     existingParties.add(party);
  //   } else {
  //     existingParties[index] = party;
  //   }
  //   _repository.saveParties(existingParties);
  // }
  Future<void> execute(Party party) async {
    List<Party> existingParties = _repository.loadParties();
    final index = existingParties.indexWhere((p) => p.id == party.id);

    // If the party already exists, delete its old calendar event.
    if (index != -1) {
      Party oldParty = existingParties[index];
      if (oldParty.calendarEventId != null) {
        // Retrieve the default calendar.
        final defaultCalendar = await _calendarService.retrieveDefaultCalendar();
        if (defaultCalendar != null && defaultCalendar.id != null) {
          await _calendarService.deleteCalendarEvent(defaultCalendar.id!, oldParty.calendarEventId!);
        }
      }
    }

    // Now create a new event for the (updated) party.
    final newEventId = await _calendarService.addOrUpdateCalendarEvent(party);
    if (newEventId != null) {
      party.calendarEventId = newEventId; // Store the new event ID.
    }

    // Upsert the party in the repository.
    if (index == -1) {
      existingParties.add(party);
    } else {
      existingParties[index] = party;
    }
    _repository.saveParties(existingParties);
  }
}