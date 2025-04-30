import 'dart:convert';
import 'package:edconnect_admin/core/constants/database_constants.dart';
import 'package:http/http.dart' as http;

class SortingSortingService {
  Future<Map<String, dynamic>> calculateClasses({
    required Map<String, dynamic> responses,
    required Map<String, int> classes,
    required List<Map<String, dynamic>> parameters,
    required bool distributeBiologicalSex,
    required int timeLimit,
    required String surveyId,
    String orgRootCol = customerSpecificRootCollectionName,
  }) async {
    const String serviceUrl =
        'https://class-sorting-service-at2wmap63q-ey.a.run.app';

    final body = {
      'students': responses,
      'class_sizes': classes,
      'parameters': parameters,
      'gender_ratio': {'m': 0.5, 'f': 0.5, 'nb': 0.05},
      'factor_gender': distributeBiologicalSex,
      'time_limit': timeLimit,
    };

    try {
      final response = await http.post(
        Uri.parse(serviceUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData;
      } else {
        throw Exception(
            'Failed to sort classes. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to contact sorting service.');
    }
  }
}
