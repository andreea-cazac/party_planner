import 'package:intl/intl.dart';
import '../../data/models/party_model.dart';

String formatPartyDate(Party party) {
  return DateFormat('dd/MM/yyyy HH:mm').format(party.date);
}