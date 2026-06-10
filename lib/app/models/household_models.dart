import 'package:cloud_firestore/cloud_firestore.dart';

class HouseholdPersonModel {
  final String id;
  final String uid;
  final String name;
  final double initialContribution;
  final String profileInfo;
  final DateTime createdAt;
  final DateTime updatedAt;

  const HouseholdPersonModel({
    required this.id,
    required this.uid,
    required this.name,
    required this.initialContribution,
    required this.profileInfo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HouseholdPersonModel.fromMap(String id, Map<String, dynamic> data) {
    DateTime readDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return DateTime.now();
    }

    return HouseholdPersonModel(
      id: id,
      uid: data['uid'] as String? ?? '',
      name: data['name'] as String? ?? '',
      initialContribution:
          (data['initialContribution'] as num? ?? 0).toDouble(),
      profileInfo: data['profileInfo'] as String? ?? '',
      createdAt: readDate(data['createdAt']),
      updatedAt: readDate(data['updatedAt']),
    );
  }
}

class PersonPaymentPoint {
  final String name;
  final double amount;

  const PersonPaymentPoint({required this.name, required this.amount});
}

class SettlementPersonBalance {
  final String personId;
  final String name;
  final double paidAmount;
  final double shareAmount;
  final double balanceAmount;

  const SettlementPersonBalance({
    required this.personId,
    required this.name,
    required this.paidAmount,
    required this.shareAmount,
    required this.balanceAmount,
  });
}

class SettlementTransfer {
  final String fromPerson;
  final String toPerson;
  final double amount;

  const SettlementTransfer({
    required this.fromPerson,
    required this.toPerson,
    required this.amount,
  });
}

class SettlementSummary {
  final DateTime startDate;
  final DateTime endDate;
  final double totalExpense;
  final double totalPaid;
  final double averageShare;
  final List<SettlementPersonBalance> balances;
  final List<SettlementTransfer> transfers;

  const SettlementSummary({
    required this.startDate,
    required this.endDate,
    required this.totalExpense,
    required this.totalPaid,
    required this.averageShare,
    required this.balances,
    required this.transfers,
  });
}

class SettlementHistoryModel {
  final String id;
  final String uid;
  final DateTime startDate;
  final DateTime endDate;
  final double totalExpense;
  final double totalPaid;
  final double averageShare;
  final List<SettlementPersonBalance> balances;
  final List<SettlementTransfer> transfers;
  final DateTime createdAt;

  const SettlementHistoryModel({
    required this.id,
    required this.uid,
    required this.startDate,
    required this.endDate,
    required this.totalExpense,
    required this.totalPaid,
    required this.averageShare,
    required this.balances,
    required this.transfers,
    required this.createdAt,
  });

  factory SettlementHistoryModel.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    DateTime readDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return DateTime.now();
    }

    final balancesRaw = data['balances'] as List<dynamic>? ?? const [];
    final transfersRaw = data['transfers'] as List<dynamic>? ?? const [];

    return SettlementHistoryModel(
      id: id,
      uid: data['uid'] as String? ?? '',
      startDate: readDate(data['startDate']),
      endDate: readDate(data['endDate']),
      totalExpense: (data['totalExpense'] as num? ?? 0).toDouble(),
      totalPaid: (data['totalPaid'] as num? ?? 0).toDouble(),
      averageShare: (data['averageShare'] as num? ?? 0).toDouble(),
      balances: balancesRaw
          .map(
            (item) => SettlementPersonBalance(
              personId: item['personId'] as String? ?? '',
              name: item['name'] as String? ?? '',
              paidAmount: (item['paidAmount'] as num? ?? 0).toDouble(),
              shareAmount: (item['shareAmount'] as num? ?? 0).toDouble(),
              balanceAmount: (item['balanceAmount'] as num? ?? 0).toDouble(),
            ),
          )
          .toList(),
      transfers: transfersRaw
          .map(
            (item) => SettlementTransfer(
              fromPerson: item['fromPerson'] as String? ?? '',
              toPerson: item['toPerson'] as String? ?? '',
              amount: (item['amount'] as num? ?? 0).toDouble(),
            ),
          )
          .toList(),
      createdAt: readDate(data['createdAt']),
    );
  }
}

class MonthlyArchiveModel {
  final String id;
  final String uid;
  final String monthKey;
  final String monthLabel;
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final List<Map<String, dynamic>> incomes;
  final List<Map<String, dynamic>> expenses;
  final DateTime createdAt;

  const MonthlyArchiveModel({
    required this.id,
    required this.uid,
    required this.monthKey,
    required this.monthLabel,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.incomes,
    required this.expenses,
    required this.createdAt,
  });

  factory MonthlyArchiveModel.fromMap(String id, Map<String, dynamic> data) {
    DateTime readDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return DateTime.now();
    }

    return MonthlyArchiveModel(
      id: id,
      uid: data['uid'] as String? ?? '',
      monthKey: data['monthKey'] as String? ?? '',
      monthLabel: data['monthLabel'] as String? ?? '',
      totalIncome: (data['totalIncome'] as num? ?? 0).toDouble(),
      totalExpense: (data['totalExpense'] as num? ?? 0).toDouble(),
      balance: (data['balance'] as num? ?? 0).toDouble(),
      incomes: (data['incomes'] as List<dynamic>? ?? const [])
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(),
      expenses: (data['expenses'] as List<dynamic>? ?? const [])
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(),
      createdAt: readDate(data['createdAt']),
    );
  }
}
