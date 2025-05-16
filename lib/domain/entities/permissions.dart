import 'package:edconnect_admin/core/interfaces/localization_repository.dart';

enum PermissionCategory {
  role, // Core roles like admin, author
  content, // Content management (articles, events)
  user, // User management features
  media, // Media handling features
  notification, // Notification systems
  settings, // System settings
  survey, // Survey features
}

/// Represents an application permission
class Permission {
  final String id;
  final String displayNameKey;
  final String descriptionKey;
  final PermissionCategory category;

  const Permission({
    required this.id,
    required this.displayNameKey,
    required this.descriptionKey,
    required this.category,
  });

  String getDisplayName(LocalizationRepository localization) {
    final strings = localization.getPermissionsStrings();
    return strings[displayNameKey] ?? displayNameKey;
  }

  // Get localized description using the repository
  String getDescription(LocalizationRepository localization) {
    final strings = localization.getPermissionsStrings();
    return strings[descriptionKey] ?? descriptionKey;
  }
}

/// Central registry of all application permissions
class Permissions {
  // Role-based permissions

  static const Permission admin = Permission(
    id: 'admin',
    displayNameKey: 'userManagementPermissionsAdministrator',
    descriptionKey: 'userManagementPermissionsAdministratorDescription',
    category: PermissionCategory.role,
  );

  static const Permission author = Permission(
    id: 'author',
    displayNameKey: 'userManagementPermissionsAuthor',
    descriptionKey: 'userManagementPermissionsAuthorDescription',
    category: PermissionCategory.role,
  );

  // Article permissions
  static const Permission createArticles = Permission(
    id: 'create_articles',
    displayNameKey: 'userManagementPermissionsCreateArticles',
    descriptionKey: 'userManagementPermissionsCreateArticlesDescription',
    category: PermissionCategory.content,
  );

  static const Permission editArticles = Permission(
    id: 'edit_articles',
    displayNameKey: 'userManagementPermissionsEditArticles',
    descriptionKey: 'userManagementPermissionsEditArticlesDescription',
    category: PermissionCategory.content,
  );

  // Event permissions
  static const Permission createEvents = Permission(
    id: 'create_events',
    displayNameKey: 'userManagementPermissionsCreateEvents',
    descriptionKey: 'userManagementPermissionsCreateEventsDescription',
    category: PermissionCategory.content,
  );

  static const Permission editEvents = Permission(
    id: 'edit_events',
    displayNameKey: 'userManagementPermissionsEditEvents',
    descriptionKey: 'userManagementPermissionsEditEventsDescription',
    category: PermissionCategory.content,
  );

  // Survey permissions
  static const Permission createSurveys = Permission(
    id: 'create_surveys',
    displayNameKey: 'userManagementPermissionsCreateSurveys',
    descriptionKey: 'userManagementPermissionsCreateSurveysDescription',
    category: PermissionCategory.survey,
  );

  static const Permission editSurveys = Permission(
    id: 'edit_surveys',
    displayNameKey: 'userManagementPermissionsEditSurveys',
    descriptionKey: 'userManagementPermissionsEditSurveysDescription',
    category: PermissionCategory.survey,
  );

  // User management permissions
  static const Permission userManagement = Permission(
    id: 'user_management',
    displayNameKey: 'userManagementPermissionsUserManagement',
    descriptionKey: 'userManagementPermissionsUserManagementDescription',
    category: PermissionCategory.user,
  );

  // Media permissions
  static const Permission fileManagement = Permission(
    id: 'file_management',
    displayNameKey: 'userManagementFileManagement',
    descriptionKey: 'userManagementFileManagementDescription',
    category: PermissionCategory.media,
  );

  // Additional permissions - add these to your localization repository
  static const Permission digitalLibrary = Permission(
    id: 'digital_library',
    displayNameKey: 'userManagementPermissionsDigitalLibrary',
    descriptionKey: 'userManagementPermissionsDigitalLibraryDescription',
    category: PermissionCategory.media,
  );

  static const Permission pushNotifications = Permission(
    id: 'push_not',
    displayNameKey: 'userManagementPermissionsPushNotifications',
    descriptionKey: 'userManagementPermissionsPushNotificationsDescription',
    category: PermissionCategory.notification,
  );

  // Permission sets
  static const List<Permission> allPermissions = [
    admin,
    author,
    createArticles,
    editArticles,
    createEvents,
    editEvents,
    createSurveys,
    editSurveys,
    userManagement,
    fileManagement,
    digitalLibrary,
    pushNotifications,
  ];

  static List<String> get allPermissionIds =>
      allPermissions.map((p) => p.id).toList();

  static Permission? getById(String id) {
    try {
      return allPermissions.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  static Permission? getByIdWithLocalization(
      String id, LocalizationRepository localization) {
    final permission = getById(id);
    return permission;
  }

  // Permission sets by feature
  static final Map<String, List<String>> featurePermissionSets = {
    'articles': [admin.id, author.id, createArticles.id, editArticles.id],
    'events': [admin.id, author.id, createEvents.id, editEvents.id],
    'surveys': [admin.id, author.id, createSurveys.id, editSurveys.id],
    'dashboard': [admin.id],
    'users': [admin.id, userManagement.id],
    'media': [admin.id, author.id, fileManagement.id],
    'digital_library': [admin.id, author.id, digitalLibrary.id],
    'push_notifications': [admin.id, pushNotifications.id],
    'admin_settings': [admin.id],
  };

  // Get permissions by category
  static List<Permission> getByCategory(PermissionCategory category) =>
      allPermissions.where((p) => p.category == category).toList();

  static List<Map<String, dynamic>> getPermissionsForDisplay(
      LocalizationRepository localization) {
    return allPermissions
        .map((p) => {
              'id': p.id,
              'displayName': p.getDisplayName(localization),
              'description': p.getDescription(localization),
              'category': p.category.toString().split('.').last,
            })
        .toList();
  }
}
