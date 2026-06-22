import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';
import '../models/category_model.dart';
import '../models/expense_model.dart';
import '../models/household_models.dart';

class SharedExpenseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _categoriesRef(String uid) {
    return _db
        .collection(AppConstants.sharedExpenseCollection)
        .doc(uid)
        .collection(AppConstants.categoriesCollection);
  }

  CollectionReference<Map<String, dynamic>> _sharedExpensesRef(String uid) {
    return _db
        .collection(AppConstants.sharedExpenseCollection)
        .doc(uid)
        .collection(AppConstants.sharedExpensesCollection);
  }

  CollectionReference<Map<String, dynamic>> _peopleRef(String uid) {
    return _db
        .collection(AppConstants.sharedExpenseCollection)
        .doc(uid)
        .collection(AppConstants.peopleCollection);
  }

  CollectionReference<Map<String, dynamic>> _settlementHistoryRef(String uid) {
    return _db
        .collection(AppConstants.sharedExpenseCollection)
        .doc(uid)
        .collection(AppConstants.settlementHistoryCollection);
  }

  Stream<List<CategoryModel>> watchCategories(String uid) {
    return _categoriesRef(uid)
        .where('type', isEqualTo: 'shared')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CategoryModel.fromMap(doc.id, doc.data()))
              .toList()
              ..sort((a, b) => a.name.compareTo(b.name)),
        );
  }

  Stream<List<SharedExpenseModel>> watchSharedExpenses(String uid) {
    return _sharedExpensesRef(uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SharedExpenseModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<List<HouseholdPersonModel>> watchPeople(String uid) {
    return _peopleRef(uid)
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => HouseholdPersonModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<List<SettlementHistoryModel>> watchSettlementHistory(String uid) {
    return _settlementHistoryRef(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SettlementHistoryModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> ensureDefaultCategories(String uid) async {
    final sharedSnapshot = await _categoriesRef(uid)
        .where('type', isEqualTo: 'shared')
        .limit(1)
        .get();
        
    if (sharedSnapshot.docs.isEmpty) {
      for (final category in AppDefaults.defaultSharedCategories) {
        await _categoriesRef(uid).add({
          'uid': uid,
          'name': category['name'],
          'type': 'shared',
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

  Future<String> addSharedExpense({
    required String uid,
    required String title,
    required String categoryId,
    required String categoryName,
    required String paidByPersonId,
    required String paidByPersonName,
    required double amount,
    required String note,
    required DateTime date,
  }) async {
    final doc = await _sharedExpensesRef(uid).add({
      'uid': uid,
      'title': title.trim(),
      'categoryId': categoryId,
      'categoryName': categoryName,
      'paidByPersonId': paidByPersonId,
      'paidByPersonName': paidByPersonName,
      'amount': amount,
      'note': note.trim(),
      'date': Timestamp.fromDate(date),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<void> updateSharedExpense({
    required String uid,
    required String id,
    required String title,
    required String categoryId,
    required String categoryName,
    required String paidByPersonId,
    required String paidByPersonName,
    required double amount,
    required String note,
    required DateTime date,
  }) {
    return _sharedExpensesRef(uid).doc(id).update({
      'title': title.trim(),
      'categoryId': categoryId,
      'categoryName': categoryName,
      'paidByPersonId': paidByPersonId,
      'paidByPersonName': paidByPersonName,
      'amount': amount,
      'note': note.trim(),
      'date': Timestamp.fromDate(date),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteSharedExpense({required String uid, required String id}) {
    return _sharedExpensesRef(uid).doc(id).delete();
  }

  Future<String> addPerson({
    required String uid,
    required String name,
    required double initialContribution,
    required String profileInfo,
  }) async {
    final doc = await _peopleRef(uid).add({
      'uid': uid,
      'name': name.trim(),
      'initialContribution': initialContribution,
      'profileInfo': profileInfo.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<void> updatePerson({
    required String uid,
    required String id,
    required String name,
    required double initialContribution,
    required String profileInfo,
  }) {
    return _peopleRef(uid).doc(id).update({
      'name': name.trim(),
      'initialContribution': initialContribution,
      'profileInfo': profileInfo.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deletePerson({required String uid, required String id}) {
    return _peopleRef(uid).doc(id).delete();
  }

  Future<String> addSettlementHistory({
    required String uid,
    required SettlementSummary summary,
  }) async {
    final doc = await _settlementHistoryRef(uid).add({
      'uid': uid,
      'startDate': Timestamp.fromDate(summary.startDate),
      'endDate': Timestamp.fromDate(summary.endDate),
      'totalExpense': summary.totalExpense,
      'totalPaid': summary.totalPaid,
      'averageShare': summary.averageShare,
      'balances': summary.balances
          .map((item) => {
                'personId': item.personId,
                'name': item.name,
                'paidAmount': item.paidAmount,
                'shareAmount': item.shareAmount,
                'balanceAmount': item.balanceAmount,
              })
          .toList(),
      'transfers': summary.transfers
          .map((item) => {
                'fromPerson': item.fromPerson,
                'toPerson': item.toPerson,
                'amount': item.amount,
              })
          .toList(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }
}
