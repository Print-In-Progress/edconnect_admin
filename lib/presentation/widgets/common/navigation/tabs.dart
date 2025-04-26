import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';

class Tabs extends ConsumerStatefulWidget {
  final List<TabItem> tabs;
  final int defaultValue;
  final ValueChanged<int>? onChanged;

  const Tabs({
    super.key,
    required this.tabs,
    this.defaultValue = 0,
    this.onChanged,
  });

  @override
  ConsumerState<Tabs> createState() => _TabsState();
}

class _TabsState extends ConsumerState<Tabs>
    with SingleTickerProviderStateMixin {
  late int _selectedIndex;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.defaultValue;
    _animationController = AnimationController(
      duration: Foundations.effects.shortAnimation,
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTabChange(int index) {
    if (index == _selectedIndex) return;

    // Reset animation and play it forward for smooth transition
    _animationController.reset();
    _animationController.forward();

    setState(() {
      _selectedIndex = index;
    });
    widget.onChanged?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TabsList(
          tabs: widget.tabs,
          selectedIndex: _selectedIndex,
          onChanged: _handleTabChange,
          animationController: _animationController,
        ),
        SizedBox(height: Foundations.spacing.lg),
        Expanded(
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeInOut,
            ),
            child: TabsContent(
              tabs: widget.tabs,
              selectedIndex: _selectedIndex,
            ),
          ),
        ),
      ],
    );
  }
}

class TabsList extends ConsumerWidget {
  final List<TabItem> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final AnimationController animationController;

  const TabsList({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final isDarkMode = theme.isDarkMode;

    return Container(
      padding: EdgeInsets.all(Foundations.spacing.xs),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Foundations.darkColors.surfaceActive
            : Foundations.colors.surfaceActive,
        borderRadius: Foundations.borders.md,
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.05)
                : Colors.black.withOpacity(0.03),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < tabs.length; i++)
            _TabTrigger(
              label: tabs[i].label,
              icon: tabs[i].icon,
              isSelected: i == selectedIndex,
              onTap: () => onChanged(i),
              animationController: animationController,
            ),
        ],
      ),
    );
  }
}

class _TabTrigger extends ConsumerWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;
  final AnimationController animationController;

  const _TabTrigger({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final isDarkMode = theme.isDarkMode;

    // Use AnimatedBuilder to rebuild only this widget when animation changes
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        final backgroundColor = isSelected
            ? isDarkMode
                ? Foundations.darkColors.surface
                : Foundations.colors.surface
            : Colors.transparent;

        final textColor = isSelected
            ? isDarkMode
                ? Foundations.darkColors.textPrimary
                : Foundations.colors.textPrimary
            : isDarkMode
                ? Foundations.darkColors.textSecondary
                : Foundations.colors.textSecondary;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: Foundations.borders.sm,
              onTap: onTap,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: isDarkMode
                  ? Foundations.darkColors.backgroundSubtle.withOpacity(0.1)
                  : Foundations.colors.backgroundSubtle.withOpacity(0.1),
              child: Ink(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: Foundations.borders.sm,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: isDarkMode
                                ? Colors.black.withOpacity(0.1)
                                : Colors.black.withOpacity(0.05),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: Foundations.spacing.md,
                  vertical: Foundations.spacing.sm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        size: 16,
                        color: textColor,
                      ),
                      SizedBox(width: Foundations.spacing.sm),
                    ],
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: Foundations.typography.sm,
                        fontWeight: Foundations.typography.medium,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class TabsContent extends StatelessWidget {
  final List<TabItem> tabs;
  final int selectedIndex;

  const TabsContent({
    super.key,
    required this.tabs,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: selectedIndex,
      children: tabs.map((tab) => tab.content).toList(),
    );
  }
}

class TabItem {
  final String label;
  final IconData? icon;
  final Widget content;

  const TabItem({
    required this.label,
    required this.content,
    this.icon,
  });
}
