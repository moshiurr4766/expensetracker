import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

class CurrencyService extends GetxService {
  String get symbol => '৳';
  
  NumberFormat get currencyFormat => NumberFormat.currency(symbol: symbol, decimalDigits: 2);
}
