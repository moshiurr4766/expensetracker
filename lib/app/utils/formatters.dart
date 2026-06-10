import 'package:intl/intl.dart';

class AppFormatters {
  static final currency = NumberFormat.currency(symbol: '\$');
  static final shortDate = DateFormat('dd MMM yyyy');
  static final monthLabel = DateFormat('MMM yyyy');
}
