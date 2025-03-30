import 'package:edconnect_admin/domain/usecases/auth/delete_account_use_case.dart';
import 'package:edconnect_admin/domain/usecases/auth/get_registration_fields_use_case.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/auth/sign_in_usecase.dart';
import '../../domain/usecases/auth/sign_out_use_case.dart';
import '../../domain/usecases/auth/sign_up_usecase.dart';
import '../../domain/usecases/auth/user_credential_repository.dart';
import '../../domain/usecases/auth/user_profile_use_case.dart';
import '../../domain/usecases/group_management_use_case.dart';
import '../../domain/usecases/theme_usecases.dart';
import '../../core/providers/interface_providers.dart';

// Auth use cases
final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  return SignUpUseCase(ref.watch(authRepositoryProvider));
});

final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  return SignInUseCase(ref.watch(authRepositoryProvider));
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(ref.watch(authRepositoryProvider));
});

final userCredentialsUseCaseProvider = Provider<UserCredentialsUseCase>((ref) {
  return UserCredentialsUseCase(ref.watch(authRepositoryProvider));
});

final userProfileDataUseCaseProvider = Provider<UserProfileDataUseCase>((ref) {
  return UserProfileDataUseCase(ref.watch(userRepositoryProvider));
});

// Group use cases
final groupManagementUseCaseProvider = Provider<GroupManagementUseCase>((ref) {
  return GroupManagementUseCase(ref.watch(groupRepositoryProvider));
});

// Theme use cases
final getAppThemeUseCaseProvider = Provider<GetAppThemeUseCase>((ref) {
  return GetAppThemeUseCase(ref.watch(themeRepositoryProvider));
});

final setDarkModeUseCaseProvider = Provider<SetDarkModeUseCase>((ref) {
  return SetDarkModeUseCase(ref.watch(themeRepositoryProvider));
});

final setThemeColorsUseCaseProvider = Provider<SetThemeColorsUseCase>((ref) {
  return SetThemeColorsUseCase(ref.watch(themeRepositoryProvider));
});

final setLogoUrlUseCaseProvider = Provider<SetLogoUrlUseCase>((ref) {
  return SetLogoUrlUseCase(ref.watch(themeRepositoryProvider));
});

final refreshRemoteThemeUseCaseProvider =
    Provider<RefreshRemoteThemeUseCase>((ref) {
  return RefreshRemoteThemeUseCase(ref.watch(themeRepositoryProvider));
});

final deleteAccountUseCaseProvider = Provider<DeleteAccountUseCase>((ref) {
  return DeleteAccountUseCase(
    ref.watch(authRepositoryProvider),
    ref.watch(userRepositoryProvider),
    ref.watch(storageRepositoryProvider),
  );
});

final getRegistrationFieldsUseCaseProvider =
    Provider<GetRegistrationFieldsUseCase>((ref) {
  return GetRegistrationFieldsUseCase(ref.watch(userRepositoryProvider));
});
