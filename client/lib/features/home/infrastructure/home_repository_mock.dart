import '../../../core/money/money.dart';
import '../domain/entities/monthly_balance.dart';
import '../domain/entities/month_summary.dart';
import '../domain/entities/user_profile.dart';
import '../domain/repositories/home_repository.dart';
import '../../transaction/domain/entities/transaction.dart';
import '../../transaction/domain/entities/transaction_category.dart';

/// Mock 实现，模拟网络延迟返回设计稿中的示例数据
class HomeRepositoryMock implements HomeRepository {
  @override
  Future<MonthlyBalance> fetchMonthlyBalance({bool forceRefresh = false}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return const MonthlyBalance(
      amount: Money(amountCents: 824050),
      changePercent: 12,
      isIncrease: true,
    );
  }

  @override
  Future<MonthSummary> fetchMonthSummary({bool forceRefresh = false}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return const MonthSummary(
      totalIncome: Money(amountCents: 1245000),
      totalExpense: Money(amountCents: 420900),
    );
  }

  @override
  Future<List<Transaction>> fetchRecentTransactions({
    int limit = 5,
    bool forceRefresh = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    return [
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
        occurredAt: yesterday,
      ),
    ];
  }

  @override
  Future<UserProfile> fetchUserProfile() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const UserProfile(id: 'user_001', displayName: 'Alex Johnson');
  }
}
