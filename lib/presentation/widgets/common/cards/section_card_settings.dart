import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/presentation/widgets/common/cards/base_card.dart';
import 'package:flutter/material.dart';

Widget buildSectionCard(String title, bool isDarkMode,
    {required List<Widget> children}) {
  return BaseCard(
    variant: CardVariant.elevated,
    margin: EdgeInsets.zero,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(Foundations.spacing.lg),
          child: Text(
            title,
            style: TextStyle(
              fontSize: Foundations.typography.lg,
              fontWeight: Foundations.typography.semibold,
              color: isDarkMode
                  ? Foundations.darkColors.textPrimary
                  : Foundations.colors.textPrimary,
            ),
          ),
        ),
        Divider(
          color: isDarkMode
              ? Foundations.darkColors.border
              : Foundations.colors.border,
          height: 1,
        ),
        ...children,
      ],
    ),
  );
}
