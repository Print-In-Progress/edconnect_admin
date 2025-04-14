import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/core/models/app_theme.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

/// The type of tab variant to use
enum TabVariant {
  /// Default tab style with underline
  underlined,

  /// Filled tab style with background
  filled,

  /// Outline tab style with borders
  outlined,

  /// Subtle tab style with minimal styling
  subtle,
}

/// The size of the tabs
enum TabSize {
  /// Small size for compact layouts
  small,

  /// Medium size for standard layouts
  medium,

  /// Large size for prominent tabs
  large,
}

/// The direction of the tabs layout
enum TabDirection {
  /// Horizontal layout (side by side)
  horizontal,

  /// Vertical layout (stacked)
  vertical,
}

/// Base tab component following shadcn design principles
class BaseTabs extends ConsumerStatefulWidget {
  /// List of tab items to display
  final List<TabItem> tabs;

  /// The initial selected index
  final int initialIndex;

  /// Callback when a tab is selected
  final ValueChanged<int>? onTabSelected;

  /// Visual variant of the tabs
  final TabVariant variant;

  /// Size of the tabs
  final TabSize size;

  /// Direction of the tabs layout
  final TabDirection direction;

  /// Whether to expand tabs to full width (horizontal) or height (vertical)
  final bool expand;

  /// Whether to center the tab labels
  final bool centered;

  /// Gap between tab list and content
  final double contentGap;

  /// Whether content should maintain its state when not visible
  final bool keepAlive;

  /// Custom tab indicator height (for underlined variant)
  final double? indicatorHeight;

  /// Custom tab indicator width (for underlined variant in horizontal layout)
  /// If null, indicator will match the tab width
  final double? indicatorWidth;

  /// Custom tab indicator color
  final Color? indicatorColor;

  /// Controller for programmatically controlling tabs
  final TabController? controller;

  const BaseTabs({
    super.key,
    required this.tabs,
    this.initialIndex = 0,
    this.onTabSelected,
    this.variant = TabVariant.underlined,
    this.size = TabSize.medium,
    this.direction = TabDirection.horizontal,
    this.expand = false,
    this.centered = false,
    this.contentGap = 16.0,
    this.keepAlive = true,
    this.indicatorHeight,
    this.indicatorWidth,
    this.indicatorColor,
    this.controller,
  }) : assert(initialIndex >= 0 && initialIndex < tabs.length,
            'initialIndex must be within range of tabs length');

  @override
  ConsumerState<BaseTabs> createState() => _BaseTabsState();
}

class _BaseTabsState extends ConsumerState<BaseTabs>
    with SingleTickerProviderStateMixin {
  late TabController _controller;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = widget.controller ??
        TabController(
          length: widget.tabs.length,
          vsync: this,
          initialIndex: widget.initialIndex,
        );
    _controller.addListener(_handleTabChange);
  }

  @override
  void didUpdateWidget(BaseTabs oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller == null) {
        _controller.removeListener(_handleTabChange);
        _controller.dispose();
      }

      _controller = widget.controller ??
          TabController(
            length: widget.tabs.length,
            vsync: this,
            initialIndex: _currentIndex,
          );

      _controller.addListener(_handleTabChange);
    }

    if (widget.tabs.length != oldWidget.tabs.length) {
      if (widget.controller == null) {
        _controller.removeListener(_handleTabChange);
        _controller.dispose();
        _controller = TabController(
          length: widget.tabs.length,
          vsync: this,
          initialIndex: math.min(_currentIndex, widget.tabs.length - 1),
        );
        _controller.addListener(_handleTabChange);
      }
    }
  }

  void _handleTabChange() {
    if (_controller.index != _currentIndex) {
      setState(() {
        _currentIndex = _controller.index;
      });
      widget.onTabSelected?.call(_currentIndex);
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.removeListener(_handleTabChange);
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isHorizontal = widget.direction == TabDirection.horizontal;

    return isHorizontal
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: widget.centered
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              _buildTabBar(),
              SizedBox(height: widget.contentGap),
              _buildTabContent(),
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTabBar(),
              SizedBox(width: widget.contentGap),
              Expanded(child: _buildTabContent()),
            ],
          );
  }

  Widget _buildTabBar() {
    return TabsBar(
      controller: _controller,
      tabs: widget.tabs,
      direction: widget.direction,
      variant: widget.variant,
      size: widget.size,
      expand: widget.expand,
      centered: widget.centered,
      indicatorHeight: widget.indicatorHeight,
      indicatorWidth: widget.indicatorWidth,
      indicatorColor: widget.indicatorColor,
    );
  }

  Widget _buildTabContent() {
    return TabsContent(
      controller: _controller,
      tabs: widget.tabs,
      keepAlive: widget.keepAlive,
    );
  }
}

/// The tab bar component that displays the tab triggers
class TabsBar extends ConsumerWidget {
  final TabController controller;
  final List<TabItem> tabs;
  final TabDirection direction;
  final TabVariant variant;
  final TabSize size;
  final bool expand;
  final bool centered;
  final double? indicatorHeight;
  final double? indicatorWidth;
  final Color? indicatorColor;

  const TabsBar({
    super.key,
    required this.controller,
    required this.tabs,
    required this.direction,
    required this.variant,
    required this.size,
    required this.expand,
    required this.centered,
    this.indicatorHeight,
    this.indicatorWidth,
    this.indicatorColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final isDarkMode = theme.isDarkMode;
    final isHorizontal = direction == TabDirection.horizontal;

    // Determine indicator settings
    final effectiveIndicatorHeight =
        indicatorHeight ?? (variant == TabVariant.underlined ? 2.0 : 0.0);

    final effectiveIndicatorColor = indicatorColor ?? theme.primaryColor;

    // Size mappings
    final double tabHeight = switch (size) {
      TabSize.small => 32.0,
      TabSize.medium => 40.0,
      TabSize.large => 48.0,
    };

    final double fontSize = switch (size) {
      TabSize.small => Foundations.typography.xs,
      TabSize.medium => Foundations.typography.sm,
      TabSize.large => Foundations.typography.base,
    };

    final double horizontalPadding = switch (size) {
      TabSize.small => Foundations.spacing.md,
      TabSize.medium => Foundations.spacing.lg,
      TabSize.large => Foundations.spacing.xl,
    };

    final double verticalPadding = switch (size) {
      TabSize.small => Foundations.spacing.xs,
      TabSize.medium => Foundations.spacing.sm,
      TabSize.large => Foundations.spacing.md,
    };

    final BorderRadius borderRadius = switch (variant) {
      TabVariant.filled || TabVariant.outlined => Foundations.borders.md,
      _ => BorderRadius.zero,
    };

    // Tab list wrapper based on direction
    Widget tabList = isHorizontal
        ? Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment:
                centered ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: _buildTabItems(
              theme,
              isDarkMode,
              isHorizontal,
              tabHeight,
              fontSize,
              horizontalPadding,
              verticalPadding,
              borderRadius,
              effectiveIndicatorHeight,
              effectiveIndicatorColor,
            ),
          )
        : Column(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            crossAxisAlignment:
                centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: _buildTabItems(
              theme,
              isDarkMode,
              isHorizontal,
              tabHeight,
              fontSize,
              horizontalPadding,
              verticalPadding,
              borderRadius,
              effectiveIndicatorHeight,
              effectiveIndicatorColor,
            ),
          );

    // Apply border for underlined variant
    if (variant == TabVariant.underlined && isHorizontal) {
      tabList = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          tabList,
          Container(
            height: 1,
            color: isDarkMode
                ? Foundations.darkColors.border
                : Foundations.colors.border,
          ),
        ],
      );
    } else if (variant == TabVariant.underlined && !isHorizontal) {
      tabList = Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          tabList,
          Container(
            width: 1,
            color: isDarkMode
                ? Foundations.darkColors.border
                : Foundations.colors.border,
          ),
        ],
      );
    }

    return tabList;
  }

  List<Widget> _buildTabItems(
    AppTheme theme,
    bool isDarkMode,
    bool isHorizontal,
    double tabHeight,
    double fontSize,
    double horizontalPadding,
    double verticalPadding,
    BorderRadius borderRadius,
    double effectiveIndicatorHeight,
    Color effectiveIndicatorColor,
  ) {
    return List.generate(tabs.length, (index) {
      final tab = tabs[index];
      final isSelected = controller.index == index;

      // Colors based on variant and state
      Color backgroundColor = Colors.transparent;
      Color textColor = isDarkMode
          ? Foundations.darkColors.textSecondary
          : Foundations.colors.textSecondary;
      Color borderColor = Colors.transparent;

      if (isSelected) {
        switch (variant) {
          case TabVariant.filled:
            backgroundColor = effectiveIndicatorColor.withOpacity(0.1);
            textColor = effectiveIndicatorColor;
            break;
          case TabVariant.outlined:
            borderColor = effectiveIndicatorColor;
            textColor = effectiveIndicatorColor;
            break;
          case TabVariant.underlined:
            textColor = effectiveIndicatorColor;
            break;
          case TabVariant.subtle:
            textColor = effectiveIndicatorColor;
            break;
        }
      } else {
        switch (variant) {
          case TabVariant.outlined:
            borderColor = isDarkMode
                ? Foundations.darkColors.border
                : Foundations.colors.border;
            break;
          default:
            break;
        }
      }

      // Tab container
      final tabContainer = AnimatedContainer(
        duration: Foundations.effects.shortAnimation,
        height: isHorizontal ? tabHeight : null,
        width: isHorizontal && expand ? 1.0 / tabs.length : null,
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
          border: variant == TabVariant.outlined
              ? Border.all(color: borderColor)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (tab.icon != null) ...[
              Icon(
                tab.icon,
                size: fontSize + 4,
                color: textColor,
              ),
              SizedBox(width: Foundations.spacing.sm),
            ],
            Flexible(
              child: Text(
                tab.label,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: isSelected
                      ? Foundations.typography.medium
                      : Foundations.typography.regular,
                  color: textColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (tab.badge != null) ...[
              SizedBox(width: Foundations.spacing.sm),
              tab.badge!,
            ],
          ],
        ),
      );

      // Indicator for underlined variant
      Widget tabWithIndicator = tabContainer;

      if (variant == TabVariant.underlined) {
        if (isHorizontal) {
          tabWithIndicator = Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              tabContainer,
              AnimatedContainer(
                duration: Foundations.effects.shortAnimation,
                height: effectiveIndicatorHeight,
                width: indicatorWidth ?? (expand ? null : 24.0),
                decoration: BoxDecoration(
                  color:
                      isSelected ? effectiveIndicatorColor : Colors.transparent,
                  borderRadius: Foundations.borders.full,
                ),
              ),
            ],
          );
        } else {
          tabWithIndicator = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: Foundations.effects.shortAnimation,
                width: effectiveIndicatorHeight,
                height: indicatorWidth ?? (expand ? null : 24.0),
                decoration: BoxDecoration(
                  color:
                      isSelected ? effectiveIndicatorColor : Colors.transparent,
                  borderRadius: Foundations.borders.full,
                ),
              ),
              tabContainer,
            ],
          );
        }
      }

      return Flexible(
        flex: expand ? 1 : 0,
        child: GestureDetector(
          onTap: () {
            controller.animateTo(index);
          },
          behavior: HitTestBehavior.opaque,
          child: tabWithIndicator,
        ),
      );
    });
  }
}

/// The content area for the tabs
class TabsContent extends StatelessWidget {
  final TabController controller;
  final List<TabItem> tabs;
  final bool keepAlive;

  const TabsContent({
    super.key,
    required this.controller,
    required this.tabs,
    required this.keepAlive,
  });

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: controller,
      children: tabs.map((tab) {
        Widget content = tab.content;
        if (keepAlive) {
          content = KeepAliveWrapper(child: content);
        }
        return content;
      }).toList(),
    );
  }
}

/// A wrapper to keep tab content alive when not visible
class KeepAliveWrapper extends StatefulWidget {
  final Widget child;

  const KeepAliveWrapper({
    super.key,
    required this.child,
  });

  @override
  State<KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

/// Represents a single tab item
class TabItem {
  /// Label text for the tab
  final String label;

  /// Optional icon to display before the label
  final IconData? icon;

  /// Optional badge to display (e.g. count indicator)
  final Widget? badge;

  /// The content to display when this tab is selected
  final Widget content;

  const TabItem({
    required this.label,
    required this.content,
    this.icon,
    this.badge,
  });
}

/// A simple badge widget for use in tabs
class TabBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final double? fontSize;

  const TabBadge({
    super.key,
    required this.label,
    this.color,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Foundations.spacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color ?? const Color(0xFFF87171),
        borderRadius: Foundations.borders.full,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize ?? Foundations.typography.xs,
          fontWeight: Foundations.typography.medium,
        ),
      ),
    );
  }
}
