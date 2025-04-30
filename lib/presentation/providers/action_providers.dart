import 'package:edconnect_admin/core/errors/domain_exception.dart';
import 'package:edconnect_admin/domain/entities/sorting_survey.dart';
import 'package:edconnect_admin/domain/entities/storage_file.dart';
import 'package:edconnect_admin/domain/entities/storage_module.dart';
import 'package:edconnect_admin/domain/usecases/auth/delete_account_use_case.dart';
import 'package:edconnect_admin/domain/usecases/auth/sign_in_usecase.dart';
import 'package:edconnect_admin/domain/usecases/auth/sign_out_use_case.dart';
import 'package:edconnect_admin/domain/usecases/auth/sign_up_usecase.dart';
import 'package:edconnect_admin/domain/usecases/auth/user_credential_repository.dart';
import 'package:edconnect_admin/domain/usecases/auth/user_profile_use_case.dart';
import 'package:edconnect_admin/domain/entities/registration_fields.dart';
import 'package:edconnect_admin/domain/usecases/sorting_survey_use_case.dart';
import 'package:edconnect_admin/domain/usecases/user_management_use_case.dart';
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

class SignUpNotifier extends StateNotifier<AsyncValue<void>> {
  final SignUpUseCase _signUpUseCase;

  SignUpNotifier(this._signUpUseCase) : super(const AsyncValue.data(null));

  Future<void> signUp(RegistrationRequest request) async {
    state = const AsyncValue.loading();

    try {
      await _signUpUseCase.signUp(request);
      state = const AsyncValue.data(null);
    } on DomainException catch (e) {
      if (e.code == ErrorCode.authAccountAlreadyExists) {
        // If account exists in another org, try signing up with existing account
        try {
          await _signUpUseCase.signUpWithExistingAuthAccount(request);
          state = const AsyncValue.data(null);
        } catch (e) {
          state = AsyncValue.error(e, StackTrace.current);
        }
      } else {
        state = AsyncValue.error(e, StackTrace.current);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final signUpNotifierProvider =
    StateNotifierProvider<SignUpNotifier, AsyncValue<void>>((ref) {
  return SignUpNotifier(ref.read(signUpUseCaseProvider));
});

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

      await _signInUseCase.execute(email, password);

      state = const AsyncValue.data(null);
      // Auth state will be automatically updated by the listener in AuthStateNotifier
    } on DomainException catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      _ref.read(authStatusProvider.notifier).state = AuthStatus.unauthenticated;
    } catch (e, stack) {
      state = AsyncValue.error(
        DomainException(
          code: ErrorCode.unexpected,
          type: ExceptionType.unexpected,
          originalError: e,
        ),
        stack,
      );
      _ref.read(authStatusProvider.notifier).state = AuthStatus.unauthenticated;
    }
  }
}

final loginStateProvider =
    StateNotifierProvider<LoginNotifier, AsyncValue<void>>((ref) {
  return LoginNotifier(
    ref.read(signInUseCaseProvider),
    ref,
  );
});

class SignOutNotifier extends StateNotifier<AsyncValue<void>> {
  final SignOutUseCase _signOutUseCase;

  SignOutNotifier(this._signOutUseCase) : super(const AsyncValue.data(null));

  Future<void> signOut() async {
    state = const AsyncValue.loading();

    try {
      await _signOutUseCase.execute();
      state = const AsyncValue.data(null);
    } on DomainException catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    } catch (e, stack) {
      state = AsyncValue.error(
        DomainException(
          code: ErrorCode.unexpected,
          type: ExceptionType.unexpected,
          originalError: e,
        ),
        stack,
      );
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

  int _currentStep = 0;
  int get currentStep => _currentStep;
  RegistrationUpdateNotifier(this._useCase, this._ref)
      : super(const AsyncValue.data(null));

  Future<void> submitUpdate(
    List<BaseRegistrationField> fields,
    String firstName,
    String lastName,
  ) async {
    state = const AsyncValue.loading();
    _currentStep = 0;
    try {
      final user = _ref.read(currentUserProvider).value;
      if (user == null) {
        throw const DomainException(
          code: ErrorCode.userNotFound,
          type: ExceptionType.auth,
        );
      }
      _currentStep = 1;
      final registrationFields = fields.whereType<RegistrationField>().toList();
      _currentStep = 2;
      await _useCase.submitRegistrationUpdate(user, registrationFields);
      _currentStep = 3;
      state = const AsyncValue.data(null);
    } on DomainException catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    } catch (e, stack) {
      state = AsyncValue.error(
        DomainException(
          code: ErrorCode.unexpected,
          type: ExceptionType.unexpected,
          originalError: e,
        ),
        stack,
      );
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
    } on DomainException catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    } catch (e, stack) {
      state = AsyncValue.error(
        DomainException(
          code: ErrorCode.unexpected,
          type: ExceptionType.unexpected,
          originalError: e,
        ),
        stack,
      );
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
      await _useCase.changeEmail(newEmail);
      state = const AsyncValue.data(null);
    } on DomainException catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    } catch (e, stack) {
      state = AsyncValue.error(
        DomainException(
          code: ErrorCode.unexpected,
          type: ExceptionType.unexpected,
          originalError: e,
        ),
        stack,
      );
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
      await _useCase.reauthenticate(password);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(
        DomainException(
          code: ErrorCode.unexpected,
          type: ExceptionType.unexpected,
          originalError: e,
        ),
        stack,
      );
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
      await _useCase.changePassword(newPassword);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(
        DomainException(
          code: ErrorCode.unexpected,
          type: ExceptionType.unexpected,
          originalError: e,
        ),
        stack,
      );
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
      await _useCase.resetPassword(email);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(
        DomainException(
          code: ErrorCode.unexpected,
          type: ExceptionType.unexpected,
          originalError: e,
        ),
        stack,
      );
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

// ---------------- USER MANAGEMENT ACTIONS -----------------
class UserManagementNotifier extends StateNotifier<AsyncValue<void>> {
  final UserManagementUseCase _useCase;

  UserManagementNotifier(this._useCase) : super(const AsyncValue.data(null));

  Future<void> deleteUser(String userId) async {
    state = const AsyncValue.loading();
    try {
      await _useCase.deleteUser(userId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(
        DomainException(
          code: ErrorCode.unexpected,
          type: ExceptionType.unexpected,
          originalError: e,
        ),
        stack,
      );
    }
  }
}

final userManagementProvider =
    StateNotifierProvider<UserManagementNotifier, AsyncValue<void>>((ref) {
  return UserManagementNotifier(ref.watch(userManagementUseCaseProvider));
});

// ---------------- MODULE ACTIONS -----------------

// ---------------- SORTING SURVEY MODULE -----------------
class SortingSurveyNotifier extends StateNotifier<AsyncValue<void>> {
  final SortingSurveyUseCase _useCase;
  final Ref _ref;

  SortingSurveyNotifier(this._useCase, this._ref)
      : super(const AsyncValue.data(null));

  Future<void> _invalidateProviders(String surveyId) async {
    _ref.invalidate(filteredResponsesProvider(surveyId));
  }

  Future<String?> createSortingSurvey(SortingSurvey survey) async {
    state = const AsyncValue.loading();
    try {
      // Get current user for creator info
      final user = await _ref.read(currentUserProvider.future);
      if (user == null) {
        state = const AsyncValue.error(
            DomainException(
              code: ErrorCode.userNotFound,
              type: ExceptionType.auth,
            ),
            StackTrace.empty);
        return null;
      }

      final surveyToCreate = survey.copyWith(
        creatorId: user.id,
        creatorName: "${user.firstName} ${user.lastName}",
        createdAt: DateTime.now(),
      );

      final id = await _useCase.createSortingSurvey(surveyToCreate);
      state = const AsyncValue.data(null);

      return id;
    } catch (e, stack) {
      state = AsyncValue.error(
        DomainException(
          code: ErrorCode.unexpected,
          type: ExceptionType.unexpected,
          originalError: e,
        ),
        stack,
      );
      return null;
    }
  }

  Future<void> updateSortingSurvey(SortingSurvey survey) async {
    state = const AsyncValue.loading();
    try {
      await _useCase.updateSortingSurvey(survey);
      await _invalidateProviders(survey.id);

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteSortingSurvey(String id) async {
    state = const AsyncValue.loading();
    try {
      await _useCase.deleteSortingSurvey(id);
      state = const AsyncValue.data(null);

      _ref.read(selectedSortingSurveyIdProvider.notifier).state = null;
    } catch (e, stack) {
      state = AsyncValue.error(
        DomainException(
          code: ErrorCode.unexpected,
          type: ExceptionType.unexpected,
          originalError: e,
        ),
        stack,
      );
    }
  }

  Future<void> publishSortingSurvey(String id) async {
    state = const AsyncValue.loading();
    try {
      await _useCase.publishSortingSurvey(id);
      await _invalidateProviders(id);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(
        DomainException(
          code: ErrorCode.unexpected,
          type: ExceptionType.unexpected,
          originalError: e,
        ),
        stack,
      );
    }
  }

  Future<void> closeSortingSurvey(String id) async {
    state = const AsyncValue.loading();
    try {
      await _useCase.closeSortingSurvey(id);
      await _invalidateProviders(id);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(
        DomainException(
          code: ErrorCode.unexpected,
          type: ExceptionType.unexpected,
          originalError: e,
        ),
        stack,
      );
    }
  }

  Future<void> addResponse(String surveyId, String responseId,
      Map<String, dynamic> responseData) async {
    state = const AsyncValue.loading();
    try {
      final survey = await _useCase.getSortingSurveyById(surveyId);
      if (survey != null) {
        final updatedResponses = {
          ...survey.responses,
          responseId: responseData
        };
        final updatedSurvey = survey.copyWith(responses: updatedResponses);
        await _useCase.updateSortingSurvey(updatedSurvey);
        await _invalidateProviders(surveyId);
        state = const AsyncValue.data(null);
      } else {
        throw Exception('Survey not found');
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Add a method to delete a single response
  Future<void> deleteResponse(String surveyId, String responseId) async {
    state = const AsyncValue.loading();
    try {
      final survey = await _useCase.getSortingSurveyById(surveyId);
      if (survey != null) {
        final updatedResponses = {...survey.responses};
        updatedResponses.remove(responseId);
        final updatedSurvey = survey.copyWith(responses: updatedResponses);
        await _useCase.updateSortingSurvey(updatedSurvey);
        await _invalidateProviders(surveyId);
        state = const AsyncValue.data(null);
      } else {
        throw Exception('Survey not found');
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Add a method to update a single response
  Future<void> updateResponse(String surveyId, String responseId,
      Map<String, dynamic> responseData) async {
    state = const AsyncValue.loading();
    try {
      final survey = await _useCase.getSortingSurveyById(surveyId);
      if (survey != null) {
        final updatedResponses = {...survey.responses};
        updatedResponses[responseId] = responseData;
        final updatedSurvey = survey.copyWith(responses: updatedResponses);
        await _useCase.updateSortingSurvey(updatedSurvey);
        await _invalidateProviders(surveyId);
        state = const AsyncValue.data(null);
      } else {
        throw Exception('Survey not found');
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Add a method to delete all responses
  Future<void> deleteAllResponses(String surveyId) async {
    state = const AsyncValue.loading();
    try {
      final survey = await _useCase.getSortingSurveyById(surveyId);
      if (survey != null) {
        final updatedSurvey = survey.copyWith(responses: {});
        await _useCase.updateSortingSurvey(updatedSurvey);
        await _invalidateProviders(surveyId);
        state = const AsyncValue.data(null);
      } else {
        throw Exception('Survey not found');
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final sortingSurveyNotifierProvider =
    StateNotifierProvider<SortingSurveyNotifier, AsyncValue<void>>((ref) {
  return SortingSurveyNotifier(
    ref.watch(sortingSurveyUseCaseProvider),
    ref,
  );
});
