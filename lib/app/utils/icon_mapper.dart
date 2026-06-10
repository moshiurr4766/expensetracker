import 'package:flutter/material.dart';

class AppIconMapper {
  static IconData byName(String name) {
    switch (name) {
      case 'balance':
        return Icons.account_balance_wallet_rounded;
      case 'analytics':
        return Icons.analytics_rounded;
      case 'lock':
        return Icons.lock_rounded;
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'directions_car':
        return Icons.directions_car_rounded;
      case 'receipt_long':
        return Icons.receipt_long_rounded;
      case 'shopping_bag':
        return Icons.shopping_bag_rounded;
      case 'favorite':
        return Icons.favorite_rounded;
      case 'work':
        return Icons.work_rounded;
      case 'laptop':
        return Icons.laptop_rounded;
      case 'trending_up':
        return Icons.trending_up_rounded;
      case 'card_giftcard':
        return Icons.card_giftcard_rounded;
      case 'home':
        return Icons.home_rounded;
      case 'school':
        return Icons.school_rounded;
      case 'category':
      default:
        return Icons.category_rounded;
    }
  }
}
