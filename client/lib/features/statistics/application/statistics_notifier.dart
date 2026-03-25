import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/money/money.dart';
import '../../transaction/domain/entities/transaction_category.dart';
import '../domain/entities/category_stat.dart';

class StatisticsData {
  final int year;
  final int month;
  final Money totalIncome;
  final Money totalExpense;
  final List<CategoryStat> expenseStats;
  final List<CategoryStat> incomeStats;

  const StatisticsData({
    required this.year,
    required this.month,
    required this.totalIncome,
    required this.totalExpense,
    required this.expenseStats,
    required this.incomeStats,
  });
}

class StatisticsNotifier extends AsyncNotifier<StatisticsData> {
  late int _year;
  late int _month;

  @override
  Future<StatisticsData> build() {
    final now = DateTime.now();
    _year = now.year;
    _month = now.month;
    return _load();
  }

  Future<StatisticsData> _load() async {
    await Future.delayed(const Duration(milliseconds: 600));
    const totalExpenseCents = 420900;
    return StatisticsData(
      year: _year,
      month: _month,
      totalIncome: const Money(amountCents: 1245000),
      totalExpense: const Money(amountCents: totalExpenseCents),
      expenseStats: const [
        CategoryStat(
          category: TransactionCategory.shopping,
          total: Money(amountCents: 209900),
          percentage: 209900 / totalExpenseCents,
          count: 1,
        ),
        CategoryStat(
          category: TransactionCategory.food,
          total: Money(amountCents: 120000),
          percentage: 120000 / totalExpenseCents,
          count: 4,
        ),
        CategoryStat(
          category: TransactionCategory.transport,
          total: Money(amountCents: 45000),
          percentage: 45000 / totalExpenseCents,
          count: 3,
        ),
        CategoryStat(
          category: TransactionCategory.other,
          total: Money(amountCents: 46000),
          percentage: 46000 / totalExpenseCents,
          count: 2,
        ),
      ],
      incomeStats: const [
        CategoryStat(
          category: TransactionCategory.salary,
          total: Money(amountCents: 1245000),
          percentage: 1.0,
          count: 1,
        ),
      ],
    );
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

  bool get canGoNext {
    final now = DateTime.now();
    return _year < now.year || (_year == now.year && _month < now.month);
  }
}

final statisticsNotifierProvider =
    AsyncNotifierProvider<StatisticsNotifier, StatisticsData>(
  StatisticsNotifier.new,
);
