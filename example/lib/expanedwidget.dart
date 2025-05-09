import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numberpicker_dynamic/numberpicker_dynamic.dart';

class ExpandedNumberPicker extends StatefulWidget {
  const ExpandedNumberPicker({super.key, required this.onExpanded});

  final VoidCallback onExpanded;

  @override
  State<ExpandedNumberPicker> createState() => _ExpandedNumberPickerState();
}

class _ExpandedNumberPickerState extends State<ExpandedNumberPicker> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  num _value = 480.3;

  //How the text field will look
  InputDecoration textFieldDecoration(String text, String suffix) {
    return InputDecoration(
      //border: const OutlineInputBorder(),
      labelStyle: Theme.of(context).textTheme.titleMedium,
      suffixText: " [$suffix]",
      hintText: text,
      contentPadding: const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
    );
  }

  @override
  void initState() {
    super.initState();
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
                  "Number: ",
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
                  textInputAction: TextInputAction.done,
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: false,
                    decimal: true,
                  ),
                  decoration: textFieldDecoration("push for number", "suffix"),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'(^-?\d*[\.\,]?\d{0,5})'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          children: [
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
            if(expanded) {
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
