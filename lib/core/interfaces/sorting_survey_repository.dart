import 'package:edconnect_admin/domain/entities/sorting_survey.dart';

abstract class SortingSurveyRepository {
  Future<List<SortingSurvey>> getSortingSurveys();
  Stream<List<SortingSurvey>> getSortingSurveysStream();
  Future<SortingSurvey?> getSortingSurveyById(String id);
  Future<String> createSortingSurvey(SortingSurvey survey);
  Future<void> updateSortingSurvey(SortingSurvey survey);
  Future<void> deleteSortingSurvey(String id);
}
