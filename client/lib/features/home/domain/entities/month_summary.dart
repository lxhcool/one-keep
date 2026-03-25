import '../../../../core/money/money.dart';

class MonthSummary {
  final Money totalIncome;
  final Money totalExpense;

  const MonthSummary({
    required this.totalIncome,
    required this.totalExpense,
  });
}
