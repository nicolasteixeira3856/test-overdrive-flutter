import 'package:intl/intl.dart';

class CurrencyFormatter {

  static String doubleToBrazilianRealString(double currency) {
    NumberFormat formatter = NumberFormat.simpleCurrency(locale: 'pt_BR');
    String value = formatter.format(currency);
    return value;
  }
}