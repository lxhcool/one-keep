import '../entities/monthly_balance.dart';
import '../entities/month_summary.dart';
import '../entities/user_profile.dart';
import '../../../transaction/domain/entities/transaction.dart';

abstract interface class HomeRepository {
  Future<MonthlyBalance> fetchMonthlyBalance({bool forceRefresh = false});
  Future<MonthSummary> fetchMonthSummary({bool forceRefresh = false});
  Future<List<Transaction>> fetchRecentTransactions({
    int limit = 5,
    bool forceRefresh = false,
  });
  Future<UserProfile> fetchUserProfile();
}
