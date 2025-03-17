import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edconnect_admin/data/datasource/theme_data_source.dart';
import '../../../constants/database_constants.dart';

class FirebaseRemoteThemeDataSource implements RemoteThemeDataSource {
  final FirebaseFirestore _firestore;

  FirebaseRemoteThemeDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Map<String, dynamic>?> fetchThemeSettings() async {
    try {
      final doc = await _firestore
          .collection(customerSpecificRootCollectionName)
          .doc('newsapp')
          .get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return doc.data()!;
    } catch (e) {
      print('Error fetching remote theme: $e');
      return null;
    }
  }
}
