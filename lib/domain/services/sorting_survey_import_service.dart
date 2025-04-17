import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import '../entities/sorting_survey.dart';

class ResponseImportService {
  final _columnMappings = {
    'first_name': ['first_name', 'vorname'],
    'last_name': ['last_name', 'nachname'],
    'sex': ['sex', 'geschlecht'],
    'preferences': ['preferences', 'freundeswuensche'],
  };

  Future<(List<String>, List<List<dynamic>>)> parseFile(
      List<int> bytes, String fileType) async {
    return switch (fileType) {
      'xlsx' => await _parseExcel(bytes),
      'csv' => await _parseCsv(bytes),
      _ => throw UnsupportedError('Unsupported file format'),
    };
  }

  Future<(List<String>, List<List<dynamic>>)> _parseExcel(
      List<int> bytes) async {
    final excel = Excel.decodeBytes(bytes);
    final sheet = excel.tables[excel.tables.keys.first]!;

    final headers = sheet
        .row(0)
        .map((cell) => _formatValue((cell?.value?.toString() ?? '').trim()))
        .where((header) => header.isNotEmpty)
        .toList();

    final rows = <List<dynamic>>[];
    for (var i = 1; i < sheet.maxRows; i++) {
      final row = sheet.row(i);
      if (row.any((cell) => cell?.value != null)) {
        rows.add(List.generate(
          headers.length,
          (index) => index < row.length ? row[index]?.value : null,
        ));
      }
    }

    return (headers, rows);
  }

  Future<(List<String>, List<List<dynamic>>)> _parseCsv(List<int> bytes) async {
    // Use UTF-8 decoding with replacement strategy
    final csvString = utf8.decode(bytes, allowMalformed: true);
    final delimiter = _detectCsvDelimiter(csvString);

    final csv = CsvToListConverter(
      fieldDelimiter: delimiter,
      eol: '\n',
      shouldParseNumbers: false,
    ).convert(csvString);

    if (csv.isEmpty) throw Exception('CSV file is empty');

    final headers = csv[0]
        .map((e) => _formatValue(_normalizeUmlauts(e.toString().trim())))
        .where((header) => header.isNotEmpty)
        .toList();

    print('Headers found: ${headers.join(', ')}');

    final rows = csv
        .sublist(1)
        .where((row) => row
            .any((cell) => cell != null && cell.toString().trim().isNotEmpty))
        .map((row) => List.generate(
              headers.length,
              (index) => index < row.length
                  ? _normalizeUmlauts(row[index]?.toString().trim() ?? '')
                  : null,
            ))
        .toList();

    return (headers, rows);
  }

  String _normalizeUmlauts(String text) {
    return text
        .replaceAll('ä', 'ae')
        .replaceAll('ö', 'oe')
        .replaceAll('ü', 'ue')
        .replaceAll('Ä', 'Ae')
        .replaceAll('Ö', 'Oe')
        .replaceAll('Ü', 'Ue')
        .replaceAll('ß', 'ss')
        .replaceAll('-', '_');
  }

  String _formatValue(String value) => value
      .toLowerCase()
      .trim()
      .replaceAll(RegExp(r'\s+'), '_')
      // Remove any remaining special characters after normalizing umlauts
      .replaceAll(RegExp(r'[^a-z0-9_]'), '')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');

  String _detectCsvDelimiter(String csvString) {
    final delimiters = [';', ',', '|', '\t'];
    final firstLine = csvString.split('\n').first;

    final counts = {for (var d in delimiters) d: firstLine.split(d).length - 1};

    return counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  (Map<String, dynamic>, List<String>) processData(
    List<String> headers,
    List<List<dynamic>> rows,
    SortingSurvey survey,
  ) {
    // Find column indices using formatted names for comparison
    Map<String, int> columnIndices = {};
    for (final entry in _columnMappings.entries) {
      final index = headers.indexWhere((h) {
        final formattedHeader = _formatValue(h);
        return entry.value.any((name) => _formatValue(name) == formattedHeader);
      });

      if (index != -1) {
        columnIndices[entry.key] = index;
      }
    }

    // Check for missing required columns
    final requiredKeys = [
      'first_name',
      'last_name',
      if (survey.askBiologicalSex) 'sex',
    ];

    final missingColumns =
        requiredKeys.where((key) => !columnIndices.containsKey(key)).toList();

    if (missingColumns.isNotEmpty) {
      throw Exception('Missing required columns: ${missingColumns.join(', ')}');
    }

    // Process rows
    Map<String, Map<String, dynamic>> responses = {};
    Map<String, String> nameToIdMap = {};
    List<String> duplicates = [];

    // First pass: create responses and build name mapping
    for (final row in rows) {
      final firstName = _getValue(row, columnIndices['first_name']!);
      final lastName = _getValue(row, columnIndices['last_name']!);

      if (firstName.isEmpty || lastName.isEmpty) continue;

      final responseId =
          'manual_${DateTime.now().millisecondsSinceEpoch}_${responses.length}';
      final fullName = '$firstName $lastName'.toLowerCase();
      nameToIdMap[fullName] = responseId;

      // Check for duplicates
      final isDuplicate = survey.responses.values.any((existing) {
        final existingName =
            '${existing['_first_name']} ${existing['_last_name']}'
                .toLowerCase();
        return existingName == fullName;
      });
      if (isDuplicate) {
        duplicates.add('$firstName $lastName');
      }

      final response = {
        '_manual_entry': true,
        '_first_name': firstName,
        '_last_name': lastName,
      };

      if (survey.askBiologicalSex) {
        final sex = _formatSexValue(_getValue(row, columnIndices['sex']!));
        if (sex == null) {
          throw Exception('Invalid sex value for $firstName $lastName');
        }
        response['sex'] = sex;
      }

      responses[responseId] = response;
    }

    // Second pass: add preferences and parameters
    for (final responseId in responses.keys) {
      final response = responses[responseId]!;
      final rowIndex = responses.keys.toList().indexOf(responseId);

      // Handle preferences
      if (survey.maxPreferences != null &&
          columnIndices.containsKey('preferences')) {
        final prefsString =
            _getValue(rows[rowIndex], columnIndices['preferences']!);
        final prefNames = prefsString
            .split(',')
            .map((p) => p.trim().toLowerCase())
            .where((p) => p.isNotEmpty)
            .toList();

        final prefs = prefNames
            .map((name) => nameToIdMap[name])
            .where((id) => id != null && id != responseId)
            .take(survey.maxPreferences!)
            .toList();

        if (prefs.isNotEmpty) {
          response['prefs'] = prefs;
        }
      }

      // Add parameters
      for (final param in survey.parameters) {
        final paramIndex =
            headers.indexWhere((h) => h == _formatValue(param['name']));
        if (paramIndex != -1) {
          final value = _getValue(rows[rowIndex], paramIndex);
          response[param['name']] = param['type'] == 'binary'
              ? _formatBinaryValue(value)
              : _formatValue(value);
        }
      }
    }

    return (
      {
        'responses': responses,
        'parameters': survey.parameters,
        'has_preferences': survey.maxPreferences != null,
        'ask_biological_sex': survey.askBiologicalSex,
      },
      duplicates
    );
  }

  String _getValue(List<dynamic> row, int index) =>
      (row[index]?.toString() ?? '').trim();

  String? _formatSexValue(String value) {
    final v = value.toLowerCase().trim();
    if (v.startsWith('m') || v.contains('männ')) return 'm';
    if (v.startsWith('f') || v.startsWith('w') || v.contains('weib')) {
      return 'f';
    }
    if (v.startsWith('nb') ||
        v.contains('non') ||
        v.contains('other') ||
        v.startsWith('d') ||
        v.contains('divers')) {
      return 'nb';
    }
    return null;
  }

  String _formatBinaryValue(String value) {
    final v = value.toLowerCase().trim();
    if (v.startsWith('y') ||
        v == '1' ||
        v == 'true' ||
        v.startsWith('j') ||
        v == 'ja') {
      return 'yes';
    }
    return 'no';
  }
}
