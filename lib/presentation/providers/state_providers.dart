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

// ---------------- MODULES STATE  -----------------

// ---------------- SORTING SURVEY MODULE STATE  -----------------
final sortingSurveysProvider = StreamProvider<List<SortingSurvey>>((ref) {
  return ref.watch(sortingSurveyUseCaseProvider).getSortingSurveysStream();
});

final selectedSortingSurveyIdProvider = StateProvider<String?>((ref) => null);

// Provider for the currently selected survey details
final selectedSortingSurveyProvider =
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
