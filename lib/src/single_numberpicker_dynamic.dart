import 'dart:async';

import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'numberpicker_model.dart';

/// A horizontal picker widget that allows users to select a value from a list.
///
/// The picker displays a list of values in a horizontal layout, with the selected
/// value highlighted. The user can scroll through the list to select a different value.
///
/// The widget provides a range of customization options, including the ability to
/// specify the text style, decoration, and padding for the selected and unselected
/// items.
class SingleNumberPicker extends StatefulWidget {
  /// The list of values to be displayed in the picker.
  //final List<num> values;

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

  /// Creates a new instance of the HorizontalPicker widget.
  const SingleNumberPicker({
    super.key,
    //required this.values,
    required this.onValueSelected,
    this.selectedTextStyle,
    this.unselectedTextStyle,
    this.itemExtent = 80,
    this.diameterRatio = 1.7,
    this.perspective = 0.005,
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

/// The state class for the HorizontalPicker widget.
///
/// This class manages the state of the HorizontalPicker widget, including the
/// scroll controller, selected index notifier, and text style.
class _SingleNumberPickerState extends State<SingleNumberPicker> {
  /// The scroll controller for the ListWheelScrollView.
  late FixedExtentScrollController _scrollController;

  /// The notifier for the currently selected index.
  late ValueNotifier<int> _selectedIndexNotifier;

  //Values to show, 0 to 9 is generated
  List<int> values = List.generate(10, (value) => value);

  /// The current selection
  //int _currentIndex = -1;

  /*@override
  void didUpdateWidget(covariant SingleNumberPicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    //Update selection on change
    /*if ( (oldWidget.initialSelectedIndex != widget.initialSelectedIndex ||
        widget.initialSelectedIndex == 0)
        ) {
      debugPrint("Jalalalal");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.jumpToItem(widget.initialSelectedIndex ?? 0);
      });
    }*/
  }*/

  @override
  /// Initializes the state of the HorizontalPicker widget.
  ///
  /// This method is called when the widget is inserted into the tree.
  void initState() {
    super.initState();

    //Reverse if set
    if(widget.reverse) {
      values = values.reversed.toList();
    }

    debugPrint("single: startValue ${widget.initalValue} - pos: ${widget.numberPosition}");

    //Find index based on value
    int startValue = widget.initalValue ?? 0;
    startValue = values.indexWhere((value) => value == startValue);
    if(startValue == -1) startValue = 0; //indexWhere returns -1 not found

    // Initialize the selected index notifier with the initial selected index.
    _selectedIndexNotifier = ValueNotifier(startValue);

    // Initialize the scroll controller with the initial selected index.
    _scrollController = FixedExtentScrollController(
      initialItem: _selectedIndexNotifier.value,
    );

    //Store current value
    //_currentIndex = _selectedIndexNotifier.value;

    // Add a post-frame callback to notify the parent widget of the initial selected value.
    /*WidgetsBinding.instance.addPostFrameCallback((_) {
    });*/

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      //Ensure to trigger when scrolling has stopped
      _scrollController.position.isScrollingNotifier.addListener(scrollStopped);
      //_triggerValueSelected();
    });
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
      //debugPrint('scroll is stopped');
      _triggerValueSelected();
    }
  }

  @override
  /// Disposes of the resources used by the HorizontalPicker widget.
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

  /// Builds the HorizontalPicker widget.
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
}
