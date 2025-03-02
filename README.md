# Party Planner Flutter Project

## Overview

This Flutter application is a prototype for planning parties. It is designed to work on both iOS and Android, offering a native look and feel. The app allows users to manage a list of parties, add party details, invite contacts, and automatically add parties to the device's native calendar.

> **Note:** This project is self-contained and does not use a backend or external database. All data is stored locally.

## Setup & Installation

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) 
- For **Android:** Android Studio or another IDE with an Android emulator or a physical device.
- For **iOS:** Xcode is required. Ensure you have the appropriate certificates and a valid device or simulator.

### Getting Started

1. **Open the project and Install the necessary dependencies by running this command:**
   
   ```bash
   flutter pub get
   ```
   
2. **Running the Project:**


#### For Android:
Open Android Studio and launch an Android emulator or connect a physical Android device.
##### For iOS:
Open Xcode and select the provided iOS simulator (or connect a physical iOS device).

After you set up the emulators, run:

   ```bash
   flutter run
```

## Completed Requirements

### Must
- The app works on Android and iOS.
- The application should save the list of parties and people who are invited.
- The app has some sort of professional (native?) styling.
- The app shows a list of upcoming parties and gives the user the ability to add one.
- When the user clicks adds a party he/she can put then name, the description and the date of the
party. Add the party to the phone agenda immediately after creating the party.
- Allow the user to add persons to the party. When the user presses the button the phones contact
list should appear and the user can select a contact.
- Allow the user to send an invitation to the party people. You can do this with plugins the
framework has available. Otherwise an enhanced mailto:// URL should work. You also can use
some sort of iCal invitation, but’s that’s not necessary.

### Should
- Add edit functionality to edit the name, description and date and time of the party (make sure to
update the agenda!). Also enable the removal of users from the party.

### Could
- Sends update notifications by mail when you updated the party.