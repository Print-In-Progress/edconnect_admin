Map<String, dynamic> calculatePreferenceSatisfaction(
    Map<String, List<String>> currentResults,
    Map<String, dynamic> surveyResponses) {
  int satisfiedPreferences = 0;
  int totalPreferences = 0;
  Set<String> studentsWithSatisfiedPrefs = {};
  Set<String> studentsWithPreferences = {};

  for (final entry in currentResults.entries) {
    final studentsInClass = Set<String>.from(entry.value);

    for (final studentId in entry.value) {
      final response = surveyResponses[studentId];
      if (response == null) continue;

      final prefs = response['prefs'] as List?;
      if (prefs == null || prefs.isEmpty) continue;

      int studentSatisfiedPrefs = 0;
      int studentTotalPrefs = 0;

      for (final pref in prefs) {
        if (pref is String) {
          studentTotalPrefs++;
          if (studentsInClass.contains(pref)) {
            studentSatisfiedPrefs++;
          }
        }
      }

      if (studentTotalPrefs > 0) {
        studentsWithPreferences.add(studentId);
      }

      totalPreferences += studentTotalPrefs;
      satisfiedPreferences += studentSatisfiedPrefs;

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
