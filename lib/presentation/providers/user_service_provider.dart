import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edconnect_admin/domain/services/user_service.dart';
import 'package:edconnect_admin/domain/usecases/auth/user_credential_repository.dart';
import 'package:edconnect_admin/domain/usecases/auth/user_profile_use_case.dart';
import 'package:edconnect_admin/core/interfaces/user_repository.dart';
import 'package:edconnect_admin/data/repositories/firebase_user_repository_impl.dart';
import 'package:edconnect_admin/presentation/providers/auth_provider.dart';

final userCredentialsUseCaseProvider = Provider<UserCredentialsUseCase>((ref) {
  return UserCredentialsUseCase(ref.watch(authRepositoryProvider));
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return FirebaseUserRepositoryImpl(ref.watch(userDataSourceProvider));
});

final userProfileDataUseCaseProvider = Provider<UserProfileDataUseCase>((ref) {
  return UserProfileDataUseCase(ref.watch(userRepositoryProvider));
});

final userServiceProvider = Provider<UserService>((ref) {
  return UserService(
    ref.watch(userCredentialsUseCaseProvider),
    ref.watch(userProfileDataUseCaseProvider),
    ref.watch(userRepositoryProvider),
  );
});
