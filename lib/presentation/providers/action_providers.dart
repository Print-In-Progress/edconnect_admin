import 'package:edconnect_admin/domain/usecases/auth/sign_in_usecase.dart';
import 'package:edconnect_admin/domain/usecases/auth/sign_out_use_case.dart';
import 'package:edconnect_admin/domain/usecases/auth/sign_up_usecase.dart';
import 'package:edconnect_admin/presentation/providers/state_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/registration_request.dart';
import '../../domain/providers/usecase_providers.dart';
import '../../core/providers/interface_providers.dart';

// ----------------- AUTH ACTIONS -----------------

// Send email verification action.
final sendEmailVerificationProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    await ref.read(authRepositoryProvider).sendEmailVerification();
  };
});

// Check email verification status action.
final checkEmailVerificationProvider = Provider<Future<bool> Function()>((ref) {
  return () async {
    await ref.read(authRepositoryProvider).reloadUser();
    return await ref.read(authRepositoryProvider).isEmailVerified();
  };
});

// Sign-up notifier.
class SignUpNotifier extends StateNotifier<AsyncValue<String?>> {
  final SignUpUseCase _signUpUseCase;

  SignUpNotifier(this._signUpUseCase) : super(const AsyncValue.data(null));

  Future<void> signUp(RegistrationRequest request) async {
    state = const AsyncValue.loading();

    try {
      final result = await _signUpUseCase.execute(request);
      if (result == null) {
        state = const AsyncValue.data(null); // Success
      } else {
        state = AsyncValue.error(result, StackTrace.current);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// Sign-up provider.
final signUpNotifierProvider =
    StateNotifierProvider<SignUpNotifier, AsyncValue<String?>>((ref) {
  return SignUpNotifier(ref.read(signUpUseCaseProvider));
});

// Login notifier.
class LoginNotifier extends StateNotifier<AsyncValue<void>> {
  final SignInUseCase _signInUseCase;
  final Ref _ref;

  LoginNotifier(this._signInUseCase, this._ref)
      : super(const AsyncValue.data(null));

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();

    try {
      // Set auth state to authenticating
      _ref.read(authStatusProvider.notifier).state = AuthStatus.authenticating;

      final result = await _signInUseCase.execute(email, password);
      if (result != null) {
        state = AsyncValue.error(result, StackTrace.current);
        _ref.read(authStatusProvider.notifier).state =
            AuthStatus.unauthenticated;
        return;
      }

      state = const AsyncValue.data(null);
      // Auth state will be automatically updated by the listener in AuthStateNotifier
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      _ref.read(authStatusProvider.notifier).state = AuthStatus.unauthenticated;
    }
  }
}

// Updated login provider
final loginStateProvider =
    StateNotifierProvider<LoginNotifier, AsyncValue<void>>((ref) {
  return LoginNotifier(
    ref.read(signInUseCaseProvider),
    ref,
  );
});

// Sign-out notifier.
class SignOutNotifier extends StateNotifier<AsyncValue<void>> {
  final SignOutUseCase _signOutUseCase;

  SignOutNotifier(this._signOutUseCase) : super(const AsyncValue.data(null));

  Future<void> signOut() async {
    state = const AsyncValue.loading();

    try {
      await _signOutUseCase.execute();
      state = const AsyncValue.data(null); // Success
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// Sign-out provider.
final signOutStateProvider =
    StateNotifierProvider<SignOutNotifier, AsyncValue<void>>((ref) {
  return SignOutNotifier(ref.read(signOutUseCaseProvider));
});
