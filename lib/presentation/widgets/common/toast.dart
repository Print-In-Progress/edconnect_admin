import 'dart:collection';
import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/l10n/app_localizations.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Variants for toast notifications
enum ToastVariant { success, error, warning, info, default_ }

/// Position where the toast will appear
enum ToastPosition { topRight, topCenter, bottomRight, bottomCenter }

/// A  toast notification system
class Toaster {
  // Singleton instance
  static final Toaster _instance = Toaster._internal();
  factory Toaster() => _instance;
  Toaster._internal();

  // Queue to manage multiple toasts
  final Queue<_ToastEntry> _toastQueue = Queue<_ToastEntry>();

  // Track active toasts
  final List<OverlayEntry> _activeToasts = [];

  // Maximum number of visible toasts at once
  final int _maxVisibleToasts = 5;

  /// Show a toast notification
  static Future<void> show({
    required BuildContext context,
    required String message,
    String? description,
    ToastVariant variant = ToastVariant.default_,
    VoidCallback? onAction,
    String? actionLabel,
    Duration duration = const Duration(seconds: 5),
    ToastPosition position = ToastPosition.bottomRight,
  }) async {
    return _instance._show(
      context: context,
      message: message,
      description: description,
      variant: variant,
      onAction: onAction,
      actionLabel: actionLabel,
      duration: duration,
      position: position,
    );
  }

  /// Show a success toast
  static Future<void> success(
    BuildContext context,
    String message, {
    String? description,
    ToastPosition position = ToastPosition.bottomRight,
  }) {
    return show(
      context: context,
      message: message,
      description: description,
      variant: ToastVariant.success,
      position: position,
    );
  }

  /// Show an error toast
  static Future<void> error(
    BuildContext context,
    String message, {
    String? description,
    ToastPosition position = ToastPosition.bottomRight,
  }) {
    return show(
      context: context,
      message: message,
      description: description,
      variant: ToastVariant.error,
      position: position,
    );
  }

  /// Show a warning toast
  static Future<void> warning(
    BuildContext context,
    String message, {
    String? description,
    ToastPosition position = ToastPosition.bottomRight,
  }) {
    return show(
      context: context,
      message: message,
      description: description,
      variant: ToastVariant.warning,
      position: position,
    );
  }

  /// Show an info toast
  static Future<void> info(
    BuildContext context,
    String message, {
    String? description,
    ToastPosition position = ToastPosition.bottomRight,
  }) {
    return show(
      context: context,
      message: message,
      description: description,
      variant: ToastVariant.info,
      position: position,
    );
  }

  /// Dismiss all toasts
  static void dismissAll() {
    _instance._dismissAll();
  }

  Future<void> _show({
    required BuildContext context,
    required String message,
    String? description,
    required ToastVariant variant,
    VoidCallback? onAction,
    String? actionLabel,
    required Duration duration,
    required ToastPosition position,
  }) async {
    final OverlayState overlayState = Overlay.of(context);

    final theme = ProviderScope.containerOf(context).read(appThemeProvider);
    final isDarkMode = theme.isDarkMode;
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Calculate dimensions
    final screenWidth = mediaQuery.size.width;
    final isSmallScreen = screenWidth < 600;

    // Calculate toast width
    final toastWidth = isSmallScreen ? screenWidth * 0.9 : 360.0;

    const double padding = 16.0;
    const double stackOffset = 8.0;
    final int toastIndex = _activeToasts.length;

    // Now declare the entry and update the onDismiss callback
    late final OverlayEntry entry;

    // Update the toast with the correct onDismiss callback
    final toToast = _ToastWidget(
      message: message,
      description: description,
      variant: variant,
      isDarkMode: isDarkMode,
      onAction: onAction,
      actionLabel: actionLabel ?? l10n.globalDismiss,
      onDismiss: () => _removeToast(entry),
    );

    // Create the entry with proper positioning based on position type
    entry = OverlayEntry(
      builder: (context) {
        if (position == ToastPosition.topRight ||
            position == ToastPosition.topCenter) {
          // Top positioning
          final leftPosition = position == ToastPosition.topCenter
              ? (screenWidth - toastWidth) / 2
              : screenWidth - toastWidth - padding;

          return Positioned(
            left: leftPosition,
            top: padding + (toastIndex * stackOffset),
            width: toastWidth,
            child: Material(
              color: Colors.transparent,
              child: SafeArea(
                child: _AnimatedToast(
                  toast: toToast,
                  onDismiss: () => _removeToast(entry),
                  slideFromTop: true,
                ),
              ),
            ),
          );
        } else {
          // Bottom positioning
          final leftPosition = position == ToastPosition.bottomCenter
              ? (screenWidth - toastWidth) / 2
              : screenWidth - toastWidth - padding;

          return Positioned(
            left: leftPosition,
            bottom:
                padding + (toastIndex * stackOffset), // Position from bottom
            width: toastWidth,
            child: Material(
              color: Colors.transparent,
              child: SafeArea(
                bottom: true, // Ensure we respect bottom safe area
                child: _AnimatedToast(
                  toast: toToast,
                  onDismiss: () => _removeToast(entry),
                  slideFromTop: false, // Slide from bottom
                ),
              ),
            ),
          );
        }
      },
    );

    // Add to queue or show directly
    final toastEntry = _ToastEntry(entry, duration, overlayState);
    _toastQueue.add(toastEntry);
    _processQueue();

    // Auto-dismiss after duration
    Future.delayed(duration, () {
      _removeToast(entry);
    });
  }

  void _processQueue() {
    // Show toasts from queue if we have room
    while (_activeToasts.length < _maxVisibleToasts && _toastQueue.isNotEmpty) {
      final entry = _toastQueue.removeFirst();
      _activeToasts.add(entry.overlayEntry);

      // Get the overlay state that was captured when show() was called
      // We'll store this when creating the _ToastEntry
      if (entry.overlayState != null) {
        entry.overlayState!.insert(entry.overlayEntry);
      }
    }
  }

  void _removeToast(OverlayEntry entry) {
    if (!_activeToasts.contains(entry)) return;

    entry.remove();
    _activeToasts.remove(entry);

    // Check queue for more toasts
    _processQueue();
  }

  void _dismissAll() {
    // Remove all active toasts
    for (final entry in _activeToasts) {
      entry.remove();
    }
    _activeToasts.clear();
    _toastQueue.clear();
  }
}

class _ToastEntry {
  final OverlayEntry overlayEntry;
  final Duration duration;
  final OverlayState? overlayState;

  _ToastEntry(this.overlayEntry, this.duration, this.overlayState);
}

class _AnimatedToast extends StatefulWidget {
  final Widget toast;
  final VoidCallback onDismiss;
  final bool slideFromTop;

  const _AnimatedToast({
    required this.toast,
    required this.onDismiss,
    this.slideFromTop = true,
  });

  @override
  _AnimatedToastState createState() => _AnimatedToastState();
}

class _AnimatedToastState extends State<_AnimatedToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _opacityAnimation;

  // Track the horizontal drag for swipe-to-dismiss
  Offset _dragStartPosition = Offset.zero;
  double _dragHorizontal = 0.0;
  bool _isDragging = false;

  // Threshold for dismissal (as a percentage of width)
  final double _dismissThreshold = 0.05;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Foundations.effects.mediumAnimation,
      vsync: this,
    );

    final beginOffset = widget.slideFromTop
        ? const Offset(0.0, -0.2) // Slide down from above
        : const Offset(0.0, 0.2); // Slide up from below

    _offsetAnimation = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss(DismissDirection direction) {
    // Determine the final offset based on direction
    final endOffset = direction == DismissDirection.endToStart
        ? const Offset(-1.0, 0.0) // Slide left
        : const Offset(1.0, 0.0); // Slide right

    _controller.duration = const Duration(milliseconds: 200);
    _controller.reset();

    // Create new animations for dismiss
    _offsetAnimation = Tween<Offset>(
      begin: Offset(_dragHorizontal / MediaQuery.of(context).size.width, 0.0),
      end: endOffset,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward().then((_) {
      widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Handle dragging to track horizontal movement
      onHorizontalDragStart: (details) {
        _dragStartPosition = details.globalPosition;
        _isDragging = true;
      },

      onHorizontalDragUpdate: (details) {
        if (!_isDragging) return;

        final delta = details.globalPosition.dx - _dragStartPosition.dx;
        setState(() {
          _dragHorizontal = delta;
        });
      },

      onHorizontalDragEnd: (details) {
        final screenWidth = MediaQuery.of(context).size.width;

        // Determine if we should dismiss based on velocity or distance
        final shouldDismiss = details.primaryVelocity!.abs() > 500 ||
            _dragHorizontal.abs() > screenWidth * _dismissThreshold;

        if (shouldDismiss) {
          final direction = _dragHorizontal > 0
              ? DismissDirection.startToEnd
              : DismissDirection.endToStart;
          _dismiss(direction);
        } else {
          // Snap back to original position
          setState(() {
            _dragHorizontal = 0;
            _isDragging = false;
          });
        }
      },

      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // Apply both the initial animation and the drag offset
          final animationOffset = _offsetAnimation.value;
          final dragOffset =
              Offset(_dragHorizontal / MediaQuery.of(context).size.width, 0);
          final combinedOffset = Offset(
            animationOffset.dx + (_isDragging ? dragOffset.dx : 0),
            animationOffset.dy,
          );

          return FractionalTranslation(
            translation: combinedOffset,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: widget.toast,
            ),
          );
        },
      ),
    );
  }
}

class _ToastWidget extends StatelessWidget {
  final String message;
  final String? description;
  final ToastVariant variant;
  final bool isDarkMode;
  final VoidCallback? onAction;
  final String actionLabel;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    this.description,
    required this.variant,
    required this.isDarkMode,
    this.onAction,
    required this.actionLabel,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: Foundations.spacing.sm,
        horizontal: Foundations.spacing.md,
      ),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Foundations.darkColors.surface
            : Foundations.colors.surface,
        borderRadius: Foundations.borders.md,
        border: Border.all(
          color: _getBorderColor(),
          width: Foundations.borders.normal,
        ),
        boxShadow: isDarkMode ? null : Foundations.effects.shadowMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(Foundations.spacing.md),
            child: Row(
              crossAxisAlignment: description != null
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                // Icon
                Icon(
                  _getIcon(),
                  color: _getIconColor(),
                  size: 18,
                ),
                SizedBox(width: Foundations.spacing.sm),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: Foundations.typography.sm,
                          fontWeight: Foundations.typography.medium,
                          color: isDarkMode
                              ? Foundations.darkColors.textPrimary
                              : Foundations.colors.textPrimary,
                        ),
                      ),
                      if (description != null) ...[
                        SizedBox(height: Foundations.spacing.xs),
                        Text(
                          description!,
                          style: TextStyle(
                            fontSize: Foundations.typography.xs,
                            color: isDarkMode
                                ? Foundations.darkColors.textSecondary
                                : Foundations.colors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                BaseIconButton(
                  icon: Icons.close,
                  onPressed: onDismiss,
                  size: IconButtonSize.small,
                  color: isDarkMode
                      ? Foundations.darkColors.textMuted
                      : Foundations.colors.textMuted,
                ),
              ],
            ),
          ),

          // Action button (if provided)
          if (onAction != null)
            InkWell(
              onTap: onAction,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: isDarkMode
                          ? Foundations.darkColors.border
                          : Foundations.colors.border,
                      width: Foundations.borders.normal,
                    ),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: Foundations.spacing.sm,
                  horizontal: Foundations.spacing.md,
                ),
                alignment: Alignment.center,
                child: Text(
                  actionLabel,
                  style: TextStyle(
                    fontSize: Foundations.typography.sm,
                    fontWeight: Foundations.typography.medium,
                    color: _getActionColor(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getIcon() {
    return switch (variant) {
      ToastVariant.success => Icons.check_circle,
      ToastVariant.error => Icons.error,
      ToastVariant.warning => Icons.warning_rounded,
      ToastVariant.info => Icons.info,
      ToastVariant.default_ => Icons.notifications,
    };
  }

  Color _getBorderColor() {
    return isDarkMode
        ? Foundations.darkColors.border
        : Foundations.colors.border;
  }

  Color _getIconColor() {
    return switch (variant) {
      ToastVariant.success => Foundations.colors.success,
      ToastVariant.error => Foundations.colors.error,
      ToastVariant.warning => Foundations.colors.warning,
      ToastVariant.info => Foundations.colors.info,
      ToastVariant.default_ => isDarkMode
          ? Foundations.darkColors.textMuted
          : Foundations.colors.textMuted,
    };
  }

  Color _getActionColor() {
    return switch (variant) {
      ToastVariant.success => Foundations.colors.success,
      ToastVariant.error => Foundations.colors.error,
      ToastVariant.warning => Foundations.colors.warning,
      ToastVariant.info => Foundations.colors.info,
      ToastVariant.default_ => isDarkMode
          ? Foundations.darkColors.textPrimary
          : Foundations.colors.textPrimary,
    };
  }
}
