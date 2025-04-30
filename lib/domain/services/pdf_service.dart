import 'package:edconnect_admin/core/models/app_user.dart';
import 'package:edconnect_admin/core/utils/crypto_utils.dart';
import 'package:edconnect_admin/domain/entities/registration_fields.dart';
import 'package:edconnect_admin/domain/entities/sorting_survey.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pointycastle/export.dart' as pc;

enum PageSize {
  a4,
  usLetter,
  legal,
  a3,
}

// Add this extension for page size formatting
extension PageSizeExtension on PageSize {
  String get label {
    switch (this) {
      case PageSize.a4:
        return 'A4';
      case PageSize.usLetter:
        return 'US Letter';
      case PageSize.legal:
        return 'Legal';
      case PageSize.a3:
        return 'A3';
    }
  }
}

class PdfService {
  static Future<Uint8List> generateRegistrationPdf(
      List<BaseRegistrationField> flattenedRegistrationList,
      bool signed,
      String uid,
      String orgName,
      String lastName,
      String firstName,
      String email,
      {pc.RSAPublicKey? publicKey}) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          children: [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'edConnect Registration Form',
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text('edConnect Registration Form', textScaleFactor: 2),
            pw.SizedBox(height: 10),
            pw.Text(
              orgName,
              textScaleFactor: 1.5,
            ),
            pw.SizedBox(height: 10),
            pw.Table(
              defaultColumnWidth: const pw.FlexColumnWidth(1),
              children: [
                pw.TableRow(
                  children: [
                    pw.Text(
                      'Last Name',
                      style: pw.TextStyle(
                          fontSize: 14, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'First Name',
                      style: pw.TextStyle(
                          fontSize: 14, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'Email',
                      style: pw.TextStyle(
                          fontSize: 14, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Text(
                      lastName.trim()[0].toUpperCase() +
                          lastName.trim().substring(1),
                      style: pw.TextStyle(
                          fontSize: 14, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      firstName.trim()[0].toUpperCase() +
                          firstName.trim().substring(1),
                      style: pw.TextStyle(
                          fontSize: 14, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      email.trim(),
                      style: pw.TextStyle(
                          fontSize: 14, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Text('edConnect User ID: $uid',
                style: pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 30),
            // free_response x, dropdown x, checkbox x, checkbox_assign_group x, signature, file_upload x, infobox, date x
            for (var field in flattenedRegistrationList)
              pw.Table(
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(2),
                },
                border: const pw.TableBorder(
                  bottom: pw.BorderSide(width: 0.5), // Define a thin border
                ),
                children: [
                  if (field.type == 'free_response')
                    pw.TableRow(
                      children: [
                        pw.Text(field.title,
                            style: pw.TextStyle(
                                fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        pw.Text(field.response!.text,
                            style: const pw.TextStyle(fontSize: 14),
                            textAlign: pw.TextAlign.right),
                      ],
                    ),
                  if (field.type == 'dropdown')
                    pw.TableRow(
                      children: [
                        pw.Text(field.title,
                            style: pw.TextStyle(
                                fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        pw.Text(field.selectedOption!,
                            style: const pw.TextStyle(fontSize: 14),
                            textAlign: pw.TextAlign.right),
                      ],
                    ),
                  if (field.type == 'checkbox')
                    pw.TableRow(
                      children: [
                        pw.Text(field.title,
                            style: pw.TextStyle(
                                fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        pw.Text(field.checked! ? 'Yes' : 'No',
                            style: const pw.TextStyle(fontSize: 14),
                            textAlign: pw.TextAlign.right),
                      ],
                    ),
                  if (field.type == 'checkbox_assign_group')
                    pw.TableRow(
                      children: [
                        pw.Text(field.title,
                            style: pw.TextStyle(
                                fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        pw.Text(field.checked! ? 'Yes' : 'No',
                            style: const pw.TextStyle(fontSize: 14),
                            textAlign: pw.TextAlign.right),
                      ],
                    ),
                  if (field.type == 'date')
                    pw.TableRow(
                      children: [
                        pw.Text(field.title,
                            style: pw.TextStyle(
                                fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        pw.Text(
                            DateFormat.yMd()
                                .format(field.selectedDate!)
                                .toString(),
                            style: const pw.TextStyle(fontSize: 14),
                            textAlign: pw.TextAlign.right),
                      ],
                    ),
                  if (field.type == 'file_upload')
                    pw.TableRow(
                      children: [
                        pw.Text(field.title,
                            style: pw.TextStyle(
                                fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        pw.Text(
                            '${field.file?.length.toString() ?? '0'} files uploaded',
                            style: const pw.TextStyle(fontSize: 14),
                            textAlign: pw.TextAlign.right),
                      ],
                    ),
                ],
              ),
            if (signed)
              pw.Container(
                margin: const pw.EdgeInsets.only(top: 20),
                child: pw.Column(
                  mainAxisSize: pw.MainAxisSize.min,
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'This form was cryptographically signed by the user with the edConnect System.',
                      style: pw.TextStyle(
                        fontSize: 10,
                      ),
                    ),
                    pw.Text(
                      'The public key fingerprint is: ${generatePublicKeyFingerprint(publicKey!)}',
                      style: pw.TextStyle(
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
    return await pdf.save();
  }
}

class SortingResultsPdfService {
  Future<Uint8List> generateClassDistributionPdf({
    required SortingSurvey survey,
    required Map<String, List<String>> currentResults,
    required Map<String, bool> selectedClasses,
    required Map<String, bool> selectedParameters,
    required bool includeGender,
    required bool includeSummaryStatistics,
    required bool showClassStatistics,
    required PageSize pageSize,
    required List<AppUser> allUsers,
  }) async {
    final pdf = pw.Document();
    final pageFormat = _getPageFormat(pageSize);

    // Add title page with summary statistics ONLY if requested
    if (includeSummaryStatistics) {
      pdf.addPage(
        pw.Page(
          pageFormat: pageFormat,
          margin: const pw.EdgeInsets.all(40),
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(survey.title),
              pw.SizedBox(height: 20),

              // Title and description
              pw.Center(
                child: pw.Text(
                  'Class Distribution Results',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  survey.title,
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 5),
              if (survey.description.isNotEmpty)
                pw.Center(
                  child: pw.Text(
                    survey.description,
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontStyle: pw.FontStyle.italic,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              pw.SizedBox(height: 20),

              // Summary statistics section
              _buildSummaryStatistics(survey, currentResults, allUsers),
            ],
          ),
        ),
      );
    }

    // Get selected classes
    final selectedClassNames = currentResults.keys
        .where((className) => selectedClasses[className] == true)
        .toList();

    // Create pages for each class
    for (final className in selectedClassNames) {
      final studentIds = currentResults[className]!;

      // Only add class statistics page if requested
      if (showClassStatistics) {
        pdf.addPage(
          pw.Page(
            pageFormat: pageFormat,
            margin: const pw.EdgeInsets.all(40),
            build: (context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildHeader(survey.title),
                pw.SizedBox(height: 10),

                // Class header
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 5),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue50,
                    border: pw.Border.all(color: PdfColors.blue200),
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(4)),
                  ),
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 10),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          className,
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          '${studentIds.length} students',
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(height: 10),

                // Class statistics
                _buildClassStatistics(_calculateClassStats(studentIds, survey),
                    survey, includeGender),
              ],
            ),
          ),
        );
      }

      // Calculate optimal number of students per page based on page size and number of columns
      final int columnCount = 1 + // Name column
          (includeGender && survey.askBiologicalSex ? 1 : 0) +
          selectedParameters.values.where((selected) => selected).length;

      // Adjust students per page based on page size and column count
      int studentsPerPage;
      if (columnCount <= 2) {
        studentsPerPage = pageSize == PageSize.a3
            ? 40
            : 30; // More rows possible with fewer columns
      } else if (columnCount <= 4) {
        studentsPerPage = pageSize == PageSize.a3 ? 35 : 25;
      } else {
        studentsPerPage = pageSize == PageSize.a3
            ? 30
            : 20; // Fewer rows possible with many columns
      }

      // Split student list into chunks for the table
      for (int i = 0; i < studentIds.length; i += studentsPerPage) {
        final endIndex = (i + studentsPerPage < studentIds.length)
            ? i + studentsPerPage
            : studentIds.length;

        final pageStudents = studentIds.sublist(i, endIndex);

        pdf.addPage(
          pw.Page(
            pageFormat: pageFormat,
            // Reduce margins to maximize table space
            margin: const pw.EdgeInsets.all(30),
            build: (context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Compact header for student tables
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      '$className - Students ${i + 1} to $endIndex of ${studentIds.length}',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      survey.title,
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Divider(),
                pw.SizedBox(height: 5),

                // Students table - expanded to fill maximum space
                pw.Expanded(
                  child: _buildStudentsTable(
                    studentIds: pageStudents,
                    allUsers: allUsers,
                    survey: survey,
                    includeGender: includeGender,
                    selectedParameters: selectedParameters,
                    currentResults: currentResults,
                  ),
                ),

                // Footer
                pw.SizedBox(height: 5),
                pw.Divider(),
                _buildFooter(context.pageNumber, context.pagesCount),
              ],
            ),
          ),
        );
      }
    }

    return pdf.save();
  }

  pw.Widget _buildHeader(String surveyTitle) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border(
            bottom: pw.BorderSide(width: 1, color: PdfColors.grey300)),
      ),
      margin: const pw.EdgeInsets.only(bottom: 10),
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'edConnect',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
          ),
          pw.Text(
            DateTime.now().toString().split(' ')[0],
            style: const pw.TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter(int pageNumber, int pageCount) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 10),
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: pw.BoxDecoration(
        border:
            pw.Border(top: pw.BorderSide(width: 1, color: PdfColors.grey300)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Generated with edConnect Sorting Module',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            'Page $pageNumber of $pageCount',
            style: const pw.TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSummaryStatistics(
    SortingSurvey survey,
    Map<String, List<String>> currentResults,
    List<AppUser> allUsers,
  ) {
    // Calculate overall statistics
    final totalClasses = currentResults.length;
    final totalStudents =
        currentResults.values.fold(0, (sum, students) => sum + students.length);
    final averagePerClass = totalClasses > 0
        ? (totalStudents / totalClasses).toStringAsFixed(1)
        : '0';

    // Calculate preference satisfaction statistics
    final satisfactionStats =
        _calculatePreferenceSatisfaction(survey, currentResults);
    final satisfiedPrefs = satisfactionStats['satisfiedPreferences'] as int;
    final totalPrefs = satisfactionStats['totalPreferences'] as int;
    final studentsWithSatisfiedPrefs =
        satisfactionStats['studentsWithSatisfiedPrefs'] as int;
    final studentsWithPreferences =
        satisfactionStats['studentsWithPreferences'] as int;

    // Calculate satisfaction rates
    final satisfactionRate = totalPrefs > 0
        ? (satisfiedPrefs / totalPrefs * 100).toStringAsFixed(1) + '%'
        : '0%';
    final studentSatisfactionRate = studentsWithPreferences > 0
        ? (studentsWithSatisfiedPrefs / studentsWithPreferences * 100)
                .toStringAsFixed(1) +
            '%'
        : '0%';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Summary Statistics',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: const pw.FlexColumnWidth(1),
            1: const pw.FlexColumnWidth(1),
          },
          children: [
            // Class distribution
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text(
                    'Class Distribution',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text(''),
                ),
              ],
            ),
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('Total Classes'),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text(totalClasses.toString()),
                ),
              ],
            ),
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('Total Students'),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text(totalStudents.toString()),
                ),
              ],
            ),
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('Average Students per Class'),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text(averagePerClass),
                ),
              ],
            ),

            // Preference satisfaction
            if (survey.maxPreferences != null) ...[
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(
                      'Preference Satisfaction',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(''),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text('Preferences Satisfied'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(
                        '$satisfiedPrefs / $totalPrefs ($satisfactionRate)'),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(
                        'Students with at least one preference satisfied'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(
                        '$studentsWithSatisfiedPrefs / $studentsWithPreferences ($studentSatisfactionRate)'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ],
    );
  }

  pw.Widget _buildClassStatistics(
    Map<String, dynamic> stats,
    SortingSurvey survey,
    bool includeGender,
  ) {
    final columns = <pw.TableRow>[];

    // Add header row
    columns.add(
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey200),
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(5),
            child: pw.Text(
              'Parameter',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(5),
            child: pw.Text(
              'Distribution',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    // Add gender distribution if enabled
    if (includeGender && survey.askBiologicalSex) {
      final genderStats = stats['gender'] as Map<String, int>;
      final total = genderStats.values.fold(0, (sum, count) => sum + count);

      if (total > 0) {
        final genderText = StringBuffer();

        // Format male count
        if (genderStats['m'] != null && genderStats['m']! > 0) {
          final percentage =
              (genderStats['m']! / total * 100).toStringAsFixed(1);
          genderText.write('Male: ${genderStats['m']} ($percentage%)');
        }

        // Format female count
        if (genderStats['f'] != null && genderStats['f']! > 0) {
          if (genderText.isNotEmpty) genderText.write(', ');
          final percentage =
              (genderStats['f']! / total * 100).toStringAsFixed(1);
          genderText.write('Female: ${genderStats['f']} ($percentage%)');
        }

        // Format non-binary count
        if (genderStats['nb'] != null && genderStats['nb']! > 0) {
          if (genderText.isNotEmpty) genderText.write(', ');
          final percentage =
              (genderStats['nb']! / total * 100).toStringAsFixed(1);
          genderText.write('Non-Binary: ${genderStats['nb']} ($percentage%)');
        }

        columns.add(
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text('Gender'),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(genderText.toString()),
              ),
            ],
          ),
        );
      }
    }

    // Add binary parameters
    final binaryParams =
        stats['binary_params'] as Map<String, Map<String, int>>;
    for (final entry in binaryParams.entries) {
      final paramName = _formatParamName(entry.key);
      final counts = entry.value;
      final total = counts.values.fold(0, (sum, count) => sum + count);

      if (total > 0) {
        final yesCount = counts['yes'] ?? 0;
        final noCount = counts['no'] ?? 0;
        final yesPercentage = (yesCount / total * 100).toStringAsFixed(1);
        final noPercentage = (noCount / total * 100).toStringAsFixed(1);

        final distributionText =
            'Yes: $yesCount ($yesPercentage%), No: $noCount ($noPercentage%)';

        columns.add(
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(paramName),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(distributionText),
              ),
            ],
          ),
        );
      }
    }

    // Build the table if we have any data rows
    if (columns.length > 1) {
      return pw.Table(
        border: pw.TableBorder.all(color: PdfColors.grey300),
        columnWidths: {
          0: const pw.FlexColumnWidth(1),
          1: const pw.FlexColumnWidth(2),
        },
        children: columns,
      );
    } else {
      return pw.Container(); // Empty container if no statistics
    }
  }

  pw.Widget _buildStudentsTable({
    required List<String> studentIds,
    required List<AppUser> allUsers,
    required SortingSurvey survey,
    required bool includeGender,
    required Map<String, bool> selectedParameters,
    required Map<String, List<String>> currentResults,
  }) {
    // Create a more space-efficient table
    final headerRow = [
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 2),
        color: PdfColors.grey200,
        child: pw.Text(
          'Student Name',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
        ),
      ),
    ];

    // Add gender header if included
    if (includeGender && survey.askBiologicalSex) {
      headerRow.add(
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 2),
          color: PdfColors.grey200,
          child: pw.Text(
            'Gender',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
          ),
        ),
      );
    }

    // Add parameter headers if included
    for (final param in survey.parameters) {
      final paramName = param['name'] as String;
      if (paramName != 'sex' && selectedParameters[paramName] == true) {
        headerRow.add(
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 2),
            color: PdfColors.grey200,
            child: pw.Text(
              _formatParamName(paramName),
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
            ),
          ),
        );
      }
    }

    // Create data rows
    final List<List<pw.Widget>> rows = [headerRow];

    // Add student rows
    for (final studentId in studentIds) {
      final row = <pw.Widget>[];

      // Get student name
      final user = allUsers.firstWhere(
        (u) => u.id == studentId,
        orElse: () {
          // Check if it's a manual entry
          final response = survey.responses[studentId];
          if (response != null && response['_manual_entry'] == true) {
            return AppUser(
              id: studentId,
              firstName: response['_first_name'] ?? 'Unknown',
              lastName: response['_last_name'] ?? 'Student',
              email: '',
              fcmTokens: [],
              groupIds: [],
              permissions: [],
              deviceIds: {},
              accountType: '',
            );
          }
          return AppUser(
            id: studentId,
            firstName: 'Unknown',
            lastName: 'Student',
            email: '',
            fcmTokens: [],
            groupIds: [],
            permissions: [],
            deviceIds: {},
            accountType: '',
          );
        },
      );

      // Add name
      row.add(
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
          child: pw.Text(user.fullName,
              style: const pw.TextStyle(
                  fontSize: 12) // fontWeight: pw.FontWeight.bold,
              ),
        ),
      );

      // Get student response
      final response = survey.responses[studentId];

      // Add gender if included
      if (includeGender && survey.askBiologicalSex) {
        String sexValue = 'Unknown';
        if (response != null && response.containsKey('sex')) {
          sexValue = _formatSex(response['sex'] as String? ?? 'unknown');
        }

        row.add(
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
            child: pw.Text(sexValue, style: const pw.TextStyle(fontSize: 9)),
          ),
        );
      }

      // Add parameters if included
      for (final param in survey.parameters) {
        final paramName = param['name'] as String;
        if (paramName != 'sex' && selectedParameters[paramName] == true) {
          String value = 'Not provided';

          if (response != null && response.containsKey(paramName)) {
            final paramValue = response[paramName];

            if (param['type'] == 'binary') {
              // Format binary value
              if (paramValue.toString().toLowerCase() == 'yes' ||
                  paramValue.toString().toLowerCase() == 'true' ||
                  paramValue.toString() == '1') {
                value = 'Yes';
              } else if (paramValue.toString().toLowerCase() == 'no' ||
                  paramValue.toString().toLowerCase() == 'false' ||
                  paramValue.toString() == '0') {
                value = 'No';
              } else {
                value = paramValue.toString();
              }
            } else {
              // Categorical parameter
              value = _formatParamName(paramValue.toString());
            }
          }

          row.add(
            pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
              child: pw.Text(value, style: const pw.TextStyle(fontSize: 9)
                  // fontWeight: pw.FontWeight.bold,
                  ),
            ),
          );
        }
      }

      rows.add(row);
    }

    // Calculate column widths - more efficient space usage
    final Map<int, pw.TableColumnWidth> columnWidths = {};

    // Name column gets proportionally more space
    columnWidths[0] = const pw.FlexColumnWidth(2.5);

    // Other columns get equal remaining space
    for (int i = 1; i < headerRow.length; i++) {
      columnWidths[i] = const pw.FlexColumnWidth(1);
    }

    // Build the table with optimized column widths
    return pw.Expanded(
      child: pw.Container(
        // Set alignment to top to prevent centering the table vertically
        alignment: pw.Alignment.topCenter,
        child: pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          columnWidths: columnWidths,
          children: rows.map((row) {
            return pw.TableRow(children: row);
          }).toList(),
        ),
      ),
    );
  }

  Map<String, dynamic> _calculateClassStats(
      List<String> studentIds, SortingSurvey survey) {
    // Gender distribution
    Map<String, int> genderCounts = {'m': 0, 'f': 0, 'nb': 0, 'unknown': 0};

    // Binary parameters (yes/no questions)
    Map<String, Map<String, int>> binaryParams = {};

    // Initialize binary parameter counters from survey parameters
    for (var param in survey.parameters) {
      if (param['type'] == 'binary') {
        String paramName = param['name'];
        binaryParams[paramName] = {'yes': 0, 'no': 0};
      }
    }

    // Count responses for each student
    for (String studentId in studentIds) {
      final response = survey.responses[studentId];

      if (response != null) {
        // Count gender
        String sex = response['sex'] as String? ?? 'unknown';
        if (genderCounts.containsKey(sex)) {
          genderCounts[sex] = genderCounts[sex]! + 1;
        } else {
          genderCounts['unknown'] = genderCounts['unknown']! + 1;
        }

        // Count binary parameters
        for (String paramName in binaryParams.keys) {
          String value =
              (response[paramName] ?? 'unknown').toString().toLowerCase();
          if (value == 'yes' || value == 'true' || value == '1') {
            binaryParams[paramName]!['yes'] =
                binaryParams[paramName]!['yes']! + 1;
          } else if (value == 'no' || value == 'false' || value == '0') {
            binaryParams[paramName]!['no'] =
                binaryParams[paramName]!['no']! + 1;
          }
        }
      }
    }

    return {
      'gender': genderCounts,
      'binary_params': binaryParams,
      'total': studentIds.length,
    };
  }

  Map<String, dynamic> _calculatePreferenceSatisfaction(
    SortingSurvey survey,
    Map<String, List<String>> currentResults,
  ) {
    int satisfiedPreferences = 0;
    int totalPreferences = 0;
    Set<String> studentsWithSatisfiedPrefs = {};
    Set<String> studentsWithPreferences = {};

    // Loop through each class and its students
    for (final entry in currentResults.entries) {
      final studentsInClass = Set<String>.from(entry.value);

      // Check each student's preferences
      for (final studentId in entry.value) {
        final response = survey.responses[studentId];
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

  PdfPageFormat _getPageFormat(PageSize pageSize) {
    switch (pageSize) {
      case PageSize.a4:
        return PdfPageFormat.a4;
      case PageSize.usLetter:
        return PdfPageFormat.letter;
      case PageSize.legal:
        return PdfPageFormat.legal;
      case PageSize.a3:
        return PdfPageFormat.a3;
    }
  }

  String _formatParamName(String name) {
    return name
        .split('_')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');
  }

  String _formatSex(String sex) {
    switch (sex) {
      case 'm':
        return 'Male';
      case 'f':
        return 'Female';
      case 'nb':
        return 'Non-Binary';
      default:
        return 'Unknown';
    }
  }
}
