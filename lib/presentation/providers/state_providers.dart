import 'package:edconnect_admin/core/interfaces/auth_repository.dart';
import 'package:edconnect_admin/core/interfaces/user_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/app_user.dart';
import '../../domain/providers/service_providers.dart';
import '../../core/providers/interface_providers.dart';

// ----------------- AUTH STATE -----------------

enum AuthStatus {
  initial,
  authenticating,
  loadingUserData,
  authenticated,
  unauthenticated,
  error,
}

class AuthStateNotifier extends StateNotifier<AuthStatus> {
  final AuthRepository _authRepository;

  AuthStateNotifier({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  })  : _authRepository = authRepository,
        super(AuthStatus.initial) {
    _setupAuthListener();
  }

  void _setupAuthListener() {
    state = AuthStatus.loadingUserData; // Set loading state first

    _authRepository.currentUserStream.listen((user) async {
      if (user == null) {
        state = AuthStatus.unauthenticated;
      } else {
        // If user exists but is unverified
        if (user.isUnverified) {
          await _authRepository.reloadUser();
          final isVerified = await _authRepository.isEmailVerified();
          if (!isVerified) {
            state = AuthStatus.authenticated; // Show verify email page
            return;
          }
        }
        state = AuthStatus.authenticated;
      }
    });
  }

  Future<void> signOut() async {
    try {
      state = AuthStatus.loadingUserData;
      await _authRepository.signOut();
      state = AuthStatus.unauthenticated;
    } catch (e) {
      state = AuthStatus.error;
    }
  }
}

// Auth status provider
final authStatusProvider =
    StateNotifierProvider<AuthStateNotifier, AuthStatus>((ref) {
  return AuthStateNotifier(
    authRepository: ref.watch(authRepositoryProvider),
    userRepository: ref.watch(userRepositoryProvider),
  );
});

// ----------------- USER STATE -----------------

// Cache for users to improve performance.
final cachedUserProvider = StateProvider<Map<String, AppUser>>((ref) => {});

// Provider to access the current user with caching.
final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.currentUserStream;
});

// Provider for fetching a user by ID with resolved groups.
final getUserWithGroupsProvider =
    FutureProvider.family<AppUser?, String>((ref, userId) async {
  final cachedUsers = ref.read(cachedUserProvider);
  if (cachedUsers.containsKey(userId)) {
    return cachedUsers[userId];
  }

  final userRepository = ref.read(userRepositoryProvider);
  final user = await userRepository.getUser(userId);
  if (user == null) return null;

  final groups = await ref.read(groupServiceProvider).getGroupsForUser(userId);
  final userWithGroups = user.withResolvedGroups(groups);

  ref.read(cachedUserProvider.notifier).update((state) => {
        ...state,
        userId: userWithGroups,
      });
  return userWithGroups;
});
