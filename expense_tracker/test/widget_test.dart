import 'package:flutter_test/flutter_test.dart';

import 'package:expense_tracker/app/constants/app_constants.dart';

void main() {
  test('app name is configured', () {
    expect(AppConstants.appName, 'Expense Tracker');
  });
}
