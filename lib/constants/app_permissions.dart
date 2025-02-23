class AppPermissions {
  // Role-based permissions
  static const String admin = 'admin';
  static const String author = 'author';

  // Article permissions
  static const String editArticles = 'edit_articles';
  static const String createArticles = 'create_articles';

  // Event permissions
  static const String editEvents = 'edit_events';
  static const String createEvents = 'create_events';

  // Survey permissions
  static const String editSurveys = 'edit_surveys';
  static const String createSurveys = 'create_surveys';

  // Other permissions
  static const String userManagement = 'user_management';
  static const String fileManagement = 'file_management';
  static const String pushNotifications = 'push_not';
  static const String digitalLibrary = 'digital_library';

  // Permission groups
  static const List<String> articlePermissions = [
    admin,
    author,
    editArticles,
    createArticles
  ];

  static const List<String> eventPermissions = [
    admin,
    author,
    editEvents,
    createEvents
  ];

  static const List<String> surveyPermissions = [
    admin,
    author,
    editSurveys,
    createSurveys
  ];

  static const List<String> adminPermissions = [admin, author];
}
