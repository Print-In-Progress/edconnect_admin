import 'package:flutter/material.dart';

class MultiSelectDropdown extends StatefulWidget {
  final Map<String, String> items; // Map of value to display text
  final List<String> selectedItems;
  final ValueChanged<List<String>> onSelectionChanged;
  final String searchHint;
  final String dropdownLabel;
  final Color color;

  MultiSelectDropdown({
    required this.items,
    required this.selectedItems,
    required this.onSelectionChanged,
    this.searchHint = 'Search items',
    this.dropdownLabel = 'Select items',
    required this.color,
  });

  @override
  _MultiSelectDropdownState createState() => _MultiSelectDropdownState();
}

class _MultiSelectDropdownState extends State<MultiSelectDropdown> {
  List<String> selectedItems = [];
  String searchText = "";

  @override
  void initState() {
    super.initState();
    selectedItems = List.from(widget.selectedItems);
  }

  void _onItemCheckedChange(String itemValue, bool checked) {
    setState(() {
      if (checked) {
        selectedItems.add(itemValue);
      } else {
        selectedItems.remove(itemValue);
      }
    });
    widget.onSelectionChanged(selectedItems);
  }

  void _openDropdownModal(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext ctx) {
        return DraggableScrollableSheet(
          initialChildSize:
              0.5, // Initial height of the modal as a fraction of the screen height
          minChildSize: 0.5, // Minimum height of the modal
          maxChildSize: 0.8, // Maximum height of the modal
          snapSizes: const [0.5, 0.8],
          expand: false,
          snap: true,
          builder: (BuildContext context, ScrollController scrollController) {
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter modalSetState) {
                return Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[500],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Search bar
                        TextField(
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText: widget.searchHint,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onChanged: (value) {
                            modalSetState(() {
                              searchText = value.toLowerCase();
                            });
                          },
                        ),
                        const SizedBox(height: 10),

                        // List of items with selection
                        Expanded(
                          child: ListView(
                            controller: scrollController,
                            children: [
                              ...widget.items.entries
                                  .where((entry) => entry.value
                                      .toLowerCase()
                                      .contains(searchText))
                                  .map((entry) {
                                return ListTile(
                                  title: Text(entry.value),
                                  trailing: Checkbox(
                                    value: selectedItems.contains(entry.key),
                                    onChanged: (bool? isSelected) {
                                      modalSetState(() {
                                        if (isSelected!) {
                                          selectedItems.add(entry.key);
                                        } else {
                                          selectedItems.remove(entry.key);
                                        }
                                      });
                                    },
                                  ),
                                );
                              }).toList(),
                              // Add your element at the bottom of the ListView
                              FilledButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  setState(() {
                                    widget.onSelectionChanged(selectedItems);
                                  });
                                },
                                icon: Icon(Icons.check),
                                label: Text('Done'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display selected chips
        Wrap(
          spacing: 8.0,
          children: selectedItems.map((item) {
            return Chip(
              label: Text(widget.items[item]!),
              onDeleted: () {
                setState(() {
                  selectedItems.remove(item);
                  widget.onSelectionChanged(selectedItems);
                });
              },
            );
          }).toList(),
        ),
        selectedItems.isEmpty
            ? const SizedBox.shrink()
            : const SizedBox(height: 10.0),

        // Dropdown button to open the modal
        GestureDetector(
          onTap: () {
            _openDropdownModal(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              border:
                  Border.all(color: widget.color.withOpacity(0.2), width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
//                  selectedItems.isEmpty
//                      ? widget.dropdownLabel
//                      : selectedItems
//                          .map((item) => widget.items[item])
//                          .join(', '),
                  widget.dropdownLabel,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: widget.color),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: widget.color,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
