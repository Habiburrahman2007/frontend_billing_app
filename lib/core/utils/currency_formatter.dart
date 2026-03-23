import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: '',
    decimalDigits: 0,
  );

  /// Formats a number to Dot-separated thousands (e.g., 25.000)
  static String format(num amount) {
    return _formatter.format(amount).trim();
  }
}
