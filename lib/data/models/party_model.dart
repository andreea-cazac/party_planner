import 'package:uuid/uuid.dart';

class Party {
  String id;
  String name;
  String description;
  DateTime date;

  Party({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
  });

  // Generate a unique ID when creating a new Party
  static String generateId() {
    return const Uuid().v4();
  }
}