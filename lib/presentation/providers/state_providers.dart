import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/app_user.dart';
import '../../domain/entities/group.dart';
import '../../data/providers/data_providers.dart';
import '../../domain/providers/service_providers.dart';
import '../../core/providers/interface_providers.dart';

// ----------------- AUTH STATE -----------------

// Auth states enum
enum AuthStatus {
  initial,
  unauthenticated,
  unverified,
  authenticated,
}

// Firebase auth state stream
final firebaseAuthStateProvider = StreamProvider<firebase_auth.User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

// App user state stream
final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).currentUserStream;
});

// Email verification state
final emailVerificationProvider = StateProvider<bool>((ref) => false);

// Combined auth status
final authStatusProvider = Provider<AuthStatus>((ref) {
  final userStream = ref.watch(authStateProvider);
  final isVerified = ref.watch(emailVerificationProvider);

  return userStream.when(
    loading: () => AuthStatus.initial,
    error: (_, __) => AuthStatus.unauthenticated,
    data: (user) {
      if (user == null) return AuthStatus.unauthenticated;
      return isVerified ? AuthStatus.authenticated : AuthStatus.unverified;
    },
  );
});

// ----------------- USER STATE -----------------

// Cache for users to improve performance
final cachedUsersProvider = StateProvider<Map<String, AppUser>>((ref) => {});

// Current user stream with caching
final currentUserProvider = StreamProvider<AppUser?>((ref) async* {
  final authState = ref.watch(firebaseAuthStateProvider).value;
  if (authState == null) {
    yield null;
    return;
  }

  final userId = authState.uid;
  final cachedUsers = ref.read(cachedUsersProvider);

  // Return cached user first if available
  if (cachedUsers.containsKey(userId)) {
    yield cachedUsers[userId];
  }

  // Stream from repository
  await for (final user
      in ref.watch(userRepositoryProvider).getCurrentUserStream(userId)) {
    if (user != null) {
      // Update cache
      ref
          .read(cachedUsersProvider.notifier)
          .update((state) => {...state, userId: user});
    }
    yield user;
  }
});

// ----------------- GROUP STATE -----------------

// All groups stream
final groupsStreamProvider = StreamProvider<List<Group>>((ref) {
  return ref.watch(groupServiceProvider).groupsStream();
});

// Single group stream by ID
final groupStreamProvider =
    StreamProvider.family<Group?, String>((ref, groupId) {
  return ref.watch(groupServiceProvider).groupStream(groupId);
});

// Provider for getting all groups as a Future
final allGroupsProvider = FutureProvider<List<Group>>((ref) {
  return ref.watch(groupServiceProvider).getAllGroups();
});

// Provider for getting groups for a specific user
final userGroupsProvider =
    FutureProvider.family<List<Group>, String>((ref, userId) {
  return ref.watch(groupServiceProvider).getGroupsForUser(userId);
});

// ----------------- USER WITH GROUPS STATE -----------------

// Unified provider for getting users with resolved groups
final userWithGroupsProvider =
    Provider.family<AsyncValue<AppUser?>, String?>((ref, userId) {
  // If userId is null, use current user
  final targetId = userId ?? ref.watch(firebaseAuthStateProvider).value?.uid;
  if (targetId == null) return const AsyncValue.data(null);

  // Get user and groups asynchronously
  final userValue = ref.watch(getUserProvider(targetId));
  final groupsValue = ref.watch(groupsStreamProvider);

  // Handle loading state
  if (userValue.isLoading || groupsValue.isLoading) {
    return const AsyncLoading();
  }

  // Handle error states
  if (userValue is AsyncError) {
    return AsyncValue.error(userValue.error!, userValue.stackTrace!);
  }
  if (groupsValue is AsyncError) {
    return AsyncValue.error(groupsValue.error!, groupsValue.stackTrace!);
  }

  // Handle data state
  final user = userValue.value;
  if (user == null) return const AsyncData(null);

  final allGroups = groupsValue.value ?? [];

  // Get user's groups
  final userGroups =
      allGroups.where((group) => user.groupIds.contains(group.id)).toList();

  // Return user with resolved groups
  return AsyncData(user.copyWith(resolvedGroups: userGroups));
});

// Helper provider to get a user by ID
final getUserProvider =
    FutureProvider.family<AppUser?, String>((ref, userId) async {
  // Check cache first
  final cachedUsers = ref.read(cachedUsersProvider);
  if (cachedUsers.containsKey(userId)) {
    return cachedUsers[userId];
  }

  // Get from repository
  final user = await ref.watch(userRepositoryProvider).getUser(userId);

  // Update cache if user exists
  if (user != null) {
    ref
        .read(cachedUsersProvider.notifier)
        .update((state) => {...state, userId: user});
  }

  return user;
});

// Permission checking provider
final hasPermissionProvider = Provider.family<bool, String>((ref, permission) {
  final userState = ref.watch(userWithGroupsProvider(null));

  return userState.when(
    data: (user) {
      if (user == null) return false;

      // Check direct permissions
      if (user.permissions.contains(permission)) {
        return true;
      }

      // Check group permissions
      for (final group in user.groups) {
        if (group.permissions.contains(permission)) {
          return true;
        }
      }

      return false;
    },
    loading: () => false,
    error: (_, __) => false,
  );
});
