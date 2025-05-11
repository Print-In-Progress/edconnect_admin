Map<String, dynamic> calculatePreferenceSatisfaction(
    Map<String, List<String>> currentResults,
    Map<String, dynamic> surveyResponses) {
  int satisfiedPreferences = 0;
  int totalPreferences = 0;
  Set<String> studentsWithSatisfiedPrefs = {};
  Set<String> studentsWithPreferences = {};

  // Loop through each class and its students
  for (final entry in currentResults.entries) {
    final studentsInClass = Set<String>.from(entry.value);

    // Check each student's preferences
    for (final studentId in entry.value) {
      final response = surveyResponses[studentId];
      if (response == null) continue;

      final prefs = response['prefs'] as List?;
      if (prefs == null || prefs.isEmpty) continue;

      // Count how many preferences are satisfied for this student
      int studentSatisfiedPrefs = 0;
      int studentTotalPrefs = 0;

      for (final pref in prefs) {
        if (pref is String) {
          studentTotalPrefs++;
          // Check if preferred student is in the same class
          if (studentsInClass.contains(pref)) {
            studentSatisfiedPrefs++;
          }
        }
      }

      // Track students who have preferences
      if (studentTotalPrefs > 0) {
        studentsWithPreferences.add(studentId);
      }

      // Update counters
      totalPreferences += studentTotalPrefs;
      satisfiedPreferences += studentSatisfiedPrefs;

      // Track students with at least one preference satisfied
      if (studentSatisfiedPrefs > 0) {
        studentsWithSatisfiedPrefs.add(studentId);
      }
    }
  }

  return {
    'satisfiedPreferences': satisfiedPreferences,
    'totalPreferences': totalPreferences,
    'studentsWithSatisfiedPrefs': studentsWithSatisfiedPrefs.length,
    'studentsWithPreferences': studentsWithPreferences.length,
  };
}
