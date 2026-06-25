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
      case 'fitness_center':
        return Icons.fitness_center_rounded;
      case 'flight':
        return Icons.flight_rounded;
      case 'local_gas_station':
        return Icons.local_gas_station_rounded;
      case 'local_grocery_store':
        return Icons.local_grocery_store_rounded;
      case 'local_hospital':
        return Icons.local_hospital_rounded;
      case 'movie':
        return Icons.movie_rounded;
      case 'pets':
        return Icons.pets_rounded;
      case 'train':
        return Icons.train_rounded;
      case 'water_drop':
        return Icons.water_drop_rounded;
      case 'wifi':
        return Icons.wifi_rounded;
      case 'coffee':
        return Icons.coffee_rounded;
      case 'sports_esports':
        return Icons.sports_esports_rounded;
      case 'category':
      default:
        return Icons.category_rounded;
    }
  }
}
