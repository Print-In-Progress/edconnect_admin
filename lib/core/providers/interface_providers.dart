import 'package:edconnect_admin/core/interfaces/auth_repository.dart';
import 'package:edconnect_admin/core/interfaces/group_repository.dart';
import 'package:edconnect_admin/core/interfaces/localization_repository.dart';
import 'package:edconnect_admin/core/interfaces/navigation_repository.dart';
import 'package:edconnect_admin/core/interfaces/storage_repository.dart';
import 'package:edconnect_admin/core/interfaces/user_repository.dart';
import 'package:edconnect_admin/data/providers/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// These providers expose only the interfaces
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return ref.watch(authRepositoryImplProvider);
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return ref.watch(userRepositoryImplProvider);
});

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  return ref.watch(groupRepositoryImplProvider);
});

final navigationRepositoryProvider = Provider<NavigationRepository>((ref) {
  return ref.watch(navigationRepositoryImplProvider);
});

final storageRepositoryProvider = Provider<StorageRepository>((ref) {
  return ref.watch(storageRepositoryImplProvider);
});

final localizationRepositoryProvider = Provider<LocalizationRepository>((ref) {
  return ref.watch(localizationRepositoryImplProvider);
});
