// Project imports:
import '../imports.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  final String symbol;
  final bool showDecimal;
  final bool withGap;

  CurrencyInputFormatter({
    this.symbol = "RM",
    this.showDecimal = true,
    this.withGap = false,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    final double value = double.parse(newValue.text);

    final formatter = NumberFormat.currency(
      symbol: withGap ? "$symbol " : symbol,
      decimalDigits: showDecimal ? 2 : 0,
    );

    final newText =
        showDecimal ? formatter.format(value / 100) : formatter.format(value);

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
