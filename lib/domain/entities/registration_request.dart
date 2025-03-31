import 'registration_fields.dart';

class RegistrationRequest {
  final String email;
  final String firstName;
  final String lastName;
  final String password;
  final String confirmedPassword;
  final String orgName;
  final List<BaseRegistrationField> registrationFields;
  final String accountType;

  RegistrationRequest({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.password,
    required this.confirmedPassword,
    required this.orgName,
    required this.registrationFields,
    required this.accountType,
  });
}
