import 'package:flutter/material.dart';
import 'package:party_planner/core/services/contacts_service.dart';
import 'package:party_planner/data/models/contact_model.dart';

class GuestSelectionDialog extends StatefulWidget {
  final List<ContactModel> currentSelected;
  const GuestSelectionDialog({super.key, required this.currentSelected});

  @override
  State<GuestSelectionDialog> createState() => _GuestSelectionDialogState();
}

class _GuestSelectionDialogState extends State<GuestSelectionDialog> {
  late final Future<List<ContactModel>> _contactsFuture;
  final Set<String> newSelections = {};

  @override
  void initState() {
    super.initState();
    // Initialize the future only once.
    _contactsFuture = ContactsServiceWrapper().getContacts();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ContactModel>>(
      future: _contactsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return AlertDialog(
            title: const Text('No Contacts'),
            content: const Text(
              "No contacts available. Please ensure your contacts permission is granted in your device settings.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        }
        final contacts = snapshot.data!;
        final alreadySelected = widget.currentSelected.map((g) => g.identifier).toSet();

        return AlertDialog(
          title: Text('Select Guests (${contacts.length} contacts)'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                final isAlreadyAdded = alreadySelected.contains(contact.identifier);
                final isSelected = newSelections.contains(contact.identifier);
                return CheckboxListTile(
                  title: Text(contact.displayName),
                  value: isAlreadyAdded ? true : isSelected,
                  onChanged: isAlreadyAdded
                      ? null
                      : (value) {
                    setState(() {
                      if (value == true) {
                        newSelections.add(contact.identifier);
                      } else {
                        newSelections.remove(contact.identifier);
                      }
                    });
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final selectedContacts = contacts
                    .where((contact) => newSelections.contains(contact.identifier))
                    .toList();
                Navigator.pop(context, selectedContacts);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}