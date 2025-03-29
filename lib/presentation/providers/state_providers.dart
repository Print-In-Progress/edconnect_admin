import 'package:edconnect_admin/core/interfaces/auth_repository.dart';
import 'package:edconnect_admin/core/interfaces/user_repository.dart';
import 'package:edconnect_admin/domain/entities/group.dart';
import 'package:edconnect_admin/domain/providers/usecase_providers.dart';
import 'package:edconnect_admin/domain/services/group_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/app_user.dart';
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
    _authRepository.currentUserStream.listen((user) async {
      if (user == null) {
        state = AuthStatus.unauthenticated;
        return;
      }

      // Single auth state transition
      state = AuthStatus.authenticated;
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

final userWithResolvedGroupsProvider = Provider<AppUser?>((ref) {
  final user = ref.watch(currentUserProvider).value;
  final groups = ref.watch(allGroupsStreamProvider).value ?? [];

  if (user == null) return null;

  final userGroups =
      groups.where((group) => user.groupIds.contains(group.id)).toList();

  // Create new user instance with resolved groups
  return user.copyWith(
    resolvedGroups: userGroups,
  );
});

// ---------------- GROUPS STATE  -----------------
final groupServiceProvider = Provider<GroupService>((ref) {
  return GroupService(ref.watch(groupManagementUseCaseProvider));
});

final cachedGroupsProvider = StateProvider<List<Group>>((ref) => []);

// Single stream for groups
final allGroupsStreamProvider = StreamProvider<List<Group>>((ref) {
  final groupService = ref.watch(groupServiceProvider);
  return groupService.groupsStream().map((groups) {
    return groups;
  });
});
