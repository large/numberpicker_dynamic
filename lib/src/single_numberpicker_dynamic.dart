
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'numberpicker_model.dart';

/// A vertical number picker widget that allows users to select number 0 to 9
class SingleNumberPicker extends StatefulWidget {
  /// The text style to be used for the selected item.
  final TextStyle? selectedTextStyle;

  /// The text style to be used for the unselected items.
  final TextStyle? unselectedTextStyle;

  /// A callback function that is called when the user selects a new value.
  final ValueChanged<NumberPickerPosition> onValueSelected;

  /// The extent of each item in the picker.
  final double itemExtent;

  /// The diameter ratio of the picker.
  final double diameterRatio;

  /// The perspective of the picker.
  final double perspective;

  /// The initial index of the selected item.
  final int? initalValue;

  /// The decoration to be used for the selected item.
  final BoxDecoration? selectedItemDecoration;

  /// The decoration to be used for the unselected items.
  final BoxDecoration? unselectedItemDecoration;

  /// The padding to be used for the selected item.
  final EdgeInsets? selectedItemPadding;

  /// The padding to be used for the unselected items.
  final EdgeInsets? unSelectedItemPadding;

  /// The duration of the scroll animation.
  final Duration? scrollDuration;

  /// Notify which position the scroller is
  final int numberPosition;

  /// Feedback if numberPosition is decimal
  final bool isDecimal;

  /// Reverse or not
  final bool reverse;

  /// Creates a new instance of the SingleNumberPicker widget.
  const SingleNumberPicker({
    super.key,
    //required this.values,
    required this.onValueSelected,
    this.selectedTextStyle,
    this.unselectedTextStyle,
    this.itemExtent = 80,
    this.diameterRatio = 1.7,
    this.perspective = 0.007,
    this.initalValue,
    this.selectedItemDecoration,
    this.unselectedItemDecoration,
    this.selectedItemPadding,
    this.unSelectedItemPadding,
    this.scrollDuration,
    required this.numberPosition,
    required this.isDecimal,
    this.reverse = true,
  });

  @override
  State<SingleNumberPicker> createState() => _SingleNumberPickerState();
}

/// The state class for the SingleNumberPicker widget.
///
/// This class manages the state of the SingleNumberPicker widget, including the
/// scroll controller, selected index notifier, and text style.
class _SingleNumberPickerState extends State<SingleNumberPicker> {
  /// The scroll controller for the ListWheelScrollView.
  late FixedExtentScrollController _scrollController;

  /// The notifier for the currently selected index.
  late ValueNotifier<int> _selectedIndexNotifier;

  //Values to show, 0 to 9 is generated
  List<int> values = List.generate(10, (value) => value);

  @override
  /// Initializes the state of the SingleNumberPicker widget.
  void initState() {
    //Reverse numbers if set (normal behaviour)
    if(widget.reverse) {
      values = values.reversed.toList();
    }

    //Find index based on value
    int startValue = widget.initalValue ?? 0;
    startValue = values.indexWhere((value) => value == startValue);
    if(startValue == -1) startValue = 0; //indexWhere returns -1 not found

    // Initialize the selected index notifier with the initial selected index.
    _selectedIndexNotifier = ValueNotifier(startValue);

    // Initialize the scroll controller with the initial selected index.
    _scrollController = FixedExtentScrollController(
      initialItem: _selectedIndexNotifier.value,
      onAttach: onScrollAttach,
      onDetach: onScrollDetach,
    );

    super.initState();
  }

  ///
  /// Internal helper for triggering callback of value, position and decimal
  void _triggerValueSelected()
  {
    widget.onValueSelected(
      NumberPickerPosition(
        value: values[_selectedIndexNotifier.value],
        isDecimal: widget.isDecimal,
        position: widget.numberPosition,
      ),
    );
  }

  ///
  /// Callback function when scrolling is started / stopped
  void scrollStopped()
  {
    if(!_scrollController.position.isScrollingNotifier.value) {
      _triggerValueSelected();
    }
  }

  @override
  /// Disposes of the resources used by the SingleNumberPicker widget.
  ///
  /// This method is called when the widget is removed from the tree.
  void dispose() {
    //Remove listener on scroller
    _scrollController.removeListener(scrollStopped);

    // Dispose of the scroll controller.
    _scrollController.dispose();

    // Dispose of the selected index notifier.
    _selectedIndexNotifier.dispose();

    super.dispose();
  }

  /// Returns the text style for the given index based on whether it is selected.
  ///
  /// If the index is selected, returns the selected text style. Otherwise, returns
  /// the unselected text style.
  TextStyle _getTextStyle(bool isSelected) {
    return isSelected
        ? widget.selectedTextStyle ??
            const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)
        : widget.unselectedTextStyle ??
            const TextStyle(fontSize: 26, fontWeight: FontWeight.normal);
  }

  /// Builds the SingleNumberPicker widget.
  ///
  /// This method is called when the widget is inserted into the tree.
  @override
  Widget build(BuildContext context) {

    // Center the picker horizontally and vertically
    return Center(
      child: ListWheelScrollView.useDelegate(

        // Set the scroll controller for the picker
        controller: _scrollController,
        // Set the physics for the scroll view
        // This ensures that it will select nearest object
        physics: const FixedExtentScrollPhysics(),
        // Set the extent of each item in the list
        itemExtent: widget.itemExtent,
        // Set the diameter ratio for the scroll view
        diameterRatio: widget.diameterRatio,
        // Set the perspective for the scroll view
        perspective: widget.perspective,
        // Handle changes to the selected item
        onSelectedItemChanged: (index) {
          // Check if the new index is the same as the current index
          if (_selectedIndexNotifier.value == index) return;

          //Store the current selection
          _selectedIndexNotifier.value = index;
        },
        // Build the child delegate for the list wheel scroll view
        childDelegate: ListWheelChildBuilderDelegate(
          // Build each item in the list
          builder: (context, index) {
            // Check if the index is out of range
            if (index < 0 || index >= values.length) return null;

            return Center(
              child: ValueListenableBuilder(
                // Listen to the selected index notifier
                valueListenable: _selectedIndexNotifier,
                // Build the item based on whether it's selected
                builder: (context, selectedIndex, child) {
                  // Check if the item is selected
                  final isSelected = index == selectedIndex;

                  return Container(
                    // Set the decoration and padding based on whether the item is selected
                    decoration:
                        isSelected
                            ? widget.selectedItemDecoration
                            : widget.unselectedItemDecoration,
                    padding:
                        isSelected
                            ? widget.selectedItemPadding
                            : widget.unSelectedItemPadding,
                    child: Text(
                      // Display the value of the item
                      values[index].toString(),
                      // Get the text style based on whether the item is selected
                      style: _getTextStyle(isSelected),
                      // Set the max lines and overflow for the text
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ),
            );
          },
          // Set the child count for the list wheel scroll view
          childCount: values.length,
        ),
      ),
    );
  }

  /// Scrollcontroller onAttach() function, ensure that we are getting scrolldata
  void onScrollAttach(ScrollPosition sp) {
    //_scrollController.position.isScrollingNotifier.addListener(scrollStopped);
    sp.isScrollingNotifier.addListener(scrollStopped);
  }

  /// Scrollcontroller onDetach() function, ensure free memory for the callback
  void onScrollDetach(ScrollPosition sp) {
    sp.isScrollingNotifier.removeListener(scrollStopped);
  }
}
