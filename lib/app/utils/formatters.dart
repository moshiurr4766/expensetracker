import 'package:intl/intl.dart';

import 'package:get/get.dart';
import '../services/currency_service.dart';

class AppFormatters {
  static NumberFormat get currency => Get.find<CurrencyService>().currencyFormat;
  static final shortDate = DateFormat('dd MMM yyyy');
  static final monthLabel = DateFormat('MMM yyyy');
}
