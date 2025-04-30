import 'package:edconnect_admin/core/interfaces/sorting_survey_repository.dart';
import 'package:edconnect_admin/domain/entities/sorting_survey.dart';

/// Single use case class for handling all sorting survey operations
class SortingSurveyUseCase {
  final SortingSurveyRepository _repository;

  SortingSurveyUseCase(this._repository);

  /// Get all sorting surveys
  Future<List<SortingSurvey>> getSortingSurveys() {
    return _repository.getSortingSurveys();
  }

  Stream<List<SortingSurvey>> getSortingSurveysStream() {
    return _repository.getSortingSurveysStream();
  }

  /// Get a specific sorting survey by ID
  Future<SortingSurvey?> getSortingSurveyById(String id) {
    return _repository.getSortingSurveyById(id);
  }

  /// Create a new sorting survey
  Future<String> createSortingSurvey(SortingSurvey survey) {
    return _repository.createSortingSurvey(survey);
  }

  /// Update an existing sorting survey
  Future<void> updateSortingSurvey(SortingSurvey survey) {
    return _repository.updateSortingSurvey(survey);
  }

  /// Delete a sorting survey
  Future<void> deleteSortingSurvey(String id) {
    return _repository.deleteSortingSurvey(id);
  }

  /// Publish a survey (changes status to published)
  Future<void> publishSortingSurvey(String id) async {
    final survey = await _repository.getSortingSurveyById(id);
    if (survey != null) {
      final updatedSurvey = survey.copyWith(
        status: SortingSurveyStatus.published,
      );
      await _repository.updateSortingSurvey(updatedSurvey);
    }
  }

  /// Close a survey (changes status to closed)
  Future<void> closeSortingSurvey(String id) async {
    final survey = await _repository.getSortingSurveyById(id);
    if (survey != null) {
      final updatedSurvey = survey.copyWith(
        status: SortingSurveyStatus.closed,
      );
      await _repository.updateSortingSurvey(updatedSurvey);
    }
  }

  /// Save calculation results to a survey
  Future<void> saveCalculationResults(
      String surveyId, Map<String, dynamic> calculationResponse) {
    return _repository.saveCalculationResults(surveyId, calculationResponse);
  }
}
