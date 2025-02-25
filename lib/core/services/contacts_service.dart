import 'package:flutter_contacts/flutter_contacts.dart';
import '../../data/models/contact_model.dart';

class ContactsServiceWrapper {
  Future<List<ContactModel>> getContacts() async {
    // Request permission to access contacts.
    bool permissionGranted = await FlutterContacts.requestPermission();
    if (!permissionGranted) {
      return [];
    }

    // Fetch contacts with properties (without thumbnails for faster retrieval).
    List<Contact> contacts = await FlutterContacts.getContacts(
      withProperties: true,
      withThumbnail: false,
    );

    // Map fetched contacts to your app's ContactModel.
    List<ContactModel> mappedContacts = contacts.map((contact) {
      return ContactModel(
        identifier: contact.id,
        displayName: contact.displayName,
        phoneNumber: contact.phones.isNotEmpty ? contact.phones.first.number : null,
        email: contact.emails.isNotEmpty ? contact.emails.first.address : null,
      );
    }).toList();

    return mappedContacts;
  }
}