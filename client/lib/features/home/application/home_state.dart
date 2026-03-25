import '../domain/entities/monthly_balance.dart';
import '../domain/entities/month_summary.dart';
import '../domain/entities/user_profile.dart';
import '../../transaction/domain/entities/transaction.dart';

/// 首页聚合数据模型（应用层）
class HomeData {
  final MonthlyBalance balance;
  final MonthSummary summary;
  final List<Transaction> recentTransactions;
  final UserProfile userProfile;

  const HomeData({
    required this.balance,
    required this.summary,
    required this.recentTransactions,
    required this.userProfile,
  });
}
