import 'dart:typed_data';
import 'package:edconnect_admin/domain/entities/group.dart';

class AppUser {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final List<String> fcmTokens;
  final List<String> permissions;
  final List<String> groupIds;
  final List<String>? publicIdentityKey;
  final Map<String, Map<String, dynamic>> deviceIds;
  final String? registrationPdfPublicKey;
  final Uint8List? registrationPdfSignature;
  final String accountType; // Student, Faculty, or Parent
  final bool isUnverified;

  // Resolved groups for efficient permission checking
  final List<Group>? _resolvedGroups;
  List<Group> get groups => _resolvedGroups ?? [];

  // Get all permissions (direct + from groups)
  List<String> get allPermissions {
    final Set<String> allPerms = Set<String>.from(permissions);

    // Add permissions from all groups
    if (_resolvedGroups != null) {
      for (final group in _resolvedGroups) {
        allPerms.addAll(group.permissions);
      }
    }

    return allPerms.toList();
  }

  // Check if user has a specific permission
  bool hasPermission(String permission) {
    // Normalize permission to check (case-insensitive)
    final normalizedPermission = permission.toLowerCase();

    // Check direct permissions
    if (permissions
        .map((p) => p.toLowerCase())
        .contains(normalizedPermission)) {
      return true;
    }

    // Check group permissions
    for (final group in groups) {
      if (group.permissions
          .map((p) => p.toLowerCase())
          .contains(normalizedPermission)) {
        return true;
      }
    }

    return false;
  }

  // Check if user has any of the given permissions
  bool hasAnyPermission(List<String> requiredPermissions) {
    for (final permission in requiredPermissions) {
      if (hasPermission(permission)) {
        return true;
      }
    }
    return false;
  }

  AppUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.fcmTokens,
    required this.permissions,
    required this.groupIds,
    this.publicIdentityKey,
    required this.deviceIds,
    this.registrationPdfPublicKey,
    this.registrationPdfSignature,
    required this.accountType,
    this.isUnverified = false,
    List<Group>? resolvedGroups,
  }) : _resolvedGroups = resolvedGroups;

  // Convert to Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'fcm_token': fcmTokens,
      'permissions': permissions,
      'groups': groupIds,
      'public_identity_key': publicIdentityKey,
      'device_ids': deviceIds,
      'registration_pdf_public_key': registrationPdfPublicKey,
      'registration_pdf_signature': registrationPdfSignature?.toList(),
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
      groupIds: const [],
      isUnverified: true,
      fcmTokens: [],
      deviceIds: {},
      accountType: '',
    );
  }

  // Factory method to create an empty AppUser
  factory AppUser.empty() {
    return AppUser(
      id: '',
      firstName: '',
      lastName: '',
      email: '',
      fcmTokens: [],
      permissions: [],
      groupIds: [],
      deviceIds: {},
      accountType: '',
      isUnverified: true,
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
      groupIds: List<String>.from(map['groups'] ?? []),
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

  AppUser copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    List<String>? fcmTokens,
    List<String>? permissions,
    List<String>? groupIds,
    List<String>? publicIdentityKey,
    Map<String, Map<String, dynamic>>? deviceIds,
    String? registrationPdfPublicKey,
    Uint8List? registrationPdfSignature,
    String? accountType,
    bool? isUnverified,
    List<Group>? resolvedGroups,
  }) {
    return AppUser(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      fcmTokens: fcmTokens ?? this.fcmTokens,
      permissions: permissions ?? this.permissions,
      groupIds: groupIds ?? this.groupIds,
      publicIdentityKey: publicIdentityKey ?? this.publicIdentityKey,
      deviceIds: deviceIds ?? this.deviceIds,
      registrationPdfPublicKey:
          registrationPdfPublicKey ?? this.registrationPdfPublicKey,
      registrationPdfSignature:
          registrationPdfSignature ?? this.registrationPdfSignature,
      accountType: accountType ?? this.accountType,
      isUnverified: isUnverified ?? this.isUnverified,
      resolvedGroups: resolvedGroups ?? _resolvedGroups,
    );
  }

  // The method that your providers are looking for
  AppUser withResolvedGroups(List<Group> groups) {
    return copyWith(resolvedGroups: groups);
  }

  String get initials => firstName.isNotEmpty && lastName.isNotEmpty
      ? '${firstName[0]}${lastName[0]}'
      : '';

  String get fullName => '$firstName $lastName';
}
