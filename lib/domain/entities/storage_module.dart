import 'package:edconnect_admin/constants/database_constants.dart';

enum StorageModule {
  articles('Articles', '$customerSpecificCollectionFiles/articles'),
  personalStorage(
      'Personal Storage', '$customerSpecificCollectionFiles/personal_storage'),
  library('Library', '$customerSpecificCollectionFiles/library'),
  registrationFiles('Registration Files',
      '$customerSpecificCollectionFiles/registration_files'),
  ;

  final String displayName;
  final String path;

  const StorageModule(this.displayName, this.path);
}
