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
  final bool isDocumentMissing;
  final String? errorMessage;

  // Resolved groups for efficient permission checking
  final List<Group>? _resolvedGroups;
  List<Group> get groups => _resolvedGroups ?? [];

  late final Set<String> normalizedPermissions;

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
    this.isDocumentMissing = false,
    this.errorMessage,
    List<Group>? resolvedGroups,
  }) : _resolvedGroups = resolvedGroups {
    normalizedPermissions = _initializeNormalizedPermissions();
  }

  // Initialize normalized permissions set
  Set<String> _initializeNormalizedPermissions() {
    final Set<String> normalized = {};
    // Add direct permissions
    normalized.addAll(permissions.map((p) => p.toLowerCase()));
    // Add group permissions
    for (final group in groups) {
      normalized.addAll(group.permissions.map((p) => p.toLowerCase()));
    }
    return normalized;
  }

  // O(1) permission check
  bool hasPermission(String permission) {
    return normalizedPermissions.contains(permission.toLowerCase());
  }

  // O(n) where n is the number of required permissions
  bool hasAnyPermission(List<String> requiredPermissions) {
    return requiredPermissions.any((permission) =>
        normalizedPermissions.contains(permission.toLowerCase()));
  }

  // Get all permissions (now returns cached set)
  List<String> get allPermissions => normalizedPermissions.toList();

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

  factory AppUser.documentNotFound(String uid) {
    return AppUser(
      id: uid,
      firstName: '',
      lastName: '',
      email: '',
      fcmTokens: const [],
      permissions: const [],
      groupIds: const [],
      deviceIds: const {},
      isUnverified: false,
      accountType: '',
      isDocumentMissing: true, // New flag
    );
  }

  factory AppUser.error(String uid, String errorMessage) {
    return AppUser(
      id: uid,
      firstName: '',
      lastName: '',
      email: '',
      fcmTokens: const [],
      permissions: const [],
      groupIds: const [],
      deviceIds: const {},
      isUnverified: false,
      accountType: '',
      errorMessage: errorMessage, // Store the error
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
  String get initials => firstName.isNotEmpty && lastName.isNotEmpty
      ? '${firstName[0]}${lastName[0]}'
      : '';

  String get fullName => '$firstName $lastName';
}
