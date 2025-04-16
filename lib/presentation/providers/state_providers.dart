import 'package:edconnect_admin/core/interfaces/auth_repository.dart';
import 'package:edconnect_admin/core/interfaces/user_repository.dart';
import 'package:edconnect_admin/domain/entities/group.dart';
import 'package:edconnect_admin/domain/entities/sorting_survey.dart';
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

// Provider for the currently selected survey details
final getSortingSurveyByIdProvider =
    FutureProvider<SortingSurvey?>((ref) async {
  final id = ref.watch(selectedSortingSurveyIdProvider);
  if (id == null) return null;

  final useCase = ref.watch(sortingSurveyUseCaseProvider);
  return await useCase.getSortingSurveyById(id);
});

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
    final surveysAsync = ref.watch(sortingSurveysProvider);

    return surveysAsync.when(
      data: (surveys) {
        final survey = surveys.where((s) => s.id == surveyId).firstOrNull;
        return AsyncValue.data(survey);
      },
      loading: () => const AsyncValue.loading(),
      error: (error, stack) => AsyncValue.error(error, stack),
    );
  },
);

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
    Provider.family<Map<String, Map<String, dynamic>>, String>(
  (ref, surveyId) {
    final surveyAsync = ref.watch(selectedSortingSurveyProvider(surveyId));
    final filterState = ref.watch(responsesFilterProvider(surveyId));
    final users = ref.watch(allUsersStreamProvider).value ?? [];

    return surveyAsync.when(
      data: (survey) {
        if (survey == null) return {};

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

        return Map.fromEntries(sortedEntries);
      },
      loading: () => {},
      error: (_, __) => {},
    );
  },
);
