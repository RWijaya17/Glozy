import 'package:intl/intl.dart';

class CurrencyHelper {
  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static String formatCurrency(double amount) {
    return _formatter.format(amount);
  }

  static String formatCurrencyWithoutSymbol(double amount) {
    return NumberFormat.decimalPattern('id_ID').format(amount);
  }

  static String formatCurrencyShort(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }

  static double parseCurrency(String value) {
    try {
      // Remove currency symbol and whitespace
      String cleanValue = value
          .replaceAll('Rp', '')
          .replaceAll(' ', '')
          .replaceAll('.', '')
          .replaceAll(',', '.');

      return double.parse(cleanValue);
    } catch (e) {
      return 0.0;
    }
  }

  static bool isValidAmount(String value) {
    try {
      double amount = parseCurrency(value);
      return amount > 0;
    } catch (e) {
      return false;
    }
  }
}
