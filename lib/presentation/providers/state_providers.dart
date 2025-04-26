import 'package:edconnect_admin/core/interfaces/auth_repository.dart';
import 'package:edconnect_admin/core/interfaces/user_repository.dart';
import 'package:edconnect_admin/domain/entities/group.dart';
import 'package:edconnect_admin/domain/entities/sorting_survey.dart';
import 'package:edconnect_admin/domain/providers/usecase_providers.dart';
import 'package:edconnect_admin/domain/services/group_service.dart';
import 'package:edconnect_admin/domain/services/sorting_survey_import_service.dart';
import 'package:edconnect_admin/presentation/providers/action_providers.dart';
import 'package:file_picker/file_picker.dart';
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

// ---------------- SORTING SURVEY MODULE STATE  -----------------
final sortingSurveysProvider = StreamProvider<List<SortingSurvey>>((ref) {
  return ref.watch(sortingSurveyUseCaseProvider).getSortingSurveysStream();
});

final selectedSortingSurveyIdProvider = StateProvider<String?>((ref) => null);

class SurveyFilterState {
  final String searchQuery;
  final SortingSurveyStatus? statusFilter;
  final SurveySortOrder sortOrder;

  const SurveyFilterState({
    this.searchQuery = '',
    this.statusFilter,
    this.sortOrder = SurveySortOrder.newestFirst,
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

// Filter state provider
final surveyFilterProvider = StateProvider<SurveyFilterState>((ref) {
  return const SurveyFilterState();
});

// Filtered surveys provider
final filteredSortingSurveysProvider =
    Provider<AsyncValue<List<SortingSurvey>>>((ref) {
  final surveysResult = ref.watch(sortingSurveysProvider);
  final filterState = ref.watch(surveyFilterProvider);

  return surveysResult.when(
    data: (surveys) {
      var filtered = List<SortingSurvey>.from(surveys);

      // Apply search filter
      if (filterState.searchQuery.isNotEmpty) {
        filtered = filtered
            .where((survey) =>
                survey.title
                    .toLowerCase()
                    .contains(filterState.searchQuery.toLowerCase()) ||
                survey.description
                    .toLowerCase()
                    .contains(filterState.searchQuery.toLowerCase()))
            .toList();
      }

      // Apply status filter
      if (filterState.statusFilter != null) {
        filtered = filtered
            .where((survey) => survey.status == filterState.statusFilter)
            .toList();
      }

      // Apply sorting
      switch (filterState.sortOrder) {
        case SurveySortOrder.newestFirst:
          filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
        case SurveySortOrder.oldestFirst:
          filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          break;
        case SurveySortOrder.alphabetical:
          filtered.sort((a, b) => a.title.compareTo(b.title));
          break;
        case SurveySortOrder.status:
          filtered.sort((a, b) => a.status.index.compareTo(b.status.index));
          break;
      }

      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
});

final selectedSortingSurveyProvider =
    Provider.family<AsyncValue<SortingSurvey?>, String>(
  (ref, surveyId) {
    // Watch the notifier state to trigger rebuilds
    ref.watch(sortingSurveyNotifierProvider);
    return ref.watch(getSortingSurveyByIdProvider);
  },
);

// Update getSortingSurveyByIdProvider to be autoDispose
final getSortingSurveyByIdProvider =
    FutureProvider.autoDispose<SortingSurvey?>((ref) async {
  final id = ref.watch(selectedSortingSurveyIdProvider);
  if (id == null) return null;

  final useCase = ref.watch(sortingSurveyUseCaseProvider);
  return await useCase.getSortingSurveyById(id);
});

// Create a new provider to handle response prefetching
final sortingSurveyResponsesPrefetchProvider =
    Provider.family<void, String>((ref, surveyId) {
  // Watch notifier state
  ref.watch(sortingSurveyNotifierProvider);

  // Watch filtered responses
  ref.watch(filteredResponsesProvider(surveyId));

  // Watch pagination state
  ref.watch(paginationStateProvider(surveyId));
});

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

enum SortOrder { asc, desc }

// Filter state provider for responses
final responsesFilterProvider =
    StateProvider.family<ResponsesFilterState, String>(
  (ref, surveyId) => const ResponsesFilterState(),
);

final filteredResponsesProvider =
    Provider.family<AsyncValue<Map<String, Map<String, dynamic>>>, String>(
  (ref, surveyId) {
    ref.watch(sortingSurveyNotifierProvider);
    final surveyAsync = ref.watch(selectedSortingSurveyProvider(surveyId));
    final filterState = ref.watch(responsesFilterProvider(surveyId));
    final users = ref.watch(allUsersStreamProvider).value ?? [];

    return surveyAsync.when(
      data: (survey) {
        if (survey == null) return const AsyncValue.data({});

        var filtered = Map<String, Map<String, dynamic>>.from(survey.responses);

        // Transform UIDs to names for non-manual entries
        filtered = Map.fromEntries(
          filtered.entries.map((entry) {
            var response = Map<String, dynamic>.from(entry.value);

            // Skip manual entries as they already have names
            if (response['_manual_entry'] == true) {
              return MapEntry(entry.key, response);
            }

            // Find matching user
            final user = users.firstWhere(
              (u) => u.id == entry.key,
              orElse: () => AppUser(
                id: entry.key,
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

            // Add first and last name to response data
            response['_first_name'] = user.firstName;
            response['_last_name'] = user.lastName;

            return MapEntry(entry.key, response);
          }),
        );

        // Apply search filter
        if (filterState.searchQuery.isNotEmpty) {
          filtered = Map.fromEntries(
            filtered.entries.where((entry) {
              final firstName = entry.value['_first_name']?.toString() ?? '';
              final lastName = entry.value['_last_name']?.toString() ?? '';
              final fullName = '$firstName $lastName';
              return fullName
                  .toLowerCase()
                  .contains(filterState.searchQuery.toLowerCase());
            }),
          );
        }

        // Apply parameter filters
        if (filterState.parameterFilters.isNotEmpty) {
          filtered = Map.fromEntries(
            filtered.entries.where((entry) {
              return filterState.parameterFilters.entries.every((filter) {
                if (filter.value == null) return true;
                return entry.value[filter.key]?.toString() == filter.value;
              });
            }),
          );
        }

        // Apply sorting
        var sortedEntries = filtered.entries.toList();
        sortedEntries.sort((a, b) {
          final aName = '${a.value['_first_name']} ${a.value['_last_name']}';
          final bName = '${b.value['_first_name']} ${b.value['_last_name']}';
          return filterState.sortOrder == SortOrder.asc
              ? aName.compareTo(bName)
              : bName.compareTo(aName);
        });

        Future.microtask(() {
          ref
              .read(paginationStateProvider('responses_$surveyId').notifier)
              .setTotalItems(filtered.length);
        });

        return AsyncValue.data(Map.fromEntries(sortedEntries));
      },
      loading: () => const AsyncValue.loading(),
      error: (err, stack) => AsyncValue.error(err, stack),
    );
  },
);

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
