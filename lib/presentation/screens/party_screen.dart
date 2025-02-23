import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:party_planner/config/constants.dart';
import 'package:provider/provider.dart';
import '../../data/models/contact_model.dart';
import '../../data/models/party_model.dart';
import '../../providers/party_provider.dart';
import '../../core/services/contacts_service.dart';

class PartyScreen extends StatefulWidget {
  final Party? party; // if null, we are creating a new party
  const PartyScreen({super.key, this.party});

  @override
  PartyScreenState createState() => PartyScreenState();
}

class PartyScreenState extends State<PartyScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  List<ContactModel> _selectedGuests = [];

  @override
  void initState() {
    super.initState();
    if (widget.party != null) {
      // Prefill fields for editing.
      _nameController.text = widget.party!.name;
      _descriptionController.text = widget.party!.description;
      _selectedDate = widget.party!.date;
      _selectedTime = TimeOfDay(hour: widget.party!.date.hour, minute: widget.party!.date.minute);
      _selectedGuests = List<ContactModel>.from(widget.party!.guests);
    }
  }

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
    final DateTime fullDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
    final partyProvider = Provider.of<PartyProvider>(context, listen: false);
    if (widget.party == null) {
      // Create mode.
      partyProvider.addParty(_nameController.text, _descriptionController.text, fullDateTime, guests: _selectedGuests);
    } else {
      // Edit mode: create an updated party object.
      final updatedParty = Party(
        id: widget.party!.id,
        name: _nameController.text,
        description: _descriptionController.text,
        date: fullDateTime,
        guests: _selectedGuests,
      );
      partyProvider.updateParty(updatedParty);
    }
    Navigator.pop(context);
  }

  Future<void> _selectGuest() async {
    final contactsService = ContactsServiceWrapper();
    List<ContactModel> contacts = await contactsService.getContacts();
    if (!mounted) return;
    if (contacts.isEmpty) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No Contacts'),
          content: const Text("No contacts available. Please ensure your contacts permission is granted in your device settings."),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      );
      return;
    }
    final alreadySelected = _selectedGuests.map((g) => g.identifier).toSet();
    final Set<String> newSelections = {};
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
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
                        setStateDialog(() {
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
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
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
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.party != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Party' : 'Add a Party')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
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
                    initialDate: _selectedDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  setState(() {
                    _selectedDate = pickedDate;
                  });
                },
                child: Text(_selectedDate == null
                    ? 'Select Date'
                    : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
              ),
              ElevatedButton(
                onPressed: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime ?? TimeOfDay.now(),
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
                    deleteIcon: const Icon(Icons.close, color: Colors.red, size: 18),
                    onDeleted: () {
                      setState(() {
                        _selectedGuests.removeWhere((g) => g.identifier == guest.identifier);
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _saveParty(context),
                child: Text(isEditing ? 'Update Party' : 'Save Party'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}