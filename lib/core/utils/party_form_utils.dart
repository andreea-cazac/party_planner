import 'package:flutter/material.dart';
import '../../data/models/party_model.dart';
import '../../data/models/contact_model.dart';

/// Builds a Party object from form input.
/// If [existingId] is null, a new ID is generated.
Party buildPartyFromForm({
  required String? existingId,
  required String name,
  required String description,
  required DateTime selectedDate,
  required TimeOfDay selectedTime,
  required List<ContactModel> guests,
}) {
  final DateTime fullDateTime = DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
    selectedTime.hour,
    selectedTime.minute,
  );
  return Party(
    id: existingId ?? Party.generateId(),
    name: name,
    description: description,
    date: fullDateTime,
    guests: guests,
  );
}