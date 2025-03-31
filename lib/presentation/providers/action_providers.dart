import 'package:edconnect_admin/domain/entities/storage_file.dart';
import 'package:edconnect_admin/domain/entities/storage_module.dart';
import 'package:edconnect_admin/domain/usecases/auth/delete_account_use_case.dart';
import 'package:edconnect_admin/domain/usecases/auth/sign_in_usecase.dart';
import 'package:edconnect_admin/domain/usecases/auth/sign_out_use_case.dart';
import 'package:edconnect_admin/domain/usecases/auth/sign_up_usecase.dart';
import 'package:edconnect_admin/domain/usecases/auth/user_credential_repository.dart';
import 'package:edconnect_admin/domain/usecases/auth/user_profile_use_case.dart';
import 'package:edconnect_admin/domain/entities/registration_fields.dart';
import 'package:edconnect_admin/domain/utils/registration_utils.dart';
import 'package:edconnect_admin/domain/utils/validation_utils.dart';
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
      final result = await _signUpUseCase.signUp(request);
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

class SignUpWithExistingAuthAccountNotifier
    extends StateNotifier<AsyncValue<String?>> {
  final SignUpUseCase _useCase;

  SignUpWithExistingAuthAccountNotifier(this._useCase)
      : super(const AsyncValue.data(null));

  Future<void> signUpWithExistingAuthAccount(
      RegistrationRequest request) async {
    state = const AsyncValue.loading();

    try {
      final result = await _useCase.signUpWithExistingAuthAccount(request);
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

final signUpWithExistingAuthAccountNotifierProvider = StateNotifierProvider<
    SignUpWithExistingAuthAccountNotifier, AsyncValue<String?>>((ref) {
  return SignUpWithExistingAuthAccountNotifier(ref.read(signUpUseCaseProvider));
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

// ---------------- USER ACTIONS -----------------

class RegistrationUpdateNotifier extends StateNotifier<AsyncValue<void>> {
  final UserProfileDataUseCase _useCase;
  final Ref _ref;

  RegistrationUpdateNotifier(this._useCase, this._ref)
      : super(const AsyncValue.data(null));

  Future<void> submitUpdate(
    List<BaseRegistrationField> fields,
    String firstName,
    String lastName,
  ) async {
    state = const AsyncValue.loading();

    try {
      // Get current user
      final user = _ref.read(currentUserProvider).value;
      if (user == null) throw Exception('No user logged in');

      // Update name first
      await _useCase.changeName(user.id, firstName, lastName);

      // Convert BaseRegistrationField to RegistrationField and filter valid fields
      final registrationFields = fields.whereType<RegistrationField>().toList();

      // Flatten and validate fields
      final flattenedFields = flattenRegistrationFields(registrationFields);
      final validationError = validateRegistrationFields(flattenedFields);
      if (validationError.isNotEmpty) {
        throw Exception(validationError);
      }

      // Submit registration update
      await _useCase.submitRegistrationUpdate(user, registrationFields);

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final registrationUpdateProvider =
    StateNotifierProvider<RegistrationUpdateNotifier, AsyncValue<void>>((ref) {
  return RegistrationUpdateNotifier(
    ref.read(userProfileDataUseCaseProvider),
    ref,
  );
});

class ChangeNameNotifier extends StateNotifier<AsyncValue<void>> {
  final UserProfileDataUseCase _useCase;

  ChangeNameNotifier(this._useCase) : super(const AsyncValue.data(null));

  Future<void> changeName(
      String userId, String firstName, String lastName) async {
    state = const AsyncValue.loading();

    try {
      await _useCase.changeName(userId, firstName, lastName);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final changeNameProvider =
    StateNotifierProvider<ChangeNameNotifier, AsyncValue<void>>((ref) {
  return ChangeNameNotifier(ref.read(userProfileDataUseCaseProvider));
});

class UpdateEmailNotifier extends StateNotifier<AsyncValue<void>> {
  final UserCredentialsUseCase _useCase;

  UpdateEmailNotifier(this._useCase) : super(const AsyncValue.data(null));

  Future<void> updateEmail(String newEmail) async {
    state = const AsyncValue.loading();

    try {
      final result = await _useCase.changeEmail(newEmail);
      if (result != null) {
        throw Exception(result);
      }
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final updateEmailProvider =
    StateNotifierProvider<UpdateEmailNotifier, AsyncValue<void>>((ref) {
  return UpdateEmailNotifier(ref.read(userCredentialsUseCaseProvider));
});

class ReauthenticateNotifier extends StateNotifier<AsyncValue<void>> {
  final UserCredentialsUseCase _useCase;

  ReauthenticateNotifier(this._useCase) : super(const AsyncValue.data(null));

  Future<void> reauthenticate(String password) async {
    state = const AsyncValue.loading();

    try {
      final result = await _useCase.reauthenticate(password);
      if (result != null) {
        throw Exception(result);
      }
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final reauthenticateProvider =
    StateNotifierProvider<ReauthenticateNotifier, AsyncValue<void>>((ref) {
  return ReauthenticateNotifier(ref.read(userCredentialsUseCaseProvider));
});

class ChangePasswordNotifier extends StateNotifier<AsyncValue<void>> {
  final UserCredentialsUseCase _useCase;

  ChangePasswordNotifier(this._useCase) : super(const AsyncValue.data(null));

  Future<void> changePassword(String newPassword) async {
    state = const AsyncValue.loading();

    try {
      final result = await _useCase.changePassword(newPassword);
      if (result != null) {
        throw Exception(result);
      }
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final changePasswordProvider =
    StateNotifierProvider<ChangePasswordNotifier, AsyncValue<void>>((ref) {
  return ChangePasswordNotifier(ref.read(userCredentialsUseCaseProvider));
});

class ResetPasswordNotifier extends StateNotifier<AsyncValue<void>> {
  final UserCredentialsUseCase _useCase;

  ResetPasswordNotifier(this._useCase) : super(const AsyncValue.data(null));

  Future<void> resetPassword(String email) async {
    state = const AsyncValue.loading();

    try {
      final result = await _useCase.resetPassword(email);
      if (result != null) {
        throw Exception(result);
      }
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final resetPasswordProvider =
    StateNotifierProvider<ResetPasswordNotifier, AsyncValue<void>>((ref) {
  return ResetPasswordNotifier(ref.read(userCredentialsUseCaseProvider));
});

class DeleteAccountNotifier extends StateNotifier<AsyncValue<void>> {
  final DeleteAccountUseCase _useCase;

  DeleteAccountNotifier(this._useCase) : super(const AsyncValue.data(null));

  Future<void> deleteAccount(String password) async {
    state = const AsyncValue.loading();

    try {
      await _useCase.execute(password);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final deleteAccountProvider =
    StateNotifierProvider<DeleteAccountNotifier, AsyncValue<void>>((ref) {
  return DeleteAccountNotifier(ref.read(deleteAccountUseCaseProvider));
});

final registrationFieldsProvider =
    FutureProvider<List<BaseRegistrationField>>((ref) {
  return ref.read(getRegistrationFieldsUseCaseProvider).execute();
});

// ----------------- FILE ACTIONS -----------------
final storageFilesProvider =
    FutureProvider.family<List<StorageFile>, String>((ref, path) async {
  final storageRepo = ref.watch(storageRepositoryProvider);
  return await storageRepo.listFiles(path);
});

// Multiple modules storage files provider
final moduleStorageFilesProvider =
    FutureProvider.family<List<StorageFile>, Set<StorageModule>>(
        (ref, modules) async {
  final storageRepo = ref.watch(storageRepositoryProvider);

  // Get files from all selected modules
  final filesLists = await Future.wait(
      modules.map((module) => storageRepo.listFiles(module.path)));

  // Combine all files into a single list
  return filesLists.expand((files) => files).toList();
});
