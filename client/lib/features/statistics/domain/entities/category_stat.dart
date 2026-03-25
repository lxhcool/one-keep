import '../../../../core/money/money.dart';
import '../../../transaction/domain/entities/transaction_category.dart';

class CategoryStat {
  final TransactionCategory category;
  final Money total;
  final double percentage; // 0.0 – 1.0
  final int count;

  const CategoryStat({
    required this.category,
    required this.total,
    required this.percentage,
    required this.count,
  });
}
