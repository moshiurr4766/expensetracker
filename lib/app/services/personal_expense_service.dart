import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';
import '../models/category_model.dart';
import '../models/expense_model.dart';
import '../models/household_models.dart';
import '../models/income_model.dart';


class PersonalExpenseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _categoriesRef(String uid) {
    return _db
        .collection(AppConstants.personalExpenseCollection)
        .doc(uid)
        .collection(AppConstants.categoriesCollection);
  }

  CollectionReference<Map<String, dynamic>> _expensesRef(String uid) {
    return _db
        .collection(AppConstants.personalExpenseCollection)
        .doc(uid)
        .collection(AppConstants.expensesCollection);
  }

  CollectionReference<Map<String, dynamic>> _incomesRef(String uid) {
    return _db
        .collection(AppConstants.personalExpenseCollection)
        .doc(uid)
        .collection(AppConstants.incomesCollection);
  }

  CollectionReference<Map<String, dynamic>> _monthlyArchiveRef(String uid) {
    return _db
        .collection(AppConstants.personalExpenseCollection)
        .doc(uid)
        .collection(AppConstants.monthlyArchiveCollection);
  }

  Stream<List<CategoryModel>> watchCategories(String uid) {
    return _categoriesRef(uid)
        .where('type', whereIn: ['expense', 'income'])
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CategoryModel.fromMap(doc.id, doc.data()))
              .toList()
              ..sort((a, b) => a.name.compareTo(b.name)),
        );
  }

  Stream<List<ExpenseModel>> watchExpenses(String uid) {
    return _expensesRef(uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ExpenseModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<List<IncomeModel>> watchIncomes(String uid) {
    return _incomesRef(uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => IncomeModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<List<MonthlyArchiveModel>> watchMonthlyArchives(String uid) {
    return _monthlyArchiveRef(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MonthlyArchiveModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> ensureDefaultCategories(String uid) async {
    final expenseSnapshot = await _categoriesRef(uid)
        .where('type', isEqualTo: 'expense')
        .limit(1)
        .get();
    final incomeSnapshot = await _categoriesRef(uid)
        .where('type', isEqualTo: 'income')
        .limit(1)
        .get();

    if (expenseSnapshot.docs.isEmpty) {
      for (final category in AppDefaults.defaultExpenseCategories) {
        await _categoriesRef(uid).add({
          'uid': uid,
          'name': category['name'],
          'type': 'expense',
          'icon': category['icon'],
          'colorValue': category['color'],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }

    if (incomeSnapshot.docs.isEmpty) {
      for (final category in AppDefaults.defaultIncomeCategories) {
        await _categoriesRef(uid).add({
          'uid': uid,
          'name': category['name'],
          'type': 'income',
          'icon': category['icon'],
          'colorValue': category['color'],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  Future<String> addCategory({
    required String uid,
    required String name,
    required String type,
    required String icon,
    required int colorValue,
  }) async {
    final doc = await _categoriesRef(uid).add({
      'uid': uid,
      'name': name.trim(),
      'type': type,
      'icon': icon,
      'colorValue': colorValue,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<void> updateCategory({
    required String uid,
    required String id,
    required String name,
    required String icon,
    required int colorValue,
  }) {
    return _categoriesRef(uid).doc(id).update({
      'name': name.trim(),
      'icon': icon,
      'colorValue': colorValue,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteCategory({required String uid, required String id}) {
    return _categoriesRef(uid).doc(id).delete();
  }

  Future<String> addExpense({
    required String uid,
    required String title,
    required String categoryId,
    required String categoryName,
    required double amount,
    required String note,
    required DateTime date,
  }) async {
    final doc = await _expensesRef(uid).add({
      'uid': uid,
      'title': title.trim(),
      'categoryId': categoryId,
      'categoryName': categoryName,
      'amount': amount,
      'note': note.trim(),
      'date': Timestamp.fromDate(date),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<void> updateExpense({
    required String uid,
    required String id,
    required String title,
    required String categoryId,
    required String categoryName,
    required double amount,
    required String note,
    required DateTime date,
  }) {
    return _expensesRef(uid).doc(id).update({
      'title': title.trim(),
      'categoryId': categoryId,
      'categoryName': categoryName,
      'amount': amount,
      'note': note.trim(),
      'date': Timestamp.fromDate(date),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteExpense({required String uid, required String id}) {
    return _expensesRef(uid).doc(id).delete();
  }

  Future<String> addIncome({
    required String uid,
    required String categoryId,
    required String categoryName,
    required double amount,
    required String note,
    required DateTime date,
  }) async {
    final doc = await _incomesRef(uid).add({
      'uid': uid,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'amount': amount,
      'note': note.trim(),
      'date': Timestamp.fromDate(date),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<void> updateIncome({
    required String uid,
    required String id,
    required String categoryId,
    required String categoryName,
    required double amount,
    required String note,
    required DateTime date,
  }) {
    return _incomesRef(uid).doc(id).update({
      'categoryId': categoryId,
      'categoryName': categoryName,
      'amount': amount,
      'note': note.trim(),
      'date': Timestamp.fromDate(date),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteIncome({required String uid, required String id}) {
    return _incomesRef(uid).doc(id).delete();
  }

  Future<String> archiveMonthlyLedger({
    required String uid,
    required String monthKey,
    required String monthLabel,
    required List<ExpenseModel> expenses,
    required List<IncomeModel> incomes,
  }) async {
    final totalIncome = incomes.fold<double>(
      0,
      (runningTotal, item) => runningTotal + item.amount,
    );
    final totalExpense = expenses.fold<double>(
      0,
      (runningTotal, item) => runningTotal + item.amount,
    );
    final doc = await _monthlyArchiveRef(uid).add({
      'uid': uid,
      'monthKey': monthKey,
      'monthLabel': monthLabel,
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'balance': totalIncome - totalExpense,
      'incomes': incomes
          .map((item) => {
                'title': item.categoryName,
                'categoryName': item.categoryName,
                'amount': item.amount,
                'note': item.note,
                'date': Timestamp.fromDate(item.date),
              })
          .toList(),
      'expenses': expenses
          .map((item) => {
                'title': item.title,
                'categoryName': item.categoryName,
                'amount': item.amount,
                'note': item.note,
                'date': Timestamp.fromDate(item.date),
              })
          .toList(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    final batch = _db.batch();
    for (final item in incomes) {
      batch.delete(_incomesRef(uid).doc(item.id));
    }
    for (final item in expenses) {
      batch.delete(_expensesRef(uid).doc(item.id));
    }
    await batch.commit();
    return doc.id;
  }
}
