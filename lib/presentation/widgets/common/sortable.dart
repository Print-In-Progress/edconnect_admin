import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edconnect_admin/core/design_system/foundations.dart';

/// A model class that represents a draggable item
class SortableItem<T> {
  /// Unique identifier for the item
  final String id;

  /// The data associated with this item
  final T data;

  const SortableItem({
    required this.id,
    required this.data,
  });
}

/// A model class that represents a column in the sortable widget
class SortableColumn<T> {
  /// Unique identifier for the column
  final String id;

  /// Display name for the column
  final String title;

  /// Description text for the column
  final String? description;

  /// Optional custom header widget (takes precedence over title/description)
  final Widget? headerWidget;

  /// List of items in this column
  final List<SortableItem<T>> items;

  const SortableColumn({
    required this.id,
    required this.title,
    this.description,
    this.headerWidget,
    required this.items,
  });

  /// Creates a new column with updated items
  SortableColumn<T> copyWith({
    String? id,
    String? title,
    String? description,
    Widget? headerWidget,
    List<SortableItem<T>>? items,
  }) {
    return SortableColumn(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      headerWidget: headerWidget ?? this.headerWidget,
      items: items ?? this.items,
    );
  }
}

/// Callback for when items are reordered within or between columns
typedef OnItemsReordered<T> = void Function(
  List<SortableColumn<T>> updatedColumns,
  String sourceColumnId,
  String targetColumnId,
  String itemId,
);

/// A widget that displays multiple columns with draggable items
class Sortable<T> extends ConsumerStatefulWidget {
  /// List of columns to display
  final List<SortableColumn<T>> columns;

  /// Function to build the content of each item
  final Widget Function(BuildContext context, SortableItem<T> item) itemBuilder;

  /// Called when items are reordered
  final OnItemsReordered<T>? onItemsReordered;

  /// Height of each column header
  final double? columnHeaderHeight;

  /// Width of each column
  final double columnWidth;

  /// Spacing between columns
  final double columnSpacing;

  /// Whether the columns should scroll horizontally
  final bool horizontalScroll;

  /// Whether empty columns should show a placeholder
  final bool showEmptyPlaceholder;

  /// Spacing between items in a column
  final double itemSpacing;

  /// Custom placeholder widget for empty columns
  final Widget Function(BuildContext context, SortableColumn<T> column)?
      emptyPlaceholderBuilder;

  const Sortable({
    super.key,
    required this.columns,
    required this.itemBuilder,
    this.onItemsReordered,
    this.columnHeaderHeight,
    this.columnWidth = 280.0,
    this.columnSpacing = 16.0,
    this.itemSpacing = 12.0,
    this.horizontalScroll = true,
    this.showEmptyPlaceholder = true,
    this.emptyPlaceholderBuilder,
  });

  @override
  ConsumerState<Sortable<T>> createState() => _SortableState<T>();
}

class _SortableState<T> extends ConsumerState<Sortable<T>> {
  /// Currently dragged item data
  SortableItem<T>? _draggedItem;

  /// Source column ID for the dragged item
  String? _sourceColumnId;

  /// Target column ID for the dragged item
  String? _targetColumnId;

  /// Index of dragged item in its source column
  int? _draggedItemIndex;

  /// Position where the item will be inserted
  int? _insertPosition;

  final Map<String, GlobalKey> _headerKeys = {};

  @override
  void initState() {
    super.initState();
    // Initialize keys for each column
    for (final column in widget.columns) {
      _headerKeys[column.id] = GlobalKey();
    }
  }

  @override
  Widget build(BuildContext context) {
    final columns = widget.columns;

    // Wrap columns in a horizontal scroll if enabled
    Widget content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(columns.length * 2 - 1, (index) {
        if (index.isOdd) {
          // Add spacing between columns
          return SizedBox(width: widget.columnSpacing);
        }

        final columnIndex = index ~/ 2;
        final column = columns[columnIndex];

        return _buildColumn(column);
      }),
    );

    if (widget.horizontalScroll) {
      content = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.all(Foundations.spacing.lg),
        child: IntrinsicHeight(child: content), // Add IntrinsicHeight here
      );
    } else {
      content = Padding(
        padding: EdgeInsets.all(Foundations.spacing.lg),
        child: IntrinsicHeight(child: content), // Add IntrinsicHeight here
      );
    }

    return content;
  }

  /// Builds a single column with header and draggable items
  Widget _buildColumn(SortableColumn<T> column) {
    return SizedBox(
      width: widget.columnWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Column header
          _buildColumnHeader(column),

          SizedBox(height: Foundations.spacing.md),

          // Draggable items area
          Expanded(
            child: DragTarget<Map<String, dynamic>>(
              onWillAccept: (data) {
                // Allow drop if data contains item and source column
                return data != null &&
                    data.containsKey('item') &&
                    data.containsKey('sourceColumnId');
              },
              onAcceptWithDetails: (details) {
                final data = details.data;
                final item = data['item'] as SortableItem<T>;
                final sourceColumnId = data['sourceColumnId'] as String;

                // Only process if not dropping in the same position
                if (sourceColumnId == column.id &&
                    (_insertPosition == _draggedItemIndex ||
                        _insertPosition == _draggedItemIndex! + 1)) {
                  // Reset indicator state even when not making changes
                  setState(() {
                    _targetColumnId = null;
                    _insertPosition = null;
                  });
                  return;
                }

                // Update columns with the reordered items
                final updatedColumns = _reorderItems(
                    sourceColumnId, column.id, item, _insertPosition);

                // Reset the indicator state after processing the drop
                setState(() {
                  _targetColumnId = null;
                  _insertPosition = null;
                });

                // Call callback with updated columns
                widget.onItemsReordered?.call(
                  updatedColumns,
                  sourceColumnId,
                  column.id,
                  item.id,
                );
              },
              onLeave: (_) {
                setState(() {
                  if (_targetColumnId == column.id) {
                    _targetColumnId = null;
                    _insertPosition = null;
                  }
                });
              },
              onMove: (details) {
                // Calculate insert position based on pointer location

                try {
                  // Get the render box of the column
                  final RenderBox columnBox =
                      context.findRenderObject() as RenderBox;

                  // Convert global position to local position within this widget
                  final localPosition = columnBox.globalToLocal(details.offset);

                  // Find the header's actual height
                  final headerHeight = widget.columnHeaderHeight ??
                      // If columnHeaderHeight is null, we need to find the actual header height
                      // This is a simplified approach - in a full implementation you might
                      // want to measure the actual header height using a GlobalKey
                      48.0 + (column.description != null ? 20.0 : 0.0);

                  // Calculate relative position within the column's content area
                  final relativeY = localPosition.dy - headerHeight;

                  // Skip if position is negative (above the content area)
                  if (relativeY < 0) return;

                  // Rest of calculation remains the same...
                  const estimatedItemHeight = 80.0;
                  final itemHeightWithSpacing =
                      estimatedItemHeight + widget.itemSpacing;
                  final newPosition =
                      (relativeY / itemHeightWithSpacing).floor();
                  final clampedPosition =
                      newPosition.clamp(0, column.items.length);

                  // Only update state if position has changed
                  if (_targetColumnId != column.id ||
                      _insertPosition != clampedPosition) {
                    setState(() {
                      _targetColumnId = column.id;
                      _insertPosition = clampedPosition;
                    });
                  }
                } catch (e) {
                  // Add error handling to help diagnose issues
                  print('Error in drag calculation: $e');
                }
              },
              builder: (context, candidateData, rejectedData) {
                // Add visual feedback with different background when dragging over
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: Foundations.borders.md,
                    // Highlight the column when it's a potential drop target
                    color: candidateData.isNotEmpty
                        ? (ref.watch(appThemeProvider).isDarkMode
                            ? Foundations.darkColors.backgroundSubtle
                                .withOpacity(0.3)
                            : Foundations.colors.backgroundSubtle
                                .withOpacity(0.3))
                        : Colors.transparent,
                  ),
                  child: _buildColumnItems(column),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the column header with title and description
  Widget _buildColumnHeader(SortableColumn<T> column) {
    // Use the custom header widget if provided
    if (column.headerWidget != null) {
      return Container(
        key: _headerKeys[column.id],
        height: widget.columnHeaderHeight,
        constraints: widget.columnHeaderHeight == null
            ? null
            : BoxConstraints(minHeight: widget.columnHeaderHeight!),
        decoration: BoxDecoration(
          color: ref.watch(appThemeProvider).isDarkMode
              ? Foundations.darkColors.backgroundMuted
              : Foundations.colors.backgroundMuted,
          borderRadius: Foundations.borders.md,
        ),
        child: column.headerWidget!,
      );
    }

    // Default header with title and description
    return Container(
      key: _headerKeys[column.id],
      height: widget.columnHeaderHeight,
      constraints: widget.columnHeaderHeight == null
          ? null
          : BoxConstraints(minHeight: widget.columnHeaderHeight!),
      padding: EdgeInsets.symmetric(
        horizontal: Foundations.spacing.lg,
        vertical: Foundations.spacing.md,
      ),
      decoration: BoxDecoration(
        color: ref.watch(appThemeProvider).isDarkMode
            ? Foundations.darkColors.backgroundMuted
            : Foundations.colors.backgroundMuted,
        borderRadius: Foundations.borders.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            column.title,
            style: TextStyle(
              fontSize: Foundations.typography.base,
              fontWeight: Foundations.typography.medium,
              color: ref.watch(appThemeProvider).isDarkMode
                  ? Foundations.darkColors.textPrimary
                  : Foundations.colors.textPrimary,
            ),
          ),
          if (column.description != null) ...[
            SizedBox(height: Foundations.spacing.xs),
            Text(
              column.description!,
              style: TextStyle(
                fontSize: Foundations.typography.sm,
                color: ref.watch(appThemeProvider).isDarkMode
                    ? Foundations.darkColors.textMuted
                    : Foundations.colors.textMuted,
              ),
              softWrap: true,
            ),
          ],
        ],
      ),
    );
  }

  /// Builds the list of items in a column
  Widget _buildColumnItems(SortableColumn<T> column) {
    final items = column.items;

    if (items.isEmpty && widget.showEmptyPlaceholder) {
      return _buildEmptyPlaceholder(column);
    }

    // Create a list of widgets that includes all items and placeholders
    final List<Widget> children = [];
    for (int index = 0;
        index < items.length + (_targetColumnId == column.id ? 1 : 0);
        index++) {
      // Show placeholder at insert position
      if (_targetColumnId == column.id &&
          _insertPosition != null &&
          index == _insertPosition) {
        children.add(_buildInsertPlaceholder());
        continue;
      }

      // Adjust index if we're past the insert position
      final itemIndex = (_targetColumnId == column.id &&
              _insertPosition != null &&
              index > _insertPosition!)
          ? index - 1
          : index;

      if (itemIndex >= items.length) continue;

      final item = items[itemIndex];

      // Skip the dragged item in its original column
      if (_draggedItem != null &&
          _draggedItem!.id == item.id &&
          _sourceColumnId == column.id) {
        continue;
      }

      children.add(_buildDraggableItem(item, column.id, itemIndex));
    }

    return ListView(
      padding: EdgeInsets.zero,
      shrinkWrap: false, // Allow it to fill available space
      children: children,
    );
  }

  /// Builds a draggable item
  Widget _buildDraggableItem(SortableItem<T> item, String columnId, int index) {
    return Draggable<Map<String, dynamic>>(
      // Changed from LongPressDraggable
      // Adding a feedback alignment to keep the dragged item centered under finger
      feedbackOffset: const Offset(0, 0),
      data: {
        'item': item,
        'sourceColumnId': columnId,
      },
      onDragStarted: () {
        setState(() {
          _draggedItem = item;
          _sourceColumnId = columnId;
          _draggedItemIndex = index;
        });
      },
      onDragEnd: (details) {
        setState(() {
          _draggedItem = null;
          _sourceColumnId = null;
          _targetColumnId = null;
          _draggedItemIndex = null;
          _insertPosition = null;
        });
      },
      feedback: Material(
        elevation: 8.0,
        borderRadius: Foundations.borders.md,
        child: SizedBox(
          // Explicitly set width with SizedBox
          width: widget.columnWidth,
          child: widget.itemBuilder(context, item),
        ),
      ),
      childWhenDragging: const SizedBox(
        height: 0,
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: widget.itemSpacing),
        child: widget.itemBuilder(context, item),
      ),
    );
  }

  /// Builds a placeholder for empty columns
  Widget _buildEmptyPlaceholder(SortableColumn<T> column) {
    if (widget.emptyPlaceholderBuilder != null) {
      return widget.emptyPlaceholderBuilder!(context, column);
    }

    return Container(
      margin: EdgeInsets.all(Foundations.spacing.lg),
      padding: EdgeInsets.all(Foundations.spacing.xl),
      decoration: BoxDecoration(
        color: ref.watch(appThemeProvider).isDarkMode
            ? Foundations.darkColors.surfaceHover.withOpacity(0.2)
            : Foundations.colors.surfaceHover.withOpacity(0.2),
        borderRadius: Foundations.borders.md,
        border: Border.all(
          color: ref.watch(appThemeProvider).isDarkMode
              ? Foundations.darkColors.border.withOpacity(0.5)
              : Foundations.colors.border.withOpacity(0.5),
        ),
      ),
      child: Center(
        child: Text(
          'Drag items here',
          style: TextStyle(
            fontSize: Foundations.typography.base,
            color: ref.watch(appThemeProvider).isDarkMode
                ? Foundations.darkColors.textMuted
                : Foundations.colors.textMuted,
          ),
        ),
      ),
    );
  }

  /// Builds a placeholder for showing where an item will be inserted
  Widget _buildInsertPlaceholder() {
    return AnimatedContainer(
      duration: Foundations.effects.shortAnimation,
      height: 6, // Made slightly thicker for better visibility
      margin: EdgeInsets.symmetric(
        vertical: widget.itemSpacing / 2,
        horizontal: Foundations.spacing.md,
      ),
      decoration: BoxDecoration(
        color: ref.watch(appThemeProvider).accentLight,
        borderRadius: Foundations.borders.full,
        // Add subtle glow effect
        boxShadow: [
          BoxShadow(
            color: ref.watch(appThemeProvider).accentLight.withOpacity(0.4),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }

  /// Reorders items between columns
  List<SortableColumn<T>> _reorderItems(String sourceColumnId,
      String targetColumnId, SortableItem<T> item, int? insertPosition) {
    // Find source and target columns
    final sourceColumnIndex =
        widget.columns.indexWhere((c) => c.id == sourceColumnId);
    final targetColumnIndex =
        widget.columns.indexWhere((c) => c.id == targetColumnId);

    // Return original columns if source or target not found
    if (sourceColumnIndex == -1 ||
        targetColumnIndex == -1 ||
        insertPosition == null) {
      return List.from(widget.columns);
    }

    final List<SortableColumn<T>> updatedColumns = List.from(widget.columns);
    final sourceColumn = updatedColumns[sourceColumnIndex];
    final targetColumn = updatedColumns[targetColumnIndex];

    // Create copies of the item lists
    final sourceItems = List<SortableItem<T>>.from(sourceColumn.items);
    final targetItems = List<SortableItem<T>>.from(targetColumn.items);

    // Find and remove the item from source column
    final itemIndex = sourceItems.indexWhere((i) => i.id == item.id);
    if (itemIndex != -1) {
      sourceItems.removeAt(itemIndex);
      // Update source column
      updatedColumns[sourceColumnIndex] =
          sourceColumn.copyWith(items: sourceItems);
    } else {
      // Item not found in source column - this shouldn't happen
      print('Warning: Item not found in source column');
      return List.from(widget.columns);
    }

    // Add item to target column
    if (sourceColumnId == targetColumnId) {
      // Reordering within the same column - adjust insert position
      final actualInsertPos =
          insertPosition > itemIndex ? insertPosition - 1 : insertPosition;
      sourceItems.insert(actualInsertPos, item);
      updatedColumns[sourceColumnIndex] =
          sourceColumn.copyWith(items: sourceItems);
    } else {
      // Moving between columns
      final insertAt = insertPosition.clamp(0, targetItems.length);
      targetItems.insert(insertAt, item);
      updatedColumns[targetColumnIndex] =
          targetColumn.copyWith(items: targetItems);
    }

    return updatedColumns;
  }
}
