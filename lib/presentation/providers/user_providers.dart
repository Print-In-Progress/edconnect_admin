import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/app_user.dart';
import '../../core/interfaces/user_repository.dart';
import '../../data/repositories/firebase_user_repository_impl.dart';
import '../../domain/services/current_user_service.dart';
import 'auth_provider.dart';

// ----------------- USER REPOSITORIES -----------------

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return FirebaseUserRepositoryImpl(
    ref.read(userDataSourceProvider), // From auth_provider.dart
  );
});

// ----------------- USER SERVICES -----------------

final userServiceProvider = Provider<UserService>((ref) {
  return UserService(ref.watch(userRepositoryProvider));
});

// ----------------- USER STATE PROVIDERS -----------------

// Cache user data for performance
final cachedUserProvider = StateProvider<AppUser?>((ref) => null);

// Stream user data based on auth state
final currentUserProvider = StreamProvider<AppUser?>((ref) async* {
  final authState = ref.watch(authStateProvider).value;
  if (authState == null) {
    ref.read(cachedUserProvider.notifier).state = null;
    yield null;
    return;
  }

  // Use cached user first if available and matches current user ID
  final cachedUser = ref.read(cachedUserProvider);
  if (cachedUser != null && cachedUser.id == authState.id) {
    yield cachedUser;
  }

  // Stream from repository
  final userService = ref.watch(userServiceProvider);
  await for (final user in userService.getUserStream(authState.id)) {
    ref.read(cachedUserProvider.notifier).state = user;
    yield user;
  }
});

// ----------------- USER ACTION PROVIDERS -----------------

// Manually refresh user data
final refreshUserProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    ref.read(cachedUserProvider.notifier).state = null;
    ref.invalidate(currentUserProvider);
  };
});

// Update user profile
/*final updateUserProfileProvider = Provider<
    Future<void> Function({
      required String firstName,
      required String lastName,
    })>((ref) {
  final userService = ref.watch(userServiceProvider);

  return ({required String firstName, required String lastName}) async {
    await userService.updateUserProfile(
      firstName: firstName,
      lastName: lastName,
    );
    ref.read(refreshUserProvider)();
  };
});
*/