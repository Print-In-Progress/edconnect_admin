import 'package:edconnect_admin/core/interfaces/localization_repository.dart';
import 'package:edconnect_admin/core/interfaces/sorting_survey_repository.dart';
import 'package:edconnect_admin/core/interfaces/storage_repository.dart';
import 'package:edconnect_admin/data/repositories/firebase_sorting_survey_repository_impl.dart';
import 'package:edconnect_admin/data/repositories/firebase_storage_repository_impl.dart';
import 'package:edconnect_admin/data/repositories/localization_repository_impl.dart';
import 'package:edconnect_admin/presentation/providers/state_providers.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/interfaces/auth_repository.dart';
import '../../core/interfaces/group_repository.dart';
import '../../core/interfaces/user_repository.dart';
import '../../core/interfaces/navigation_repository.dart';
import '../../core/interfaces/theme_repository.dart';
import '../../data/repositories/firebase_auth_repositories_impl.dart';
import '../../data/repositories/firebase_group_repository_impl.dart';
import '../../data/repositories/firebase_user_repository_impl.dart';
import '../../data/repositories/navigation_repository_impl.dart';
import '../../data/repositories/theme_repository.dart';
import 'datasource_providers.dart';

// Localization repository implementation
final localizationRepositoryImplProvider =
    Provider<LocalizationRepository>((ref) {
  final localizationService = LocalizationServiceImpl('en');

  ref.listen<Locale>(appLocaleProvider, (_, Locale locale) {
    localizationService.updateLocale(locale.languageCode);
  });

  return localizationService;
});

// Auth repository implementation
final authRepositoryImplProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepositoryImpl(
    ref.watch(authDataSourceProvider),
    ref.watch(userDataSourceProvider),
    ref.watch(storageDataSourceProvider),
    ref.watch(localizationRepositoryImplProvider),
  );
});

// Group repository implementation
final groupRepositoryImplProvider = Provider<GroupRepository>((ref) {
  return FirebaseGroupRepositoryImpl(
    ref.watch(groupDataSourceProvider),
  );
});

// User repository implementation
final userRepositoryImplProvider = Provider<UserRepository>((ref) {
  return FirebaseUserRepositoryImpl(
    ref.watch(userDataSourceProvider),
  );
});

// Navigation repository implementation - using singleton
final _navigationRepository = NavigationRepositoryImpl();
final navigationRepositoryImplProvider = Provider<NavigationRepository>((ref) {
  return _navigationRepository;
});

// Theme repository implementation
final themeRepositoryImplProvider = Provider<ThemeRepository>((ref) {
  return ThemeRepositoryImpl(
    ref.watch(themeLocalDataSourceProvider),
    ref.watch(themeRemoteDataSourceProvider),
  );
});

final storageRepositoryImplProvider = Provider<StorageRepository>((ref) {
  return FirebaseStorageRepositoryImpl(
    ref.watch(storageDataSourceProvider),
  );
});

// Modules repository implementations
// Sorting Module
final sortingSurveyRepositoryProvider =
    Provider<SortingSurveyRepository>((ref) {
  final dataSource = ref.watch(sortingSurveyDataSourceProvider);
  return FirebaseSortingSurveyRepositoryImpl(dataSource);
});
