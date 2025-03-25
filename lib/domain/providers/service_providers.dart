// Auth service
import 'package:edconnect_admin/domain/services/current_user_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/auth_service.dart';
import '../../domain/services/group_service.dart';
import '../../domain/services/permission_service.dart';
import '../../domain/services/user_service.dart';
import 'usecase_providers.dart';
import '../../core/providers/interface_providers.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    ref.watch(signUpUseCaseProvider),
    ref.watch(signInUseCaseProvider),
  );
});

// User service
final userServiceProvider = Provider<UserService>((ref) {
  return UserService(
    ref.watch(userCredentialsUseCaseProvider),
    ref.watch(userProfileDataUseCaseProvider),
    ref.watch(userRepositoryProvider),
  );
});

// Current user service
final currentUserServiceProvider = Provider<CurrentUserService>((ref) {
  return CurrentUserService(
    ref.watch(userRepositoryProvider),
  );
});

// Group service
final groupServiceProvider = Provider<GroupService>((ref) {
  return GroupService(ref.watch(groupManagementUseCaseProvider));
});

// Permission service
final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService();
});
