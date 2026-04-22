import 'package:intl/intl.dart';

String formatCurrency(num amount, String currency) {
  switch (currency) {
    case 'USD':
      return NumberFormat.currency(locale: 'en_US', symbol: '\$').format(amount);
    case 'EUR':
      return NumberFormat.currency(locale: 'de_DE', symbol: '€').format(amount);
    case 'MYR':
      return NumberFormat.currency(locale: 'ms_MY', symbol: 'RM ').format(amount);
    default:
      return NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(amount);
  }
}