import 'package:device_calendar/device_calendar.dart';
import '../../data/models/party_model.dart';
import 'package:timezone/timezone.dart' as tz;

class CalendarService {
  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();

  /// Requests calendar permissions from the user.
  Future<bool> requestPermissions() async {
    final result = await _deviceCalendarPlugin.requestPermissions();
    return result.data ?? false;
  }

  /// Retrieves the first calendar (often the default) or any calendar you prefer.
  /// You could also filter for a specific calendar name if desired.
  Future<Calendar?> retrieveDefaultCalendar() async {
    final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
    if (calendarsResult.isSuccess && calendarsResult.data != null && calendarsResult.data!.isNotEmpty) {
      // Attempt to find the "default" calendar, or fall back to the first.
      return calendarsResult.data!.firstWhere(
            (c) => (c.isDefault ?? false),
        orElse: () => calendarsResult.data!.first,
      );
    }
    return null;
  }

  /// Creates or updates an event in the user's calendar based on the given party.
  ///
  /// If [party.calendarEventId] is null, a new event is created.
  /// If [party.calendarEventId] is not null, that event is updated.
  ///
  /// Returns the `eventId` that was created or updated, or `null` if unsuccessful.
  Future<String?> addOrUpdateCalendarEvent(Party party) async {
    // Request permissions first
    final granted = await requestPermissions();
    if (!granted) {
      return null;
    }

    final defaultCalendar = await retrieveDefaultCalendar();
    if (defaultCalendar == null) {
      return null;
    }

    // Create an Event object for the plugin
    // Use an end time that is, for example, 5 hours after start (customize as needed).
    // Convert party.date to TZDateTime using the local timezone.
    final tzStartDate = tz.TZDateTime.from(party.date, tz.local);
    final tzEndDate =
    tz.TZDateTime.from(party.date.add(const Duration(hours: 5)), tz.local);

    final event = Event(
    defaultCalendar.id,
    eventId: party.calendarEventId, // null => create new, non-null => update
    title: party.name,
    description: party.description,
    start: tzStartDate,
    end: tzEndDate,
    );


    // Create or update the event in the calendar
    final createOrUpdateResult = await _deviceCalendarPlugin.createOrUpdateEvent(event);
    if (createOrUpdateResult!.isSuccess && createOrUpdateResult.data != null) {
      return createOrUpdateResult.data; // This is the eventId
    }
    return null;
  }

  /// Optionally, remove an event if a party is deleted.
  Future<bool> deleteCalendarEvent(String calendarId, String eventId) async {
    final deleteResult = await _deviceCalendarPlugin.deleteEvent(calendarId, eventId);
    return deleteResult.isSuccess;
  }
}