import 'package:flutter/material.dart';
import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/presentation/widgets/common/cards/base_card.dart';

class SurveySkeletonLoader extends StatelessWidget {
  final bool isDarkMode;

  const SurveySkeletonLoader({required this.isDarkMode, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Foundations.spacing.lg),
      child: Column(
        children: [
          _buildTabsSkeleton(),
          SizedBox(height: Foundations.spacing.lg),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildSectionSkeleton(),
                  SizedBox(height: Foundations.spacing.lg),
                  _buildContentSkeleton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabsSkeleton() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDarkMode
                ? Foundations.darkColors.border
                : Foundations.colors.border,
          ),
        ),
      ),
      child: Row(
        children: List.generate(4, (index) {
          return Padding(
            padding: EdgeInsets.only(right: Foundations.spacing.md),
            child: Container(
              width: 120,
              height: 32,
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Foundations.darkColors.surfaceActive
                    : Foundations.colors.surfaceActive,
                borderRadius: Foundations.borders.md,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSectionSkeleton() {
    return Container(
      height: 24,
      width: 200,
      decoration: BoxDecoration(
        color: isDarkMode
            ? Foundations.darkColors.surfaceActive
            : Foundations.colors.surfaceActive,
        borderRadius: Foundations.borders.md,
      ),
    );
  }

  Widget _buildContentSkeleton() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: _buildSkeletonCard(itemCount: 6),
        ),
        SizedBox(width: Foundations.spacing.lg),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildSkeletonCard(itemCount: 2),
              SizedBox(height: Foundations.spacing.lg),
              _buildSkeletonCard(itemCount: 4),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonCard({required int itemCount}) {
    return BaseCard(
      variant: CardVariant.outlined,
      child: Padding(
        padding: EdgeInsets.all(Foundations.spacing.lg),
        child: Column(
          children: List.generate(itemCount, (index) {
            return Column(
              children: [
                Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Foundations.darkColors.surfaceActive
                        : Foundations.colors.surfaceActive,
                    borderRadius: Foundations.borders.md,
                  ),
                ),
                if (index < itemCount - 1)
                  Divider(
                    height: Foundations.spacing.xl,
                    color: isDarkMode
                        ? Foundations.darkColors.border
                        : Foundations.colors.border,
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
