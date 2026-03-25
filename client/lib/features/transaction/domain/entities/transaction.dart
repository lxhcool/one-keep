import '../../../../core/money/money.dart';
import 'transaction_category.dart';

enum TransactionType { income, expense }

class Transaction {
  final String id;
  final TransactionType type;
  final TransactionCategory category;
  final Money amount; // 始终为正数
  final String title;
  final DateTime occurredAt;

  const Transaction({
    required this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.title,
    required this.occurredAt,
  });

  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;

  /// 返回带符号的金额字符串，例如 -32.50 / +12,450.00（不含 ¥）
  String get formattedAmount {
    final sign = isIncome ? '+' : '-';
    return '$sign${amount.formatRaw()}';
  }
}
