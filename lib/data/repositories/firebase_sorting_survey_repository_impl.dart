import 'package:edconnect_admin/core/errors/error_handler.dart';
import 'package:edconnect_admin/core/interfaces/sorting_survey_repository.dart';
import 'package:edconnect_admin/data/datasource/sorting_survey_data_source.dart';
import 'package:edconnect_admin/domain/entities/sorting_survey.dart';

class FirebaseSortingSurveyRepositoryImpl implements SortingSurveyRepository {
  final SortingSurveyDataSource _dataSource;

  FirebaseSortingSurveyRepositoryImpl(this._dataSource);

  @override
  Future<List<SortingSurvey>> getSortingSurveys() async {
    try {
      return await _dataSource.getSortingSurveys();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Stream<List<SortingSurvey>> getSortingSurveysStream() {
    try {
      return _dataSource.getSortingSurveysStream();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<SortingSurvey?> getSortingSurveyById(String id) async {
    try {
      return await _dataSource.getSortingSurveyById(id);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<String> createSortingSurvey(SortingSurvey survey) async {
    try {
      return await _dataSource.createSortingSurvey(survey);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> updateSortingSurvey(SortingSurvey survey) async {
    try {
      await _dataSource.updateSortingSurvey(survey);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> deleteSortingSurvey(String id) async {
    try {
      await _dataSource.deleteSortingSurvey(id);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> saveCalculationResults(
      String surveyId, Map<String, dynamic> calculationResponse) async {
    // Get the current survey
    final survey = await getSortingSurveyById(surveyId);
    if (survey == null) {
      throw Exception('Survey not found');
    }

    // Check if calculation was successful
    final success = calculationResponse['success'] as bool;

    if (success) {
      // Extract the data and metrics
      final data = calculationResponse['data'] as Map<String, dynamic>;
      final metrics = calculationResponse['metrics'] as Map<String, dynamic>;

      // Update the survey with the new data
      final updatedSurvey = survey.copyWith(
        calculationResults: data,
        calculationMetrics: metrics,
      );

      // Save to Firestore
      await _dataSource.updateSortingSurvey(updatedSurvey);
    } else {
      // Handle error case
      final error = calculationResponse['error'] as Map<String, dynamic>;
      throw Exception('Calculation failed: ${error['message']}');
    }
  }
}
