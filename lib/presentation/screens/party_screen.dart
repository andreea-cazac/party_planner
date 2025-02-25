import 'package:flutter/material.dart';
import 'package:party_planner/config/constants.dart';
import 'package:provider/provider.dart';
import '../../core/utils/party_form_utils.dart';
import '../../data/models/contact_model.dart';
import '../../data/models/party_model.dart';
import '../../providers/party_provider.dart';
import '../widgets/guest_selection_dialog.dart';

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
    if (_nameController.text.isEmpty || _descriptionController.text.isEmpty || _selectedDate == null || _selectedTime == null || _selectedGuests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all fields before saving.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Use the helper to build the Party from the form.
    final partyToSave = buildPartyFromForm(
      existingId: widget.party?.id,
      name: _nameController.text,
      description: _descriptionController.text,
      selectedDate: _selectedDate!,
      selectedTime: _selectedTime!,
      guests: _selectedGuests,
    );

    final partyProvider = Provider.of<PartyProvider>(context, listen: false);
    partyProvider.upsertParty(partyToSave);
    Navigator.pop(context);
  }

  Future<void> _selectGuest() async {
    // When editing, disable adding new guests.
    if (widget.party != null) return;
    final List<ContactModel>? selected = await showDialog<List<ContactModel>>(
      context: context,
      builder: (context) => GuestSelectionDialog(currentSelected: _selectedGuests),
    );
    if (selected != null) {
      setState(() {
        for (final contact in selected) {
          if (!_selectedGuests.any((g) => g.identifier == contact.identifier)) {
            _selectedGuests.add(contact);
          }
        }
      });
    }
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
              // Only allow guest selection in creation mode.
              if (!isEditing)
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