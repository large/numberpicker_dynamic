import 'dart:math';
import 'package:flutter/material.dart';
import 'package:numberpicker_dynamic/numberpicker_dynamic.dart';
import 'numberpicker_model.dart';

///Main widget for creating a complete numberpicker
class NumberPickerDynamic extends StatefulWidget {
  const NumberPickerDynamic({
    super.key,
    required this.onValueChange,
    this.height = 110,
    this.width = double.infinity,
    this.initValue = 0,
    this.itemExtent = 50,
    this.maxDecimals = 6,
    this.maxFractions = 12,
    this.valueChangeOnDecimalOverflow = true,
    this.buttonBackground,
    this.buttonIconColor,
    this.textStyle,
    this.textPadding,
    this.textSelectDecoration,
  });

  /// Override text style for each number
  final TextStyle? textStyle;

  /// Override padding for each number
  final EdgeInsets? textPadding;

  /// Override box decoration for each number
  final BoxDecoration? textSelectDecoration;

  /// Background color for button for + / - numbers
  final Color? buttonBackground;

  /// Icon color on button for + / - numbers
  final Color? buttonIconColor;

  /// Initial value of item
  final num initValue;

  /// Height of widget, defaults: 110
  final double height;

  /// Width of SizeBox around widget, defaults: double.inifity
  final double width;

  /// Listview itemExtent between each number
  final double itemExtent;

  /// Callback to parent when data is changing
  final ValueChanged<num> onValueChange;

  /// Max number of decimals, limited by double maxvalue
  final int maxDecimals;

  /// Max fractions (whole number) allowed, limited by double maxvalue
  final int maxFractions;

  /// Gives onValueChange trigger if data is being rounded in widget
  final bool valueChangeOnDecimalOverflow;

  @override
  State<NumberPickerDynamic> createState() => _NumberPickerDynamicState();
}

/// Stateclass for NumberPickerDynamic
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
    //Typical where parent sets new data
    if (oldWidget.initValue != widget.initValue) {
      updateByNum(widget.initValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    //Set textscale to max 40% oversize (handle zoom/textsize accesibility)
    return MediaQuery.withClampedTextScaling(
      minScaleFactor: 1.0,
      maxScaleFactor: 1.4,
      child: SizedBox(
        height: widget.height,
        width: widget.width,
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
                    Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                selectedItemPadding:
                    widget.textPadding ?? EdgeInsets.all(widget.itemExtent / 5),
                unSelectedItemPadding:
                    widget.textPadding ?? EdgeInsets.all(widget.itemExtent / 5),
                selectedItemDecoration: _getBoxDecoration(i),
                unselectedItemDecoration: _getBoxDecoration(i),
                initalValue: _indexToValue(i),
                onValueSelected: (NumberPickerPosition value) {
                  //debugPrint(
                  //  "${value.isDecimal ? "Decimal" : "Fraction"} from singlepicker ${value.value} at position ${value.position} - stored ${value.isDecimal ? _decimals[value.position] : _fractions[value.position]}",
                  //);
                  if (value.isDecimal) {
                    _decimals[value.position] = value.value;
                  } else {
                    _fractions[value.position] = value.value;
                  }

                  //Trigger setState
                  _triggerValueCallback();
                },
                numberPosition: _positionHelper(i),
                isDecimal: _isDecimal(i),
              );
            },
          ),
        ),
      ),
    );
  }

  ///
  /// Internal helper for getting box decorations (used on both versions)
  BoxDecoration _getBoxDecoration(int position) {
    return widget.textSelectDecoration ??
        BoxDecoration(
          color:
              _isDecimal(position)
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.secondaryContainer,
          border: Border.all(
            color:
                _isDecimal(position)
                    ? Theme.of(context).colorScheme.inversePrimary
                    : Theme.of(context).colorScheme.onSecondaryContainer,
          ),
          borderRadius: BorderRadius.circular(8),
        );
  }

  ///
  /// Internal helper for trigger callback to parent, but do it after frameback is OK
  void _triggerValueCallback() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widget.onValueChange(getNum());
    });
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

  ///
  /// Helper to get value based on position
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
        if (fraction && _fractions.length < widget.maxFractions ||
            !fraction && _decimals.length < widget.maxDecimals)
          IconButton.filled(
            onPressed: () {
              setState(() {
                if (fraction) {
                  if (_fractions.length < widget.maxFractions) {
                    _fractions.insert(0, 0);
                  }
                } else {
                  if (_decimals.length < widget.maxDecimals) _decimals.add(0);

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
                Theme.of(context).colorScheme.onTertiaryContainer,
          ),

        if (fraction && _fractions.isNotEmpty ||
            !fraction && _decimals.isNotEmpty)
          IconButton.filledTonal(
            onPressed: () {
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
                Theme.of(context).colorScheme.onTertiaryContainer,
            highlightColor: Colors.red,
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
    return roundDouble(result, _decimals.length);
  }

  ///
  /// Internal helper to ensure that decimals do not go bananas
  num roundDouble(num number, int decimalPlaces) {
    if (decimalPlaces == 0) return number.toInt();
    number = number * pow(10, decimalPlaces);
    int numInt = number.round();
    num result = numInt / pow(10, decimalPlaces);
    return result;
  }

  ///
  /// Creates fraction & decimals based on 10th position
  void createByNum(num value) {
    int fraction = value.toInt();
    String fractionString = fraction.toString();
    for (int i = 0; i < fractionString.length; i++) {
      _fractions.add(num.tryParse(fractionString[i]) ?? 0);
    }

    List<String> decimalStringArray = value.toString().split('.');
    String decimalString =
        decimalStringArray.length < 2 ? "" : decimalStringArray[1];
    int decimalAsNumber = int.tryParse(decimalString) ?? 0;

    //If decimals are zero, we just ignore
    if (decimalAsNumber == 0) {
      return;
    }

    //Create decimals base on string
    for (int i = 0; i < decimalString.length; i++) {
      _decimals.add(num.tryParse(decimalString[i]) ?? 0);
    }
  }

  ///
  /// Update existing data with new value
  void updateByNum(num value) {
    //Do same checks as in the createNum(...)
    ///// Fraction part
    int fraction = value.toInt();
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
    if (_fractions.length > fractionString.length) {
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

    ///// Decimal part
    //Get decimal as string + number (string needs to be a copy
    List<String> decimalStringArray = value.toString().split('.');
    String decimalString =
        decimalStringArray.length < 2 ? "" : decimalStringArray[1];
    num decimalAsNumber = num.tryParse(decimalString) ?? 0;

    //If decimals are zero, we are finished
    if (decimalAsNumber == 0) {
      for (int i = 0; i < _decimals.length; i++) {
        _decimals[i] = 0;
      }
      return;
    }

    //If the string is long, round it to max decimals and notify parents
    if (decimalString.length > widget.maxDecimals &&
        widget.valueChangeOnDecimalOverflow) {
      decimalAsNumber = roundDouble(value, widget.maxDecimals);
      decimalString = decimalAsNumber.toString().split('.')[1];
      _triggerValueCallback();
    }

    //If there are less decimals than the string, we add them (if not empty)
    if (_decimals.length < decimalString.length &&
        _decimals.length < widget.maxDecimals) {
      int add = decimalString.length - _decimals.length;
      for (int i = 0; i < add; i++) {
        _decimals.add(0);
      }
    }

    //Update decimals
    if (_decimals.isNotEmpty) {
      for (int i = 0; i < decimalString.length; i++) {
        _decimals[i] = num.tryParse(decimalString[i]) ?? 0;
      }
    }
  }
}
