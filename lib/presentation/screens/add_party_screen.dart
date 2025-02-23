import 'package:flutter/material.dart';
import 'package:party_planner/config/constants.dart';
import 'package:provider/provider.dart';
import '../../core/services/contacts_service.dart';
import '../../data/models/contact_model.dart';
import '../../providers/party_provider.dart';

class AddPartyScreen extends StatefulWidget {
  const AddPartyScreen({super.key});

  //stateful widgets must override
  @override
  AddPartyScreenState createState() => AddPartyScreenState();
}

class AddPartyScreenState extends State<AddPartyScreen> {

  //data user will return
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  List<ContactModel> _selectedGuests = [];

  void _saveParty(BuildContext context) {
    if (_nameController.text.isEmpty || _descriptionController.text.isEmpty || _selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all fields before saving.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Combine selected date and time into one DateTime object
    // ! ensures the variable is not null
    final DateTime fullDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    //listen: false means this widget doesn’t need to rebuild when PartyProvider updates.
    Provider.of<PartyProvider>(context, listen: false)
        .addParty(_nameController.text, _descriptionController.text, fullDateTime, guests: _selectedGuests);

    //Navigator.pop(context); closes the current screen and goes back to the previous screen
    //Opposite of Navigator.push
    Navigator.pop(context);
  }

  Future<void> _selectGuest() async {
    // Use the ContactsServiceWrapper to get a list of contacts.
    final contactsService = ContactsServiceWrapper();
    List<ContactModel> contacts = await contactsService.getContacts();

    if (!mounted) return;

    // If no contacts were fetched, use a simple message.
    if (contacts.isEmpty) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
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
        ),
      );
      return;
    }

    // Create a Set of identifiers for contacts already selected.
    final alreadySelected = _selectedGuests.map((g) => g.identifier).toSet();
    // Local mutable set to track new selections in this dialog.
    final Set<String> newSelections = {};

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text ('Select Guests (${contacts.length} contacts)'),
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
                      // If already added, show it as checked and disable changes.
                      value: isAlreadyAdded ? true : isSelected,
                      onChanged: isAlreadyAdded
                          ? null // Disable checkbox if contact is already selected.
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
                    // Add all newly selected contacts that are not already added.
                    for (final contact in contacts) {
                      if (newSelections.contains(contact.identifier) &&
                          !_selectedGuests.any((g) => g.identifier == contact.identifier)) {
                        _selectedGuests.add(contact);
                      }
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
    // Force update the state after the dialog closes so the selected guest list is immediately refreshed.
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add a Party')),
      body: Padding(
        padding: const EdgeInsets.all(16.0), //16px of all sides
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Party Name'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            ElevatedButton(
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );

                //trigger an UI update
                //for name and description we do not setState as the text field updates in real time
                setState(() {
                  _selectedDate = pickedDate;
                });
              },
              child: Text(_selectedDate == null
                  ? 'Select Date'
                  : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
            ),
            // Time Picker Button
            ElevatedButton(
              onPressed: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                setState(() {
                  _selectedTime = pickedTime;
                });
              },
              child: Text(_selectedTime == null
                  ? 'Select Time'
                  : _selectedTime!.format(context)),
            ),
            ElevatedButton(
              onPressed: _selectGuest,
              child: const Text('Add Guest'),
            ),
            const SizedBox(height: 16),
            // Display the selected guests with a header.
            Center(
              child: Text(
                "Selected Guests:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _selectedGuests.isEmpty
                ? const Text("No guests added.")
                : Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: _selectedGuests.map((guest) {
                return Chip(
                  label: Text(guest.displayName),
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: () => _saveParty(context),
              child: const Text('Save Party'),
            ),
          ],
        ),
      ),
    );
  }
}