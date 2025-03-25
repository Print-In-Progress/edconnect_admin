import 'package:edconnect_admin/core/models/app_user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/registration_request.dart';
import '../../domain/services/auth_service.dart';
import '../../domain/usecases/auth/sign_in_usecase.dart';
import '../../domain/usecases/auth/sign_out_use_case.dart';
import '../../domain/providers/service_providers.dart';
import '../../domain/providers/usecase_providers.dart';
import '../../core/providers/interface_providers.dart';
import 'state_providers.dart';

// ----------------- AUTH ACTIONS -----------------

// Send email verification action
final sendEmailVerificationProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    await ref.read(authRepositoryProvider).sendEmailVerification();
  };
});

// Check email verification status action
final checkEmailVerificationProvider = Provider<Future<bool> Function()>((ref) {
  return () async {
    final isVerified = await ref.read(authRepositoryProvider).isEmailVerified();
    ref.read(emailVerificationProvider.notifier).state = isVerified;
    return isVerified;
  };
});

// Sign-up state notifier
final signUpNotifierProvider =
    StateNotifierProvider<SignUpNotifier, AsyncValue<String?>>((ref) {
  return SignUpNotifier(ref.read(authServiceProvider));
});

class SignUpNotifier extends StateNotifier<AsyncValue<String?>> {
  final AuthService _authService;

  SignUpNotifier(this._authService) : super(const AsyncValue.data(null));

  Future<void> signUp(RegistrationRequest request) async {
    state = const AsyncValue.loading();

    try {
      final result = await _authService.signUp(request);
      if (result == null) {
        state = const AsyncValue.data(null); // Success
      } else {
        state =
            AsyncValue.error(result, StackTrace.current); // Error with message
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// Login state notifier
final loginStateProvider =
    StateNotifierProvider<LoginNotifier, AsyncValue<void>>((ref) {
  return LoginNotifier(ref.read(signInUseCaseProvider));
});

class LoginNotifier extends StateNotifier<AsyncValue<void>> {
  final SignInUseCase _signInUseCase;

  LoginNotifier(this._signInUseCase) : super(const AsyncValue.data(null));

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();

    try {
      await _signInUseCase.execute(email, password);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// Sign-out state notifier
final signOutStateProvider =
    StateNotifierProvider<SignOutNotifier, AsyncValue<void>>((ref) {
  return SignOutNotifier(ref.read(signOutUseCaseProvider));
});

class SignOutNotifier extends StateNotifier<AsyncValue<void>> {
  final SignOutUseCase _signOutUseCase;

  SignOutNotifier(this._signOutUseCase) : super(const AsyncValue.data(null));

  Future<void> signOut() async {
    state = const AsyncValue.loading();

    try {
      await _signOutUseCase.execute();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// ----------------- USER ACTIONS -----------------

// Refresh user data manually
final refreshUserProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    // Clear the cached user for the current user ID
    final userId = ref.read(firebaseAuthStateProvider).value?.uid;
    if (userId != null) {
      ref.read(cachedUsersProvider.notifier).update((state) {
        final newState = Map<String, AppUser>.from(state);
        newState.remove(userId);
        return newState;
      });
    }

    // Force refresh the providers
    ref.invalidate(currentUserProvider);
    ref.invalidate(getUserProvider(userId ?? ''));
  };
});

// ----------------- GROUP ACTIONS -----------------

// Add user to group action
final addUserToGroupProvider =
    Provider<Future<void> Function(String userId, String groupId)>((ref) {
  return (userId, groupId) async {
    await ref.read(groupServiceProvider).addUserToGroup(userId, groupId);
    // Refresh user data to reflect changes
    ref.invalidate(getUserProvider(userId));
  };
});

// Remove user from group action
final removeUserFromGroupProvider =
    Provider<Future<void> Function(String userId, String groupId)>((ref) {
  return (userId, groupId) async {
    await ref.read(groupServiceProvider).removeUserFromGroup(userId, groupId);
    // Refresh user data to reflect changes
    ref.invalidate(getUserProvider(userId));
  };
});

// Update user's groups action
final updateUserGroupsProvider =
    Provider<Future<void> Function(String userId, List<String> groupIds)>(
        (ref) {
  return (userId, groupIds) async {
    await ref.read(groupServiceProvider).updateUserGroups(userId, groupIds);
    // Refresh user data to reflect changes
    ref.invalidate(getUserProvider(userId));
  };
});
