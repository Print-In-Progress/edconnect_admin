import 'package:edconnect_admin/domain/usecases/auth/sign_in_usecase.dart';
import 'package:edconnect_admin/domain/usecases/auth/sign_out_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasource/auth_data_source.dart';
import '../../data/datasource/firebase/firebase_auth_data_source.dart';
import '../../data/datasource/user_data_source.dart';
import '../../data/datasource/firebase/firebase_user_data_source.dart';
import '../../data/datasource/storage_data_source.dart';
import '../../data/datasource/firebase/firebase_storage_data_source.dart';
import '../../data/services/pdf_service.dart';
import '../../data/repositories/firebase_auth_repositories_impl.dart';
import '../../core/interfaces/auth_repository.dart';
import '../../domain/services/auth_service.dart';
import '../../domain/usecases/auth/sign_up_usecase.dart';
import '../../domain/entities/registration_request.dart';
import '../../core/models/app_user.dart';

// ----------------- DATA LAYER PROVIDERS -----------------

// DataSource providers for auth
final authDataSourceProvider = Provider<AuthDataSource>((ref) {
  return FirebaseAuthDataSource();
});

final userDataSourceProvider = Provider<UserDataSource>((ref) {
  return FirebaseUserDataSource();
});

final storageDataSourceProvider = Provider<StorageDataSource>((ref) {
  return FirebaseStorageDataSource();
});

final pdfServiceProvider = Provider<PdfService>((ref) {
  return PdfService();
});

// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepositoryImpl(
    ref.read(authDataSourceProvider),
    ref.read(userDataSourceProvider),
    ref.read(storageDataSourceProvider),
    ref.read(pdfServiceProvider),
  );
});

// ----------------- DOMAIN LAYER PROVIDERS -----------------

// Use case provider
final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  return SignUpUseCase(ref.read(authRepositoryProvider));
});

final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  return SignInUseCase(ref.read(authRepositoryProvider));
});

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
      ref.read(signUpUseCaseProvider), ref.read(signInUseCaseProvider));
});

// ----------------- AUTH STATE PROVIDERS -----------------

// Auth states
enum AuthStatus {
  initial,
  unauthenticated,
  unverified,
  authenticated,
}

// Stream of the current user
final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).currentUserStream;
});

// State provider for tracking email verification status
final emailVerificationProvider = StateProvider<bool>((ref) => false);

// Auth status derived from the user stream and email verification
final authStatusProvider = Provider<AuthStatus>((ref) {
  final userStream = ref.watch(authStateProvider);
  final isVerified = ref.watch(emailVerificationProvider);

  return userStream.when(
    loading: () => AuthStatus.initial,
    error: (_, __) => AuthStatus.unauthenticated,
    data: (user) {
      if (user == null) {
        return AuthStatus.unauthenticated;
      }
      return isVerified ? AuthStatus.authenticated : AuthStatus.unverified;
    },
  );
});

// ----------------- AUTH ACTION PROVIDERS -----------------

// Method to check email verification status
final checkEmailVerificationProvider = Provider<Future<bool> Function()>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);

  return () async {
    final isVerified = await authRepo.isEmailVerified();
    ref.read(emailVerificationProvider.notifier).state = isVerified;
    return isVerified;
  };
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(ref.read(authRepositoryProvider));
});

// Sign out state notifier
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

// Send email verification functionality
final sendEmailVerificationProvider = Provider<Future<void> Function()>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);

  return () async {
    await authRepo.sendEmailVerification();
  };
});

final signUpNotifierProvider =
    StateNotifierProvider<SignUpNotifier, AsyncValue<String?>>((ref) {
  return SignUpNotifier(ref.read(authServiceProvider));
});

// Sign up functionality with state management
class SignUpNotifier extends StateNotifier<AsyncValue<String?>> {
  final AuthService _authService;

  SignUpNotifier(this._authService) : super(const AsyncValue.data(null));

  Future<void> signUp(RegistrationRequest request) async {
    state = const AsyncValue.loading();

    try {
      final result = await _authService.signUp(request);
      if (result == null) {
        // Success
        state = const AsyncValue.data(null);
      } else {
        // Error with message
        state = AsyncValue.error(result, StackTrace.current);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

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
