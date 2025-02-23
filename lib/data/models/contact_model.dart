class ContactModel {
  final String identifier;
  final String displayName;
  final String? phoneNumber;
  final String? email;

  ContactModel({
    required this.identifier,
    required this.displayName,
    this.phoneNumber,
    this.email,
  });
}