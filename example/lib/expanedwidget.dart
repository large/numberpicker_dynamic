import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numberpicker_dynamic/numberpicker_dynamic.dart';

///Example of own widget with textfield and numberpicker
class ExpandedNumberPicker extends StatefulWidget {
  const ExpandedNumberPicker({super.key, required this.onExpanded});

  final VoidCallback onExpanded;

  @override
  State<ExpandedNumberPicker> createState() => _ExpandedNumberPickerState();
}

class _ExpandedNumberPickerState extends State<ExpandedNumberPicker> {
  ///Text editing controller for the text field + focusHandling
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  //Static value at startup
  num _value = 123;

  //How the text field will look
  InputDecoration textFieldDecoration(String hintText, String suffix) {
    return InputDecoration(
      //border: const OutlineInputBorder(),
      labelStyle: Theme.of(context).textTheme.titleMedium,
      suffixText: suffix.isEmpty ? null : " [$suffix]",
      hintText: hintText,
      contentPadding: const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
    );
  }

  @override
  void initState() {
    super.initState();

    //Set the initial value in the text field after first frame is set
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _textController.text = _value.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: Colors.blueGrey,
        child: ExpansionTile(
          //Removes a Divider() drawn on top/bottom while expanded
          shape: Border(),
          title: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8),
                child: Text(
                  "Value: ",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Expanded(
                child: TextFormField(
                  focusNode: _focusNode,
                  style: Theme.of(context).textTheme.headlineSmall,
                  controller: _textController,
                  onChanged: (text) {
                    setState(() {
                      //Since , is available in keyboard, just convert it
                      _value = num.tryParse(text.replaceAll(",", ".")) ?? 0;
                    });
                  },
                  textInputAction: TextInputAction.send,
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: false,
                    decimal: true,
                  ),
                  decoration: textFieldDecoration("Push for number", ""),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'(^-?\d*[.,]?\d{0,5})'),
                    ),
                  ],
                ),
              ),
              //Show icon to close the keyboard (for iOS users)
              if(_focusNode.hasFocus /*&& Theme.of(context).platform == TargetPlatform.iOS*/)
                IconButton.filledTonal(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                  },
                  icon: const Icon(Icons.check),
                ),
            ],
          ),
          children: [
            //GestureDetector removes focus from textfield when tapped
            NumberPickerDynamic(
              height: 100,
              maxDecimals: 5,
              initValue: _value,
              onValueChange: (value) {
                debugPrint("Value is $value");
                setState(() {
                  _value = value;
                  _textController.text = _value.toString();
                });
              },
            ),
          ],
          onExpansionChanged: (expanded) {
            if (expanded) {
              Future.delayed(Duration(milliseconds: 250), () {
                widget.onExpanded();
              });
            }
          },
        ),
      ),
    );
  }
}
