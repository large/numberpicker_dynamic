import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker_dynamic/numberpicker_dynamic.dart';

import 'numberpicker_model.dart';

///Main widget for creating all widgets
class NumberPickerDynamic extends StatefulWidget {
  const NumberPickerDynamic({
    super.key,
    required this.onValueChange,
    this.itemHeight = 150,
    this.itemWidth = 350,
    this.initValue = 0,
  });

  final num initValue;
  final double itemHeight;
  final double itemWidth;
  final ValueChanged<num> onValueChange;

  @override
  State<NumberPickerDynamic> createState() => _NumberPickerDynamicState();
}

class _NumberPickerDynamicState extends State<NumberPickerDynamic> {
  final List<num> _fractions = List<num>.empty(growable: true);
  final List<num> _decimals = List<num>.empty(growable: true);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //_fractions.add(2);
    //_fractions.add(4);
    createByNum(widget.initValue);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.itemHeight,
      width: widget.itemWidth,
      child: Container(
        color: Colors.orange,
        child: Center(
          child: ListView.builder(
            //To have center effect shrinkWrap needs to be true
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount:
                2 +
                _fractions.length +
                _decimals.length +
                (_decimals.isNotEmpty ? 1 : 0),
            itemExtent: 50,
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
                pickerWidth: 50,
                unselectedTextStyle: Theme.of(context).textTheme.headlineLarge,
                selectedTextStyle: Theme.of(context).textTheme.headlineLarge,
                selectedItemPadding: const EdgeInsets.all(10.0),
                selectedItemDecoration: BoxDecoration(
                  color: Colors.yellow,
                  border: Border.all(color: Colors.yellow),
                  borderRadius: BorderRadius.circular(20),
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

                  //Get double
                  num test = getNum();
                  widget.onValueChange(test);
                },
                numberPosition: (i < _fractions.length + 1) ? (i - 1) : i - _fractions.length - 2,
                isDecimal: (i < _fractions.length + 1) ? false : true,
              );
            },
          ),
        ),
      ),
    );
  }

  //Helper to get value based on position
  int _indexToValue(int position) {
    if (position <= _fractions.length + 1) {
      int v = _fractions[position - 1].toInt();
      debugPrint("v is $v at position $position");
      return v;
    }

    if (position > _fractions.length + 1) {
        int v = _decimals[position - _fractions.length - 2].toInt();
        debugPrint("v decimal is $v at position $position");
        return v;
      }

    return 0;
  }

  ///
  /// Widget dot (simple non movable character)
  Widget dotWidget() {
    return Center(
      child: Text(".", style: Theme.of(context).textTheme.headlineLarge),
    );
  }

  ///
  /// Widget add fraction / decimal (clickable frame)
  Widget addFractionOrDecimal({required bool fraction}) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.yellow),
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          onTap: () {
            setState(() {
              if (fraction) {
                _fractions.insert(0, 0);
              } else {
                _decimals.add(0);
              }
            });
          },
          onLongPress: () {
            setState(() {
              if (fraction) {
                _fractions.removeAt(0);
              } else {
                _decimals.removeLast();
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(fraction ? Icons.plus_one : Icons.numbers),
          ),
        ),
      ),
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
    for(int i=0;i<_decimals.length ;i++)
      {
        result += _decimals[i] * (1 / pos);
        pos *= 10;
      }

    //Ensure we got the precision user selected
    result = num.parse(result.toStringAsFixed(_decimals.length));

    return result;
  }

  void createByNum(num value)
  {
    int fraction = value.toInt();
    int decimals = int.tryParse(value.toString().split('.')[1]) ?? 0;
    String fractionString = fraction.toString();
    for(int i = 0; i<fractionString.length;i++) {
        _fractions.add(num.tryParse(fractionString[i]) ?? 0);
      }

    //If decimals are zero, we just ignore
    if(decimals == 0) {
      return;
    }

    String decimalString = decimals.toString();
    for(int i = 0; i<decimalString.length;i++) {
      _decimals.add(num.tryParse(decimalString[i]) ?? 0);
    }
  }
}
