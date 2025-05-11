import 'dart:math' as math;

Map<String, int> countVariables({
  required Map<String, dynamic> students,
  required Map<String, int> classes,
  required List<Map<String, dynamic>> parameters,
  required bool factorGender,
}) {
  final result = <String, int>{};

  // 1. Base assignment variables (one per student-class pair)
  final assignmentVars = students.length * classes.length;
  result['assignmentVariables'] = assignmentVars;

  // 2. Parameter variables
  int parameterVars = 0;
  int binaryParamVars = 0;
  int categoricalParamVars = 0;

  for (var param in parameters) {
    String paramName = param['name'];
    String paramType = param['type'] ?? 'binary';
    String strategy = param['strategy'] ?? 'distribute';

    if (paramType == 'binary') {
      // Count students with "yes" value
      final yesStudents = students.entries
          .where((entry) => entry.value[paramName] == 'yes')
          .length;

      if (strategy == 'concentrate') {
        // Objective function variables (affected by number of students with "yes")
        binaryParamVars += 5 + (yesStudents > 0 ? 2 : 0);
      } else {
        // 'distribute'
        // Create constraints based on count of "yes" students
        if (yesStudents > 0) {
          // More yes students = more complex constraints
          int distributionComplexity = math.min(yesStudents, classes.length);
          binaryParamVars += classes.length * 2 + distributionComplexity;
        } else {
          // No yes students = simpler constraints
          binaryParamVars += classes.length;
        }
      }
    } else {
      // 'categorical'
      // Count unique values for this parameter
      final uniqueValues = <String>{};
      students.forEach((_, studentData) {
        if (studentData[paramName] != null) {
          uniqueValues.add(studentData[paramName].toString());
        }
      });

      if (strategy == 'concentrate') {
        // Creates boolean variable for each value-class pair
        categoricalParamVars += uniqueValues.length * classes.length;

        // Additional variables for minimization objective
        categoricalParamVars += uniqueValues.length * classes.length;
      } else {
        // 'distribute'
        // Creates constraints for each value-class pair (2 vars per constraint)
        categoricalParamVars += uniqueValues.length * classes.length * 2;
      }
    }
  }

  result['binaryParamVariables'] = binaryParamVars;
  result['categoricalParamVariables'] = categoricalParamVars;
  parameterVars = binaryParamVars + categoricalParamVars;
  result['parameterVariables'] = parameterVars;

  // 3. Preference pair variables
  int prefPairVars = 0;
  int totalPreferences = 0;

  // First count valid preferences
  students.forEach((studentId, studentData) {
    final prefs = studentData['prefs'] as List? ?? [];

    for (final friendId in prefs) {
      // Only count if friend exists in students
      if (students.containsKey(friendId)) {
        totalPreferences++;

        // For each class, we create a pair_in_class variable
        prefPairVars += classes.length;

        // Each constraint adds approximately 2 more variables
        prefPairVars += classes.length * 2;
      }
    }
  });

  result['preferenceVariables'] = prefPairVars;
  result['totalPreferences'] = totalPreferences;

  // 4. Gender constraint variables
  int genderVars = 0;
  if (factorGender) {
    // Count unique genders
    final genders = <String>{};
    students.forEach((_, s) => genders.add(s['sex'] ?? 'unknown'));

    // Each gender constraint adds approximately 2 variables
    genderVars = genders.length * classes.length * 2;
  }
  result['genderVariables'] = genderVars;

  // 5. Class balancing (when no preferences)
  int balancingVars = 0;
  if (totalPreferences == 0) {
    // Class size balancing constraints add 2 variables per class
    balancingVars = classes.length * 2;
  }
  result['balancingVariables'] = balancingVars;

  // Total variables
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

  // Calculate preference density
  int totalPrefs = varCounts['totalPreferences']!;
  double prefDensity =
      students.isEmpty ? 0 : totalPrefs / (students.length * students.length);

  // Determine complexity rating

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
