import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final List<String> fcmToken;
  final List<String> groups;
  final List<String> permissions;
  final List? publicIdentityKey; // Make it nullable
  final int? registrationId;
  final Map<String, Map<String, dynamic>> deviceIds;

  AppUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fcmToken,
    required this.email,
    required this.groups,
    required this.permissions,
    this.publicIdentityKey, // Nullable
    this.registrationId,
    required this.deviceIds,
  });

  // Convert a User object into a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'groups': groups,
      'permissions': permissions,
      'fcm_token': fcmToken,
      'email': email,
      'public_identity_key': publicIdentityKey,
      'registration_id': registrationId,
      'device_Ids': deviceIds,
    };
  }

  // Create a User object from a map
  factory AppUser.fromMap(Map<String, dynamic> map, String id) {
    return AppUser(
      id: id,
      firstName: map['first_name'] ?? '',
      lastName: map['last_name'] ?? '',
      email: map['email'] ?? '',
      fcmToken: List<String>.from(map['fcm_token'] ?? []),
      groups: List<String>.from(map['groups'] ?? []),
      permissions: List<String>.from(map['permissions'] ?? []),
      publicIdentityKey: map['public_identity_key'],
      registrationId: map['registration_id'] ?? 0,
      deviceIds: (map['device_Ids'] as Map<String, dynamic>? ?? {}).map(
        (key, value) => MapEntry(key, value as Map<String, dynamic>),
      ),
    );
  }

  // Create a User object from a Firestore document
  factory AppUser.fromDocument(DocumentSnapshot doc, String id) {
    return AppUser.fromMap(doc.data() as Map<String, dynamic>, id);
  }

  bool hasPermission(String permission) => permissions.contains(permission);

  bool hasAnyPermission(List<String> requiredPermissions) {
    return requiredPermissions.any(hasPermission);
  }

  String get initials => '${firstName[0]}${lastName[0]}';
}
