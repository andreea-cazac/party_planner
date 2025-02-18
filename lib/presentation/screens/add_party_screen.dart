import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
        .addParty(_nameController.text, _descriptionController.text, fullDateTime);

    //Navigator.pop(context); closes the current screen and goes back to the previous screen
    //Opposite of Navigator.push
    Navigator.pop(context);
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
              onPressed: () => _saveParty(context),
              child: const Text('Save Party'),
            ),
          ],
        ),
      ),
    );
  }
}