import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasource/auth_data_source.dart';
import '../../data/datasource/firebase/firebase_auth_data_source.dart';
import '../../data/datasource/group_data_source.dart';
import '../../data/datasource/firebase/firebase_group_data_source.dart';
import '../../data/datasource/storage_data_source.dart';
import '../../data/datasource/firebase/firebase_storage_data_source.dart';
import '../../data/datasource/user_data_source.dart';
import '../../data/datasource/firebase/firebase_user_data_source.dart';
import '../../data/datasource/theme_data_source.dart';
import '../../data/datasource/local/shared_prefs_theme_data_source.dart';
import '../../data/datasource/firebase/firebase_theme_data_source.dart';
import '../../data/services/pdf_service.dart';
import 'data_providers.dart';
import '../../core/providers/interface_providers.dart';

// Auth data source
final authDataSourceProvider = Provider<AuthDataSource>((ref) {
  return FirebaseAuthDataSource(
    firebaseAuth: ref.watch(firebaseAuthProvider),
  );
});

// Group data source
final groupDataSourceProvider = Provider<GroupDataSource>((ref) {
  return FirebaseGroupDataSource(
    firestore: ref.watch(firestoreProvider),
  );
});

// User data source
// Note: This requires groupRepository which comes from interface_providers
// to avoid circular dependency
final userDataSourceProvider = Provider<UserDataSource>((ref) {
  return FirebaseUserDataSource(
    firestore: ref.watch(firestoreProvider),
    storage: ref.watch(firebaseStorageProvider),
    groupRepository: ref.watch(groupRepositoryProvider),
  );
});

// Storage data source
final storageDataSourceProvider = Provider<StorageDataSource>((ref) {
  return FirebaseStorageDataSource(
    storage: ref.watch(firebaseStorageProvider),
  );
});

// PDF service
final pdfServiceProvider = Provider<PdfService>((ref) {
  return PdfService();
});

// Theme data sources
final themeLocalDataSourceProvider = Provider<ThemeDataSource>((ref) {
  return SharedPrefsThemeDataSource();
});

final themeRemoteDataSourceProvider = Provider<RemoteThemeDataSource>((ref) {
  return FirebaseRemoteThemeDataSource();
});
