import 'package:party_planner/data/models/contact_model.dart';
import 'package:uuid/uuid.dart';

class Party {
  String id;
  String name;
  String description;
  DateTime date;
  List<ContactModel> guests;
  String? calendarEventId;

  Party({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
    required this.guests,
    this.calendarEventId,
  });

  // Generate a unique ID when creating a new Party
  static String generateId() {
    return const Uuid().v4();
  }
}