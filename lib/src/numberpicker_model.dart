//Return value from each numberpicker
class NumberPickerPosition {
  const NumberPickerPosition({
    required this.isDecimal,
    required this.value,
    required this.position,
  });

  final int position;
  final bool isDecimal;
  final num value;
}
