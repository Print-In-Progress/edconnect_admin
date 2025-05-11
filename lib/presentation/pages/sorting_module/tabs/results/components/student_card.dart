import 'package:edconnect_admin/core/design_system/color_generator.dart';
import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/core/models/app_user.dart';
import 'package:edconnect_admin/domain/entities/sorting_survey.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/utils/parameter_formatter.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/cards/base_card.dart';
import 'package:edconnect_admin/presentation/widgets/common/chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SortingSurveyStudentCard extends ConsumerStatefulWidget {
  final String studentId;
  final List<AppUser> allUsers;
  final SortingSurvey survey;
  final Map<String, dynamic> currentResults;
  const SortingSurveyStudentCard({
    super.key,
    required this.studentId,
    required this.allUsers,
    required this.survey,
    required this.currentResults,
  });

  @override
  ConsumerState<SortingSurveyStudentCard> createState() =>
      _SortingSurveyStudentCardState();
}

class _SortingSurveyStudentCardState
    extends ConsumerState<SortingSurveyStudentCard> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(appThemeProvider).isDarkMode;
    final user = widget.allUsers.firstWhere(
      (u) => u.id == widget.studentId,
      orElse: () {
        // Check if it's a manual entry
        final response = widget.survey.responses[widget.studentId];
        if (response != null && response['_manual_entry'] == true) {
          return AppUser(
            id: widget.studentId,
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
          id: widget.studentId,
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

    // Get biological sex if available
    String? sex;
    final response = widget.survey.responses[widget.studentId];
    if (widget.survey.askBiologicalSex && response != null) {
      sex = response['sex'] as String?;
    }
    final Map<String, dynamic> responseWithId = {
      ...response,
      '_student_id': widget.studentId,
    };
    return BaseCard(
      variant: CardVariant.outlined,
      padding: EdgeInsets.all(Foundations.spacing.sm),
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          // Student basic info row
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: ColorGenerator.getColor(
                    user.fullName,
                    user.id,
                    isDarkMode: isDarkMode,
                  ),
                  borderRadius: Foundations.borders.full,
                ),
                child: Center(
                  child: Text(
                    user.initials,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: Foundations.typography.semibold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: Foundations.spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: TextStyle(
                        fontSize: Foundations.typography.base,
                        fontWeight: Foundations.typography.medium,
                        color: isDarkMode
                            ? Foundations.darkColors.textPrimary
                            : Foundations.colors.textPrimary,
                      ),
                    ),
                    if (sex != null) ...[
                      SizedBox(height: Foundations.spacing.xs),
                      BaseChip(
                        label: ParameterFormatter.formatSexForDisplay(sex),
                        variant: ChipVariant.default_,
                        size: ChipSize.small,
                        backgroundColor: ColorGenerator.getColor(
                          'sex',
                          sex,
                          isDarkMode: isDarkMode,
                        ).withOpacity(0.1),
                        textColor: ColorGenerator.getColor(
                          'sex',
                          sex,
                          isDarkMode: isDarkMode,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // Show response details in expansion tile if response exists
          if (response != null) ...[
            ExpansionTile(
              title: Text(
                'Response Details',
                style: TextStyle(
                  fontSize: Foundations.typography.xs,
                  color: isDarkMode
                      ? Foundations.darkColors.textSecondary
                      : Foundations.colors.textSecondary,
                ),
              ),
              dense: true,
              childrenPadding: EdgeInsets.only(
                left: Foundations.spacing.sm,
                right: Foundations.spacing.sm,
                bottom: Foundations.spacing.sm,
              ),
              iconColor: isDarkMode
                  ? Foundations.darkColors.textMuted
                  : Foundations.colors.textMuted,
              shape: const Border(),
              collapsedShape: const Border(),
              children: [
                // Preferences section
                _buildPreferencesSection(
                    responseWithId, widget.allUsers, isDarkMode),

                // Parameters section based on survey parameters
                ...widget.survey.parameters.map((param) {
                  return _buildParameterInfo(param, response, isDarkMode);
                }),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreferencesSection(
      Map<String, dynamic> response, List<AppUser> allUsers, bool isDarkMode) {
    // We need to get the actual student ID first
    final studentId = response['_student_id'] ?? ''; // This might be missing

    final prefs = response['prefs'] as List?;
    if (prefs == null || prefs.isEmpty) {
      return _buildInfoRow(
        'Preferences',
        'No preferences selected',
        isDarkMode,
        icon: Icons.favorite_border,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Preferences', Icons.favorite_border, isDarkMode),
        SizedBox(height: Foundations.spacing.xs),
        ...prefs.map((prefId) {
          if (prefId is String) {
            // Find preferred student name
            final prefUser = allUsers.firstWhere(
              (u) => u.id == prefId,
              orElse: () {
                // Check if it's a manual entry
                final prefResponse = widget.survey.responses[prefId];
                if (prefResponse != null &&
                    prefResponse['_manual_entry'] == true) {
                  return AppUser(
                    id: prefId,
                    firstName: prefResponse['_first_name'] ?? 'Unknown',
                    lastName: prefResponse['_last_name'] ?? 'Student',
                    email: '',
                    fcmTokens: [],
                    groupIds: [],
                    permissions: [],
                    deviceIds: {},
                    accountType: '',
                  );
                }
                return AppUser(
                  id: prefId,
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

            // Get the current student's class
            String? currentStudentClass;
            for (final entry in widget.currentResults.entries) {
              if (entry.value.contains(studentId)) {
                currentStudentClass = entry.key;
                break;
              }
            }

            // Check if preferred student is in the same class
            bool isSatisfied = false;
            if (currentStudentClass != null) {
              isSatisfied =
                  widget.currentResults[currentStudentClass]!.contains(prefId);
            }

            // Get a color based on the preferred student's name/ID
            final nameColor = ColorGenerator.getColor(
              prefUser.fullName,
              prefUser.id,
              isDarkMode: isDarkMode,
            );

            return Padding(
              padding: EdgeInsets.only(left: Foundations.spacing.md),
              child: Row(
                children: [
                  Icon(
                    isSatisfied
                        ? Icons.check // Use simple checkmark when satisfied
                        : Icons.highlight_off,
                    size: 14,
                    color: isSatisfied
                        ? Foundations.colors.success
                        : Foundations.colors.error.withOpacity(0.7),
                  ),
                  SizedBox(width: Foundations.spacing.xs),
                  Text(
                    prefUser.fullName,
                    style: TextStyle(
                        fontSize: Foundations.typography.xs,
                        fontWeight: isSatisfied
                            ? Foundations.typography.medium
                            : Foundations.typography.regular,
                        color:
                            nameColor // Use color generated from student name

                        ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

// Build individual parameter info row based on parameter type
  Widget _buildParameterInfo(Map<String, dynamic> param,
      Map<String, dynamic> response, bool isDarkMode) {
    final paramName = param['name'] as String;
    final paramType = param['type'] as String;
    final displayName =
        ParameterFormatter.formatParameterNameForDisplay(paramName);

    // Skip sex parameter as it's already shown in the header
    if (paramName == 'sex') return const SizedBox.shrink();

    String valueText = 'Not provided';
    IconData paramIcon;

    if (response.containsKey(paramName)) {
      final value = response[paramName];

      if (paramType == 'binary') {
        paramIcon = Icons.check_box_outline_blank;

        // Format binary value
        if (value.toString().toLowerCase() == 'yes' ||
            value.toString().toLowerCase() == 'true' ||
            value.toString() == '1') {
          valueText = 'Yes';
        } else if (value.toString().toLowerCase() == 'no' ||
            value.toString().toLowerCase() == 'false' ||
            value.toString() == '0') {
          valueText = 'No';
        } else {
          valueText = value.toString();
        }
      } else {
        // Categorical parameter
        paramIcon = Icons.label_outline;
        valueText =
            ParameterFormatter.formatParameterNameForDisplay(value.toString());
      }
    } else {
      paramIcon = paramType == 'binary'
          ? Icons.check_box_outline_blank
          : Icons.label_outline;
    }

    return _buildInfoRow(displayName, valueText, isDarkMode, icon: paramIcon);
  }

  Widget _buildSectionTitle(String title, IconData icon, bool isDarkMode) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: isDarkMode
              ? Foundations.darkColors.textMuted
              : Foundations.colors.textMuted,
        ),
        SizedBox(width: Foundations.spacing.xs),
        Text(
          title,
          style: TextStyle(
            fontSize: Foundations.typography.xs,
            fontWeight: Foundations.typography.medium,
            color: isDarkMode
                ? Foundations.darkColors.textMuted
                : Foundations.colors.textMuted,
          ),
        ),
      ],
    );
  }

// Build a generic parameter row
  Widget _buildInfoRow(String label, String value, bool isDarkMode,
      {IconData? icon}) {
    return Padding(
      padding: EdgeInsets.only(top: Foundations.spacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: isDarkMode
                  ? Foundations.darkColors.textMuted
                  : Foundations.colors.textMuted,
            ),
            SizedBox(width: Foundations.spacing.xs),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: Foundations.typography.xs,
                    fontWeight: Foundations.typography.medium,
                    color: isDarkMode
                        ? Foundations.darkColors.textMuted
                        : Foundations.colors.textMuted,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: Foundations.typography.xs,
                    color: isDarkMode
                        ? Foundations.darkColors.textSecondary
                        : Foundations.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
