import 'package:edconnect_admin/core/interfaces/auth_repository.dart';
import 'package:edconnect_admin/core/interfaces/localization_repository.dart';
import 'package:edconnect_admin/core/interfaces/user_repository.dart';
import 'package:edconnect_admin/domain/entities/group.dart';
import 'package:edconnect_admin/domain/entities/sorting_survey.dart';
import 'package:edconnect_admin/domain/providers/usecase_providers.dart';
import 'package:edconnect_admin/domain/services/group_service.dart';
import 'package:edconnect_admin/domain/services/sorting_survey_import_service.dart';
import 'package:edconnect_admin/domain/services/sorting_survey_sorting_service.dart';
import 'package:edconnect_admin/domain/usecases/sorting_survey_use_case.dart';
import 'package:edconnect_admin/presentation/providers/action_providers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  void updateAuthStatus(AuthStatus status) {
    state = status;
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

/// Provider to hold authentication errors, separate from the auth state
final authErrorProvider = StateProvider<AuthError?>((ref) => null);

/// Represents authentication errors with user-friendly messages
class AuthError {
  final String code;
  final String message;
  final Object? originalError;

  const AuthError({
    required this.code,
    required this.message,
    this.originalError,
  });

  /// Factory to create error from Firebase exceptions
  factory AuthError.fromFirebaseException(
      FirebaseAuthException e, LocalizationRepository localizations) {
    final localizedStrings = localizations.getErrorStrings();
    return AuthError(
      code: e.code,
      message: switch (e.code) {
        'wrong-password' => localizedStrings['errorInvalidPassword']!,
        'user-not-found' => localizedStrings['errorUserNotFound']!,
        'invalid-email' => localizedStrings['errorInvalidEmail']!,
        'too-many-requests' => 'Too many attempts. Please try again later.',
        _ => e.message ?? localizedStrings['errorUnexpected']!,
      },
      originalError: e,
    );
  }

  /// Create a generic error
  factory AuthError.unexpected(
      Object error, LocalizationRepository localizations) {
    return AuthError(
      code: 'unexpected',
      message: localizations.getErrorStrings()['errorUnexpected']!,
      originalError: error,
    );
  }
}

// ---------------- APP LOCALE STATE  -----------------
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en'));

  void updateLocale(Locale locale) {
    state = locale;
  }
}

// Create a StateNotifierProvider for the locale
final appLocaleProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
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
  final groupsValue = ref.watch(allGroupsStreamProvider);

  if (user == null) return null;

  return groupsValue.when(
    data: (groups) {
      final userGroups = user.groupIds
          .map((id) => groups.where((g) => g.id == id).firstOrNull)
          .whereType<Group>()
          .toList();

      return user.copyWith(resolvedGroups: userGroups);
    },
    loading: () => user,
    error: (_, __) => user,
  );
});

// ---------------- PAGINATION STATE -----------------
class PaginationState {
  final int currentPage;
  final int itemsPerPage;
  final int totalItems;
  final int totalPages;

  const PaginationState({
    this.currentPage = 0,
    this.itemsPerPage = 10,
    this.totalItems = 0,
    this.totalPages = 0,
  });

  PaginationState copyWith({
    int? currentPage,
    int? itemsPerPage,
    int? totalItems,
    int? totalPages,
  }) {
    return PaginationState(
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      totalItems: totalItems ?? this.totalItems,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}

final paginationInitProvider =
    Provider.family<AsyncValue<void>, String>((ref, surveyId) {
  final responses = ref.watch(filteredResponsesProvider(surveyId));

  return responses.when(
    data: (data) {
      // Return success state instead of directly modifying
      return const AsyncValue.data(null);
    },
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
});

final paginationStateProvider =
    StateNotifierProvider.family<PaginationNotifier, PaginationState, String>(
        (ref, key) {
  return PaginationNotifier();
});

class PaginationNotifier extends StateNotifier<PaginationState> {
  PaginationNotifier() : super(const PaginationState());

  void setTotalItems(int total) {
    // Calculate total pages correctly
    final totalPages = (total / state.itemsPerPage).ceil();
    state = state.copyWith(
      totalItems: total,
      totalPages: totalPages,
      // Reset to page 0 if current page would be out of bounds
      currentPage: state.currentPage >= totalPages ? 0 : state.currentPage,
    );
  }

  void setPage(int page) {
    // Ensure page is within bounds
    if (page >= 0 && page < state.totalPages) {
      state = state.copyWith(currentPage: page);
    }
  }

  void setItemsPerPage(int items) {
    // Recalculate total pages when changing items per page
    final newTotalPages = (state.totalItems / items).ceil();
    state = state.copyWith(
      itemsPerPage: items,
      totalPages: newTotalPages,
      // Reset to page 0 when changing items per page
      currentPage: 0,
    );
  }
}

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

// ---------------- USER MANAGEMENT STATE  -----------------
final allUsersStreamProvider = StreamProvider<List<AppUser>>((ref) {
  final userManagementUseCase = ref.watch(userManagementUseCaseProvider);
  return userManagementUseCase.getAllUsers();
});

final filteredUsersProvider = Provider<AsyncValue<List<AppUser>>>((ref) {
  final usersAsync = ref.watch(allUsersStreamProvider);
  final searchQuery = ref.watch(userSearchQueryProvider);

  return usersAsync.when(
    data: (users) {
      if (searchQuery.isEmpty) return AsyncValue.data(users);

      return AsyncValue.data(users
          .where((user) =>
              user.fullName.toLowerCase().contains(searchQuery.toLowerCase()) ||
              user.email.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList());
    },
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
});

final userSearchQueryProvider = StateProvider<String>((ref) => '');

// ---------------- MODULES STATE  -----------------

// ---------------- SORTING SURVEY MODULE STATE -----------------

// Base stream provider for all surveys
final sortingSurveysProvider = StreamProvider<List<SortingSurvey>>((ref) {
  final useCase = ref.watch(sortingSurveyUseCaseProvider);
  return useCase.getSortingSurveysStream();
});

// Provider for selected survey ID
final selectedSortingSurveyIdProvider = StateProvider<String?>((ref) => null);

// Provider that streams a specific survey by ID
final selectedSortingSurveyProvider =
    Provider.family<AsyncValue<SortingSurvey?>, String>((ref, id) {
  final surveysAsync = ref.watch(sortingSurveysProvider);

  // Properly propagate loading state
  return surveysAsync.when(
    data: (surveys) {
      final matchingSurvey =
          surveys.where((survey) => survey.id == id).firstOrNull;
      return AsyncValue.data(matchingSurvey);
    },
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
});

final surveyLoadingStateProvider = StateProvider<bool>((ref) => false);

// For convenience when using providers that need the selected ID
final getSortingSurveyByIdProvider = Provider<SortingSurvey?>((ref) {
  final selectedId = ref.watch(selectedSortingSurveyIdProvider);
  if (selectedId == null) return null;

  final surveyAsync = ref.watch(selectedSortingSurveyProvider(selectedId));
  return surveyAsync.value;
});

// Response filter state
enum SortOrder { asc, desc }

class ResponsesFilterState {
  final String searchQuery;
  final Map<String, String?> parameterFilters;
  final SortOrder sortOrder;

  const ResponsesFilterState({
    this.searchQuery = '',
    this.parameterFilters = const {},
    this.sortOrder = SortOrder.asc,
  });

  ResponsesFilterState copyWith({
    String? searchQuery,
    Map<String, String?>? parameterFilters,
    SortOrder? sortOrder,
  }) {
    return ResponsesFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      parameterFilters: parameterFilters ?? this.parameterFilters,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

final selectedSurveyResponsesProvider =
    Provider.family<AsyncValue<Map<String, Map<String, dynamic>>>, String>(
        (ref, surveyId) {
  // This automatically starts watching the responses when requested
  return ref.watch(filteredResponsesProvider(surveyId));
});

final responsesFilterProvider =
    StateProvider.family<ResponsesFilterState, String>(
        (ref, surveyId) => const ResponsesFilterState());

// Filtered responses provider with streaming updates
final filteredResponsesProvider =
    Provider.family<AsyncValue<Map<String, Map<String, dynamic>>>, String>(
        (ref, surveyId) {
  // Watch the survey to get updates
  final surveyAsync = ref.watch(selectedSortingSurveyProvider(surveyId));

  // Watch the filter to get filter updates
  final filter = ref.watch(responsesFilterProvider(surveyId));

  // Get users for enriching response data
  final usersAsync = ref.watch(allUsersStreamProvider);

  // Process based on current state
  if (!surveyAsync.hasValue || surveyAsync.value == null) {
    return surveyAsync.hasError
        ? AsyncValue.error(surveyAsync.error!, surveyAsync.stackTrace!)
        : const AsyncValue.loading();
  }

  // Safe null check
  final survey = surveyAsync.value!;

  // Start with all responses
  final responses = survey.responses;

  // Apply search filter
  final filtered = filter.searchQuery.isEmpty
      ? Map<String, Map<String, dynamic>>.from(responses)
      : Map.fromEntries(responses.entries.where((entry) {
          final data = entry.value;
          final fullName =
              '${data['_first_name'] ?? ''} ${data['_last_name'] ?? ''}'
                  .toLowerCase();
          return fullName.contains(filter.searchQuery.toLowerCase());
        }));

  // Apply parameter filters
  final afterParamFilter = filter.parameterFilters.isEmpty
      ? filtered
      : Map.fromEntries(filtered.entries.where((entry) {
          return filter.parameterFilters.entries.every((paramFilter) {
            // Skip filter if no value selected
            if (paramFilter.value == null) return true;
            // Match parameter value with filter
            return entry.value[paramFilter.key]?.toString() ==
                paramFilter.value;
          });
        }));

  // Add user information to responses (if we have users)
  final enrichedResponses =
      Map<String, Map<String, dynamic>>.from(afterParamFilter);

  if (usersAsync.hasValue && usersAsync.value != null) {
    final users = usersAsync.value!;

    // Update entries in place
    enrichedResponses.forEach((userId, response) {
      if (response['_manual_entry'] != true) {
        final user = users.firstWhere(
          (u) => u.id == userId,
          orElse: () => AppUser(
            id: userId,
            firstName: 'Unknown',
            lastName: 'User',
            email: '',
            fcmTokens: [],
            groupIds: [],
            permissions: [],
            deviceIds: {},
            accountType: '',
          ),
        );

        // Create a copy and update
        final updatedResponse = Map<String, dynamic>.from(response);
        updatedResponse['_first_name'] = user.firstName;
        updatedResponse['_last_name'] = user.lastName;
        enrichedResponses[userId] = updatedResponse;
      }
    });
  }

  // Sort by name (fixed type issue)
  final sortedEntries = enrichedResponses.entries.toList()
    ..sort((a, b) {
      final nameA =
          '${a.value['_first_name'] ?? ''} ${a.value['_last_name'] ?? ''}'
              .toLowerCase();
      final nameB =
          '${b.value['_first_name'] ?? ''} ${b.value['_last_name'] ?? ''}'
              .toLowerCase();
      return filter.sortOrder == SortOrder.asc
          ? nameA.compareTo(nameB)
          : nameB.compareTo(nameA);
    });

  // Convert entries back to map with proper types
  final sortedResponses =
      Map<String, Map<String, dynamic>>.fromEntries(sortedEntries);

  return AsyncValue.data(sortedResponses);
});

// Paginated responses provider for UI
final paginatedResponsesProvider =
    Provider.family<List<MapEntry<String, Map<String, dynamic>>>, String>(
        (ref, surveyId) {
  final filteredResponsesAsync = ref.watch(filteredResponsesProvider(surveyId));
  final paginationState =
      ref.watch(paginationStateProvider('responses_$surveyId'));

  if (!filteredResponsesAsync.hasValue) {
    return [];
  }

  final responses = filteredResponsesAsync.value!;
  final allEntries = responses.entries.toList();

  // Update pagination total count safely
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ref
        .read(paginationStateProvider('responses_$surveyId').notifier)
        .setTotalItems(responses.length);
  });

  if (allEntries.isEmpty) return [];

  final start = paginationState.currentPage * paginationState.itemsPerPage;
  final end = start + paginationState.itemsPerPage;

  if (start >= allEntries.length) return [];

  return allEntries.sublist(
      start, end < allEntries.length ? end : allEntries.length);
});

class ImportState {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? previewData;
  final List<String>? duplicates;

  const ImportState({
    this.isLoading = false,
    this.error,
    this.previewData,
    this.duplicates,
  });

  ImportState copyWith({
    bool? isLoading,
    String? error,
    Map<String, dynamic>? previewData,
    List<String>? duplicates,
    bool clearError = false,
  }) {
    return ImportState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      previewData: previewData ?? this.previewData,
      duplicates: duplicates ?? this.duplicates,
    );
  }
}

class ResponseImportNotifier extends StateNotifier<ImportState> {
  final ResponseImportService _service;
  final Ref _ref;

  ResponseImportNotifier(this._service, this._ref) : super(const ImportState());

  void reset() {
    state = const ImportState();
  }

  Future<void> parseFile(PlatformFile file, SortingSurvey survey) async {
    state = const ImportState(isLoading: true);

    try {
      final (headers, rows) = await _service.parseFile(
        file.bytes!,
        file.extension!,
      );

      final (data, duplicates) = _service.processData(headers, rows, survey);

      state = ImportState(
        previewData: data,
        duplicates: duplicates,
      );
    } catch (e) {
      state = ImportState(error: e.toString());
    }
  }

  Future<void> confirmImport(SortingSurvey survey) async {
    if (state.previewData == null) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _ref
          .read(sortingSurveyNotifierProvider.notifier)
          .updateSortingSurvey(
            survey.copyWith(
              responses: {
                ...survey.responses,
                ...state.previewData!['responses'] as Map<String, dynamic>,
              },
            ),
          );
      state = const ImportState();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final responseImportProvider =
    StateNotifierProvider<ResponseImportNotifier, ImportState>((ref) {
  return ResponseImportNotifier(
    ResponseImportService(),
    ref,
  );
});

class SurveyFilterState {
  final String searchQuery;
  final SortingSurveyStatus? statusFilter;
  final SurveySortOrder sortOrder;

  const SurveyFilterState({
    this.searchQuery = '',
    this.statusFilter,
    this.sortOrder = SurveySortOrder.newest,
  });

  SurveyFilterState copyWith({
    String? searchQuery,
    SortingSurveyStatus? statusFilter,
    bool clearStatusFilter = false,
    SurveySortOrder? sortOrder,
  }) {
    return SurveyFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter:
          clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

// Provider for the current filter state
final surveyFilterProvider = StateProvider<SurveyFilterState>((ref) {
  return const SurveyFilterState();
});

// Provider that applies filters to the surveys
final filteredSortingSurveysProvider =
    Provider<AsyncValue<List<SortingSurvey>>>((ref) {
  final surveysAsync = ref.watch(sortingSurveysProvider);
  final filters = ref.watch(surveyFilterProvider);

  return surveysAsync.when(
    data: (surveys) {
      if (surveys.isEmpty) return const AsyncValue.data([]);

      // Apply filters
      var filtered = [...surveys];

      // Search filter
      if (filters.searchQuery.isNotEmpty) {
        final query = filters.searchQuery.toLowerCase();
        filtered = filtered
            .where((s) =>
                s.title.toLowerCase().contains(query) ||
                s.description.toLowerCase().contains(query))
            .toList();
      }

      // Status filter
      if (filters.statusFilter != null) {
        filtered =
            filtered.where((s) => s.status == filters.statusFilter).toList();
      }

      // Apply sorting
      switch (filters.sortOrder) {
        case SurveySortOrder.newest:
          filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
        case SurveySortOrder.oldest:
          filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          break;
        case SurveySortOrder.alphabetical:
          filtered.sort((a, b) => a.title.compareTo(b.title));
          break;
      }

      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
});

class CalculationState {
  final bool isCalculating;
  final String? error;
  final Map<String, dynamic>? result;

  const CalculationState({
    this.isCalculating = false,
    this.error,
    this.result,
  });

  CalculationState copyWith({
    bool? isCalculating,
    String? error,
    Map<String, dynamic>? result,
    bool clearError = false,
  }) {
    return CalculationState(
      isCalculating: isCalculating ?? this.isCalculating,
      error: clearError ? null : (error ?? this.error),
      result: result ?? this.result,
    );
  }
}

final classSortingServiceProvider = Provider((ref) => SortingSortingService());

final surveyTabIndexProvider =
    StateProvider.family<int, String>((ref, surveyId) => 0);

final calculationStateProvider =
    StateNotifierProvider<CalculationNotifier, CalculationState>((ref) {
  return CalculationNotifier(
    ref.watch(classSortingServiceProvider),
    ref.watch(sortingSurveyUseCaseProvider),
  );
});

class CalculationNotifier extends StateNotifier<CalculationState> {
  final SortingSortingService _service;
  final SortingSurveyUseCase _surveyUseCase;

  CalculationNotifier(this._service, this._surveyUseCase)
      : super(const CalculationState());

  Future<void> calculate({
    required Map<String, dynamic> responses,
    required Map<String, int> classes,
    required List<Map<String, dynamic>> parameters,
    required bool distributeBiologicalSex,
    required int timeLimit,
    required String surveyId,
  }) async {
    state = const CalculationState(isCalculating: true);

    try {
      final result = await _service.calculateClasses(
        responses: responses,
        classes: classes,
        parameters: parameters,
        distributeBiologicalSex: distributeBiologicalSex,
        timeLimit: timeLimit,
        surveyId: surveyId,
      );

      await _surveyUseCase.saveCalculationResults(surveyId, result);

      state = CalculationState(result: result);
    } catch (e) {
      state = CalculationState(error: e.toString());
    }
  }
}
