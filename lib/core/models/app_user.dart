import 'dart:typed_data';

class AppUser {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final List<String> fcmTokens;
  final List<String> permissions;
  final List<String> groups;
  final List<String>? publicIdentityKey;
  final Map<String, Map<String, dynamic>> deviceIds;
  final String? registrationPdfPublicKey;
  final Uint8List? registrationPdfSignature;
  final String accountType; // Student, Faculty, or Parent
  final bool isUnverified;

  AppUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.fcmTokens,
    required this.permissions,
    required this.groups,
    this.publicIdentityKey,
    required this.deviceIds,
    this.registrationPdfPublicKey,
    this.registrationPdfSignature,
    required this.accountType,
    this.isUnverified = false,
  });

  // Convert to Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'fcm_tokens': fcmTokens,
      'permissions': permissions,
      'groups': groups,
      'public_identity_key': publicIdentityKey,
      'device_ids': deviceIds,
      'registration_pdf_public_key': registrationPdfPublicKey,
      'registration_pdf_signature': registrationPdfSignature?.toList() ?? null,
      'account_type': accountType,
    };
  }

  factory AppUser.unverified(String uid) {
    return AppUser(
      id: uid,
      email: '',
      firstName: '',
      lastName: '',
      permissions: const [],
      groups: const [],
      isUnverified: true,
      fcmTokens: [],
      deviceIds: {},
      accountType: '',
    );
  }

  // Create from Firestore document
  factory AppUser.fromMap(Map<String, dynamic> map, String id) {
    return AppUser(
      id: id,
      firstName: map['first_name'] ?? '',
      lastName: map['last_name'] ?? '',
      email: map['email'] ?? '',
      fcmTokens: List<String>.from(map['fcm_token'] ?? []),
      groups: List<String>.from(map['groups'] ?? []),
      permissions: List<String>.from(map['permissions'] ?? []),
      deviceIds: (map['device_ids'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, Map<String, dynamic>.from(value)),
          ) ??
          {},
      registrationPdfPublicKey: map['registration_pdf_public_key'],
      registrationPdfSignature: map['registration_pdf_signature'] != null
          ? Uint8List.fromList(
              List<int>.from(map['registration_pdf_signature']))
          : null,
      accountType: map['account_type'] ?? '',
    );
  }
  String get initials => '${firstName[0]}${lastName[0]}';
  String get fullName => '$firstName $lastName';
}
