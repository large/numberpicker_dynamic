import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numberpicker_dynamic/numberpicker_dynamic.dart';

import 'numberpicker_model.dart';

///Main widget for creating all widgets
class NumberPickerDynamic extends StatefulWidget {
  const NumberPickerDynamic({
    super.key,
    required this.onValueChange,
    this.itemHeight = 110,
    this.itemWidth = double.infinity,
    this.initValue = 0,
    this.itemExtent = 50,
    this.background,
    this.buttonBackground,
    this.buttonIconColor,
    this.textStyle,
    this.textPadding,
    this.textSelectDecoration,
  });

  final TextStyle? textStyle;
  final EdgeInsets? textPadding;
  final BoxDecoration? textSelectDecoration;

  final Color? background;
  final Color? buttonBackground;
  final Color? buttonIconColor;
  final num initValue;
  final double itemHeight;
  final double itemWidth;
  final double itemExtent;
  final ValueChanged<num> onValueChange;

  @override
  State<NumberPickerDynamic> createState() => _NumberPickerDynamicState();
}

class _NumberPickerDynamicState extends State<NumberPickerDynamic> {
  final List<num> _fractions = List<num>.empty(growable: true);
  final List<num> _decimals = List<num>.empty(growable: true);

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    createByNum(widget.initValue);
  }

  @override
  void didUpdateWidget(covariant NumberPickerDynamic oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);

    //If the initValue is not the same, update it
    //This ensure that when setState is triggered a new value is stored
    if (oldWidget.initValue != widget.initValue) {
      updateByNum(widget.initValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.itemHeight,
      width: widget.itemWidth,
      child: Container(
        color:
            widget.background ?? Theme.of(context).colorScheme.surfaceContainer,
        child: Center(
          child: ListView.builder(
            //To have center effect shrinkWrap needs to be true
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            controller: _scrollController,
            itemCount: _itemCount(),
            itemExtent: widget.itemExtent,
            itemBuilder: (context, i) {
              if (i == 0) {
                return addFractionOrDecimal(fraction: true);
              }
              if (i == _fractions.length + 1) {
                if (_decimals.isNotEmpty) {
                  return dotWidget();
                } else {
                  return addFractionOrDecimal(fraction: false);
                }
              }
              if (i == _fractions.length + _decimals.length + 2) {
                return addFractionOrDecimal(fraction: false);
              }
              return SingleNumberPicker(
                key: ValueKey(_keyName(i)),
                unselectedTextStyle:
                    widget.textStyle ??
                    Theme.of(context).textTheme.headlineLarge,
                selectedTextStyle:
                    widget.textStyle ??
                    Theme.of(context).textTheme.headlineLarge,
                selectedItemPadding:
                    widget.textPadding ?? EdgeInsets.all(widget.itemExtent / 5),
                selectedItemDecoration:
                    widget.textSelectDecoration ??
                    BoxDecoration(
                      color:
                          _isDecimal(i)
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(
                                context,
                              ).colorScheme.secondaryContainer,
                      border: Border.all(
                        color:
                            _isDecimal(i)
                                ? Theme.of(context).colorScheme.inversePrimary
                                : Theme.of(
                                  context,
                                ).colorScheme.onSecondaryContainer,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                values: List.generate(10, (value) => value),
                initialSelectedIndex: _indexToValue(i),
                onValueSelected: (NumberPickerPosition value) {
                  debugPrint(
                    "${value.isDecimal ? "Decimal" : "Fraction"} from singlepicker ${value.value} at position ${value.position} - stored ${value.isDecimal ? _decimals[value.position] : _fractions[value.position]}",
                  );
                  if (value.isDecimal) {
                    _decimals[value.position] = value.value;
                  } else {
                    _fractions[value.position] = value.value;
                  }

                  _triggerValueCallback();
                },
                numberPosition: _positionHelper(i),
                //(i < _fractions.length + 1) ? (i - 1) : i - _fractions.length - 2,
                isDecimal: _isDecimal(
                  i,
                ), //i < _fractions.length + 1) ? false : true,
              );
            },
          ),
        ),
      ),
    );
  }

  void _triggerValueCallback() {
    widget.onValueChange(getNum());
  }

  ///
  /// Internal helper for getting the key for this slider
  String _keyName(int position) {
    return "${_positionHelper(position)}-${_isDecimal(position)}-${_indexToValue(position)}";
  }

  ///
  /// Internal helper to say if position is decimal or not
  bool _isDecimal(int position) {
    //+1 for the first icon
    if (position < _fractions.length + 1) {
      return false;
    } else {
      return true;
    }
  }

  ///
  /// Internal helper for getting the correct position in the lists
  int _positionHelper(int position) {
    if (position < _fractions.length + 1) {
      //+1 for the first icon
      return position - 1;
    } else {
      //-2 is for the icon last AND the "dot" separator
      return position - _fractions.length - 2;
    }
  }

  //Helper to get value based on position
  int _indexToValue(int position) {
    if (position <= _fractions.length + 1) {
      int v = _fractions[position - 1].toInt();
      //debugPrint("v is $v at position $position");
      return v;
    }

    if (position > _fractions.length + 1) {
      int v = _decimals[position - _fractions.length - 2].toInt();
      //debugPrint("v decimal is $v at position $position");
      return v;
    }

    return 0;
  }

  ///
  /// Internal helper to tell how many items to add to the list view
  int _itemCount() {
    //+2 icons in front and back of the widget
    //Decimals check is for "dot" widget
    return 2 +
        _fractions.length +
        _decimals.length +
        (_decimals.isNotEmpty ? 1 : 0);
  }

  ///
  /// Widget dot (simple non movable character)
  Widget dotWidget() {
    return Center(
      child: Text(
        ".",
        style: widget.textStyle ?? Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }

  ///
  /// Widget add fraction / decimal (clickable frame)
  Widget addFractionOrDecimal({required bool fraction}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Material(
          color: Colors.transparent,
          child: Ink(
            decoration: ShapeDecoration(
              color:
                  widget.buttonBackground ??
                  Theme.of(context).colorScheme.tertiaryContainer,
              shape: CircleBorder(),
            ),
            child: IconButton(
              onPressed: () {
                setState(() {
                  if (fraction) {
                    _fractions.insert(0, 0);
                  } else {
                    _decimals.add(0);

                    //Do scrolling after frame is finished
                    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                      //Scroll to the end
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: Duration(milliseconds: 250),
                        curve: Curves.ease,
                      );
                    });
                  }
                });
              },
              icon: Icon(
                fraction ? Icons.chevron_left_sharp : Icons.chevron_right_sharp,
              ),
              iconSize: 30,
              color:
                  widget.buttonIconColor ??
                  Theme.of(context).colorScheme.tertiary,
            ),
          ),
        ),

        if (fraction && _fractions.isNotEmpty ||
            !fraction && _decimals.isNotEmpty)
          Material(
            color: Colors.transparent,
            child: Ink(
              decoration: ShapeDecoration(
                color:
                    widget.buttonBackground ??
                    Theme.of(context).colorScheme.tertiary,
                shape: CircleBorder(),
              ),
              child: IconButton(
                onPressed: () {},
                onLongPress: () {
                  setState(() {
                    if (fraction) {
                      if (_fractions.isNotEmpty) {
                        if (_fractions.length == 1 && _decimals.isEmpty) return;
                        _fractions.removeAt(0);
                      }
                    } else {
                      if (_decimals.isNotEmpty) {
                        if (_decimals.length == 1 && _fractions.isEmpty) return;
                        _decimals.removeLast();
                      }
                    }
                  });

                  //Update value
                  _triggerValueCallback();
                },
                icon: Icon(fraction ? Icons.chevron_right : Icons.chevron_left),
                iconSize: 30,
                color:
                    widget.buttonIconColor ??
                    Theme.of(context).colorScheme.onTertiary,
              ),
            ),
          ),
      ],
    );
  }

  ///
  /// Returns a double based on user selection
  num getNum() {
    num result = 0;
    int pos = 1;
    for (int i = _fractions.length - 1; i >= 0; i--) {
      result += _fractions[i] * pos;
      pos *= 10;
    }

    pos = 10;
    for (int i = 0; i < _decimals.length; i++) {
      result += _decimals[i] * (1 / pos);
      pos *= 10;
    }

    //Ensure we got the precision user selected
    result = num.parse(result.toStringAsFixed(_decimals.length));

    return result;
  }

  ///
  /// Creates fraction & decimals based on 10th position
  void createByNum(num value) {
    int fraction = value.toInt();
    List<String> decimalStringArray = value.toString().split('.');
    int decimals =
        int.tryParse(
          decimalStringArray.length < 2 ? "" : decimalStringArray[1],
        ) ??
        0;
    String fractionString = fraction.toString();
    for (int i = 0; i < fractionString.length; i++) {
      _fractions.add(num.tryParse(fractionString[i]) ?? 0);
    }

    //If decimals are zero, we just ignore
    if (decimals == 0) {
      return;
    }

    String decimalString = decimals.toString();
    for (int i = 0; i < decimalString.length; i++) {
      _decimals.add(num.tryParse(decimalString[i]) ?? 0);
    }
  }

  ///
  /// Update existing data with new value
  void updateByNum(num value) {
    //Do same checks as in the createNum(...)
    int fraction = value.toInt();
    List<String> decimalStringArray = value.toString().split('.');
    num decimals =
        num.tryParse(
          decimalStringArray.length < 2 ? "" : decimalStringArray[1],
        ) ??
        0;

    String decimalString = decimals.toString();
    String fractionString = fraction.toString();

    //If there are less fractions than the string, we add them (if not empty)
    if (_fractions.length < fractionString.length &&
        (_fractions.isNotEmpty || fraction != 0)) {
      int add = fractionString.length - _fractions.length;
      for (int i = 0; i < add; i++) {
        _fractions.add(0);
      }
    }

    //If there are more fractions than the string, we zero the first items
    if(_fractions.length > fractionString.length)
      {
        for (int i = 0; i < _fractions.length - fractionString.length; i++) {
          _fractions[i] = 0;
        }
     }

    //Update fractions
    //There can be zero in the beginning of this array that we want to keep.
    //So start working back to front based on string length
    if (_fractions.isNotEmpty) {
      for (int i = fractionString.length - 1; i >= 0; i--) {
        int pos = (_fractions.length - 1) - (fractionString.length - i - 1);
        _fractions[pos] = num.tryParse(fractionString[i]) ?? 0;
      }
    }

    //If decimals are zero, we are finished
    if (decimals == 0) {
      for(int i=0;i<_decimals.length;i++) {
        _decimals[i] = 0;
      }
      return;
    }

    //If there are less decimals than the string, we add them (if not empty)
    if (_decimals.length < decimalString.length /*&&
        (_fractions.isNotEmpty || fraction != 0)*/) {
      int add = decimalString.length - _decimals.length;
      for (int i = 0; i < add ; i++) {
        _decimals.add(0);
      }
    }

    //Update decimals
    for (int i = 0; i < decimalString.length; i++) {
      _decimals[i] = num.tryParse(decimalString[i]) ?? 0;
    }
  }
}
