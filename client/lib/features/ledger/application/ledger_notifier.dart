import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/money/money.dart';
import '../../transaction/domain/entities/transaction.dart';
import '../../transaction/domain/entities/transaction_category.dart';

enum TransactionFilter { all, income, expense }

class LedgerData {
  final int year;
  final int month;
  final Money totalIncome;
  final Money totalExpense;
  final List<Transaction> transactions;
  final TransactionFilter filter;

  const LedgerData({
    required this.year,
    required this.month,
    required this.totalIncome,
    required this.totalExpense,
    required this.transactions,
    required this.filter,
  });

  LedgerData copyWith({
    TransactionFilter? filter,
    List<Transaction>? transactions,
  }) {
    return LedgerData(
      year: year,
      month: month,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      transactions: transactions ?? this.transactions,
      filter: filter ?? this.filter,
    );
  }
}

class LedgerNotifier extends AsyncNotifier<LedgerData> {
  late int _year;
  late int _month;
  TransactionFilter _filter = TransactionFilter.all;

  @override
  Future<LedgerData> build() {
    final now = DateTime.now();
    _year = now.year;
    _month = now.month;
    return _load();
  }

  Future<LedgerData> _load() async {
    await Future.delayed(const Duration(milliseconds: 700));
    final now = DateTime.now();
    final all = _mockTransactions(now);
    return LedgerData(
      year: _year,
      month: _month,
      totalIncome: const Money(amountCents: 1445000),
      totalExpense: const Money(amountCents: 420900),
      transactions: _applyFilter(all, _filter),
      filter: _filter,
    );
  }

  List<Transaction> _mockTransactions(DateTime now) => [
        Transaction(
          id: 'txn_001',
          type: TransactionType.expense,
          category: TransactionCategory.food,
          amount: const Money(amountCents: 3250),
          title: '全家便利店',
          occurredAt: now,
        ),
        Transaction(
          id: 'txn_002',
          type: TransactionType.expense,
          category: TransactionCategory.transport,
          amount: const Money(amountCents: 4500),
          title: '滴滴出行',
          occurredAt: now,
        ),
        Transaction(
          id: 'txn_003',
          type: TransactionType.income,
          category: TransactionCategory.salary,
          amount: const Money(amountCents: 1245000),
          title: '工资收入',
          occurredAt: now,
        ),
        Transaction(
          id: 'txn_004',
          type: TransactionType.expense,
          category: TransactionCategory.shopping,
          amount: const Money(amountCents: 29900),
          title: '优衣库',
          occurredAt: now.subtract(const Duration(days: 1)),
        ),
        Transaction(
          id: 'txn_005',
          type: TransactionType.expense,
          category: TransactionCategory.food,
          amount: const Money(amountCents: 4200),
          title: '星巴克',
          occurredAt: now.subtract(const Duration(days: 3)),
        ),
        Transaction(
          id: 'txn_006',
          type: TransactionType.expense,
          category: TransactionCategory.transport,
          amount: const Money(amountCents: 500),
          title: '地铁出行',
          occurredAt: now.subtract(const Duration(days: 5)),
        ),
        Transaction(
          id: 'txn_007',
          type: TransactionType.expense,
          category: TransactionCategory.food,
          amount: const Money(amountCents: 6850),
          title: '外卖美食',
          occurredAt: now.subtract(const Duration(days: 7)),
        ),
        Transaction(
          id: 'txn_008',
          type: TransactionType.income,
          category: TransactionCategory.other,
          amount: const Money(amountCents: 200000),
          title: '年终奖金',
          occurredAt: now.subtract(const Duration(days: 10)),
        ),
        Transaction(
          id: 'txn_009',
          type: TransactionType.expense,
          category: TransactionCategory.shopping,
          amount: const Money(amountCents: 18000),
          title: '京东购物',
          occurredAt: now.subtract(const Duration(days: 12)),
        ),
        Transaction(
          id: 'txn_010',
          type: TransactionType.expense,
          category: TransactionCategory.other,
          amount: const Money(amountCents: 4600),
          title: '理发',
          occurredAt: now.subtract(const Duration(days: 15)),
        ),
      ];

  List<Transaction> _applyFilter(
    List<Transaction> all,
    TransactionFilter filter,
  ) {
    switch (filter) {
      case TransactionFilter.income:
        return all.where((t) => t.isIncome).toList();
      case TransactionFilter.expense:
        return all.where((t) => t.isExpense).toList();
      case TransactionFilter.all:
        return all;
    }
  }

  Future<void> previousMonth() async {
    if (_month == 1) {
      _year--;
      _month = 12;
    } else {
      _month--;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> nextMonth() async {
    if (_month == 12) {
      _year++;
      _month = 1;
    } else {
      _month++;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  void setFilter(TransactionFilter filter) {
    _filter = filter;
    final current = state.value;
    if (current == null) return;
    final now = DateTime.now();
    final all = _mockTransactions(now);
    state = AsyncData(
      current.copyWith(filter: filter, transactions: _applyFilter(all, filter)),
    );
  }

  bool get canGoNext {
    final now = DateTime.now();
    return _year < now.year || (_year == now.year && _month < now.month);
  }
}

final ledgerNotifierProvider =
    AsyncNotifierProvider<LedgerNotifier, LedgerData>(LedgerNotifier.new);
