import 'package:intl/intl.dart';

class DateFormatter {
  static String todayDateYYYYMMDDString () {
    DateTime now = new DateTime.now();
    DateFormat formatter = new DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);
    return formattedDate;
  }

  static String thirtyDaysAgoYYYYMMDDString () {
    DateTime now = new DateTime.now();
    DateTime thirtyDaysAgo = now.subtract(const Duration(days: 30));
    DateFormat formatter = new DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(thirtyDaysAgo);
    return formattedDate;
  }

  static String dateToPtBr (String date) {
    DateTime dateTime = DateTime.parse(date);
    DateFormat formatter = new DateFormat('dd/MM/yyyy');
    String formattedDate = formatter.format(dateTime);
    return formattedDate;
  }
}