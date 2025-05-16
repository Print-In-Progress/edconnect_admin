import 'dart:math' as math;

Map<String, int> countVariables({
  required Map<String, dynamic> students,
  required Map<String, int> classes,
  required List<Map<String, dynamic>> parameters,
  required bool factorGender,
}) {
  final result = <String, int>{};

  final assignmentVars = students.length * classes.length;
  result['assignmentVariables'] = assignmentVars;

  int parameterVars = 0;
  int binaryParamVars = 0;
  int categoricalParamVars = 0;

  for (var param in parameters) {
    String paramName = param['name'];
    String paramType = param['type'] ?? 'binary';
    String strategy = param['strategy'] ?? 'distribute';

    if (paramType == 'binary') {
      final yesStudents = students.entries
          .where((entry) => entry.value[paramName] == 'yes')
          .length;

      if (strategy == 'concentrate') {
        binaryParamVars += 5 + (yesStudents > 0 ? 2 : 0);
      } else {
        if (yesStudents > 0) {
          int distributionComplexity = math.min(yesStudents, classes.length);
          binaryParamVars += classes.length * 2 + distributionComplexity;
        } else {
          binaryParamVars += classes.length;
        }
      }
    } else {
      final uniqueValues = <String>{};
      students.forEach((_, studentData) {
        if (studentData[paramName] != null) {
          uniqueValues.add(studentData[paramName].toString());
        }
      });

      if (strategy == 'concentrate') {
        categoricalParamVars += uniqueValues.length * classes.length;

        categoricalParamVars += uniqueValues.length * classes.length;
      } else {
        categoricalParamVars += uniqueValues.length * classes.length * 2;
      }
    }
  }

  result['binaryParamVariables'] = binaryParamVars;
  result['categoricalParamVariables'] = categoricalParamVars;
  parameterVars = binaryParamVars + categoricalParamVars;
  result['parameterVariables'] = parameterVars;

  int prefPairVars = 0;
  int totalPreferences = 0;

  students.forEach((studentId, studentData) {
    final prefs = studentData['prefs'] as List? ?? [];

    for (final friendId in prefs) {
      if (students.containsKey(friendId)) {
        totalPreferences++;

        prefPairVars += classes.length;

        prefPairVars += classes.length * 2;
      }
    }
  });

  result['preferenceVariables'] = prefPairVars;
  result['totalPreferences'] = totalPreferences;

  int genderVars = 0;
  if (factorGender) {
    final genders = <String>{};
    students.forEach((_, s) => genders.add(s['sex'] ?? 'unknown'));

    genderVars = genders.length * classes.length * 2;
  }
  result['genderVariables'] = genderVars;

  int balancingVars = 0;
  if (totalPreferences == 0) {
    balancingVars = classes.length * 2;
  }
  result['balancingVariables'] = balancingVars;

  final totalVars = assignmentVars +
      parameterVars +
      prefPairVars +
      genderVars +
      balancingVars;
  result['totalVariables'] = totalVars;

  return result;
}

/// Estimates solver runtime in seconds based on problem complexity
/// Provides a comprehensive complexity report for the given problem
Map<String, dynamic> generateComplexityReport({
  required Map<String, dynamic> students,
  required Map<String, int> classes,
  required List<Map<String, dynamic>> parameters,
  required bool factorGender,
}) {
  final varCounts = countVariables(
    students: students,
    classes: classes,
    parameters: parameters,
    factorGender: factorGender,
  );

  int totalPrefs = varCounts['totalPreferences']!;
  double prefDensity =
      students.isEmpty ? 0 : totalPrefs / (students.length * students.length);

  return {
    'variables': varCounts,
    'problemSize': {
      'students': students.length,
      'classes': classes.length,
      'parameters': parameters.length,
      'totalPreferences': totalPrefs,
      'preferenceDensity': prefDensity,
    },
  };
}
