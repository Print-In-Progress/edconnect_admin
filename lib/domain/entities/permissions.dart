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
  final String displayName;
  final String description;
  final PermissionCategory category;

  const Permission({
    required this.id,
    required this.displayName,
    required this.description,
    required this.category,
  });
}

/// Central registry of all application permissions
class Permissions {
  // Role-based permissions
  static const Permission admin = Permission(
    id: 'admin',
    displayName: 'Administrator',
    description: 'Full system access',
    category: PermissionCategory.role,
  );

  static const Permission author = Permission(
    id: 'author',
    displayName: 'Author',
    description: 'Can create and manage content',
    category: PermissionCategory.role,
  );

  // Article permissions
  static const Permission createArticles = Permission(
    id: 'create_articles',
    displayName: 'Create Articles',
    description: 'Can create new articles',
    category: PermissionCategory.content,
  );

  static const Permission editArticles = Permission(
    id: 'edit_articles',
    displayName: 'Edit Articles',
    description: 'Can modify existing articles',
    category: PermissionCategory.content,
  );

  // Event permissions
  static const Permission createEvents = Permission(
    id: 'create_events',
    displayName: 'Create Events',
    description: 'Can create new events',
    category: PermissionCategory.content,
  );

  static const Permission editEvents = Permission(
    id: 'edit_events',
    displayName: 'Edit Events',
    description: 'Can modify existing events',
    category: PermissionCategory.content,
  );

  // Survey permissions
  static const Permission createSurveys = Permission(
    id: 'create_surveys',
    displayName: 'Create Surveys',
    description: 'Can create new surveys',
    category: PermissionCategory.survey,
  );

  static const Permission editSurveys = Permission(
    id: 'edit_surveys',
    displayName: 'Edit Surveys',
    description: 'Can modify existing surveys',
    category: PermissionCategory.survey,
  );

  // User management permissions
  static const Permission userManagement = Permission(
    id: 'user_management',
    displayName: 'User Management',
    description: 'Can manage users and their permissions',
    category: PermissionCategory.user,
  );

  // Media permissions
  static const Permission fileManagement = Permission(
    id: 'file_management',
    displayName: 'File Management',
    description: 'Can upload and manage files',
    category: PermissionCategory.media,
  );

  static const Permission digitalLibrary = Permission(
    id: 'digital_library',
    displayName: 'Digital Library',
    description: 'Can access and manage digital library',
    category: PermissionCategory.media,
  );

  // Notification permissions
  static const Permission pushNotifications = Permission(
    id: 'push_not',
    displayName: 'Push Notifications',
    description: 'Can send push notifications',
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

  // Get all permission IDs
  static List<String> get allPermissionIds =>
      allPermissions.map((p) => p.id).toList();

  // Get permission by ID - Fixed return type!
  static Permission? getById(String id) {
    try {
      return allPermissions.firstWhere((p) => p.id == id);
    } catch (e) {
      return null; // Return null if not found
    }
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

  // Get permissions display data for UI
  static List<Map<String, dynamic>> getPermissionsForDisplay() {
    return allPermissions
        .map((p) => {
              'id': p.id,
              'displayName': p.displayName,
              'description': p.description,
              'category': p.category.toString().split('.').last,
            })
        .toList();
  }
}
