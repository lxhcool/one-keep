import '../../../../core/money/money.dart';

class MonthlyBalance {
  final Money amount;
  final double? changePercent; // null 表示新用户无历史数据
  final bool isIncrease;

  const MonthlyBalance({
    required this.amount,
    this.changePercent,
    this.isIncrease = true,
  });

  bool get hasChangeData => changePercent != null;

  String? get formattedChange {
    if (changePercent == null) return null;
    final sign = isIncrease ? '+' : '-';
    return '$sign${changePercent!.abs().toStringAsFixed(0)}%';
  }
}
