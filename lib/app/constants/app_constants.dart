class AppConstants {
  static const appName = 'Expense Tracker';
  static const storageBox = 'expense_tracker_storage';
  static const keyOnboardingSeen = 'onboarding_seen';
  static const keySessionUid = 'session_uid';
  static const keySessionEmail = 'session_email';
  static const keySessionName = 'session_name';
  static const keyLastArchivedMonth = 'last_archived_month';

  static const userInfoCollection = 'userInfo';
  static const invitesCollection = 'invites';
  static const personalExpenseCollection = 'personalExpense';
  static const sharedExpenseCollection = 'sharedExpense';

  // Subcollections for personalExpense
  static const expensesCollection = 'expenses';
  static const incomesCollection = 'incomes';
  static const categoriesCollection = 'categories';
  static const monthlyArchiveCollection = 'monthly_history';

  // Subcollections for sharedExpense
  static const sharedExpensesCollection = 'shared_expenses';
  static const peopleCollection = 'people';
  static const settlementHistoryCollection = 'settlement_history';
}

class Routes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const signIn = '/sign-in';
  static const signUp = '/sign-up';
  static const dashboard = '/dashboard';
}

class AppDefaults {
  static const onboardingPages = [
    (
      title: 'Track money clearly',
      description:
          'Record income and expenses in one place with a simple flow.',
      icon: 'balance',
    ),
    (
      title: 'See the numbers',
      description:
          'Review balance, category trends, and monthly movement at a glance.',
      icon: 'analytics',
    ),
    (
      title: 'Stay signed in',
      description:
          'Use your Firebase account and return to the dashboard faster.',
      icon: 'lock',
    ),
  ];

  static const defaultExpenseCategories = [
    {'name': 'Food', 'icon': 'restaurant', 'color': 0xFFE57373},
    {'name': 'Transport', 'icon': 'directions_car', 'color': 0xFF64B5F6},
    {'name': 'Bills', 'icon': 'receipt_long', 'color': 0xFFFFB74D},
    {'name': 'Shopping', 'icon': 'shopping_bag', 'color': 0xFFBA68C8},
    {'name': 'Health', 'icon': 'favorite', 'color': 0xFF4DB6AC},
  ];

  static const defaultIncomeCategories = [
    {'name': 'Salary', 'icon': 'work', 'color': 0xFF81C784},
    {'name': 'Freelance', 'icon': 'laptop', 'color': 0xFF4FC3F7},
    {'name': 'Bonus', 'icon': 'card_giftcard', 'color': 0xFF9575CD},
    {'name': 'Investment', 'icon': 'trending_up', 'color': 0xFFFFB74D},
  ];

  static const defaultSharedCategories = [
    {'name': 'Rent', 'icon': 'home', 'color': 0xFF60A5FA},
    {'name': 'Internet', 'icon': 'laptop', 'color': 0xFF34D399},
    {'name': 'Electricity', 'icon': 'receipt_long', 'color': 0xFFFBBF24},
    {'name': 'Gas', 'icon': 'directions_car', 'color': 0xFFF97316},
    {'name': 'Others', 'icon': 'category', 'color': 0xFF94A3B8},
  ];
}
