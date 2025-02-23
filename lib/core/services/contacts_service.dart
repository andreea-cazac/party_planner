import 'package:flutter_contacts/flutter_contacts.dart';
import '../../data/models/contact_model.dart';

class ContactsServiceWrapper {
  Future<List<ContactModel>> getContacts() async {
    // Request permission to access contacts.
    // if (!await FlutterContacts.requestPermission()) {
    //   return [];
    // }

   // print("DEBUG: Starting getContacts() in ContactsServiceWrapper");

    // Request permission to access contacts.
    //print("DEBUG: Requesting contacts permission via FlutterContacts.requestPermission()");
    bool permissionGranted = await FlutterContacts.requestPermission();
   // print("DEBUG: Contacts permission granted: $permissionGranted");
    if (!permissionGranted) {
    //  print("DEBUG: Permission not granted. Returning empty contact list.");
      return [];
    }

   // print("DEBUG: Fetching contacts with properties (without thumbnails)...");
    // Fetch contacts with properties (without thumbnails for faster retrieval).
    List<Contact> contacts = await FlutterContacts.getContacts(
      withProperties: true,
      withThumbnail: false,
    );
   // print("DEBUG: Found ${contacts.length} contacts");
    // Map fetched contacts to your app's ContactModel.
// Optionally, print details for each contact for debugging.
    for (var i = 0; i < contacts.length; i++) {
      final contact = contacts[i];
   //   print("DEBUG: Contact[$i]: id=${contact.id}, displayName=${contact.displayName}");
      if (contact.phones.isNotEmpty) {
    //    print("DEBUG:   - Phone: ${contact.phones.first.number}");
      }
      if (contact.emails.isNotEmpty) {
   //     print("DEBUG:   - Email: ${contact.emails.first.address}");
      }
    }

    // Map fetched contacts to your app's ContactModel.
    List<ContactModel> mappedContacts = contacts.map((contact) {
      return ContactModel(
        identifier: contact.id,
        displayName: contact.displayName,
        phoneNumber: contact.phones.isNotEmpty ? contact.phones.first.number : null,
        email: contact.emails.isNotEmpty ? contact.emails.first.address : null,
      );
    }).toList();

   // print("DEBUG: Mapped contacts to ContactModel: ${mappedContacts.length} items.");
    return mappedContacts;
  }
}