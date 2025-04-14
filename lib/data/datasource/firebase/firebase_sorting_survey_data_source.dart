import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edconnect_admin/core/constants/database_constants.dart';
import 'package:edconnect_admin/data/datasource/sorting_survey_data_source.dart';
import 'package:edconnect_admin/domain/entities/sorting_survey.dart';

class FirebaseSortingSurveyDataSource implements SortingSurveyDataSource {
  final FirebaseFirestore _firestore;

  FirebaseSortingSurveyDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<SortingSurvey>> getSortingSurveys() async {
    final snapshot = await _firestore
        .collection(customerSpecificCollectionSortingSurveys)
        .orderBy('created_at', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => SortingSurvey.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Stream<List<SortingSurvey>> getSortingSurveysStream() {
    return _firestore
        .collection(customerSpecificCollectionSortingSurveys)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SortingSurvey.fromMap(doc.data(), doc.id))
            .toList());
  }

  @override
  Future<SortingSurvey?> getSortingSurveyById(String id) async {
    final docSnapshot = await _firestore
        .collection(customerSpecificCollectionSortingSurveys)
        .doc(id)
        .get();

    if (!docSnapshot.exists || docSnapshot.data() == null) {
      return null;
    }

    return SortingSurvey.fromMap(docSnapshot.data()!, docSnapshot.id);
  }

  @override
  Future<String> createSortingSurvey(SortingSurvey survey) async {
    final docRef = await _firestore
        .collection(customerSpecificCollectionSortingSurveys)
        .add(survey.toMap());

    return docRef.id;
  }

  @override
  Future<void> updateSortingSurvey(SortingSurvey survey) async {
    await _firestore
        .collection(customerSpecificCollectionSortingSurveys)
        .doc(survey.id)
        .update(survey.toMap());
  }

  @override
  Future<void> deleteSortingSurvey(String id) async {
    await _firestore
        .collection(customerSpecificCollectionSortingSurveys)
        .doc(id)
        .delete();
  }
}
