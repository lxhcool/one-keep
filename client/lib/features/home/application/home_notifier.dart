import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_state.dart';
import '../domain/repositories/home_repository.dart';
import '../infrastructure/home_repository_mock.dart';

final homeRepositoryProvider = Provider<HomeRepository>(
  (ref) => HomeRepositoryMock(),
);

class HomeNotifier extends AsyncNotifier<HomeData> {
  @override
  Future<HomeData> build() => _load();

  Future<HomeData> _load() async {
    final repo = ref.read(homeRepositoryProvider);
    // 并行请求四个接口
    final balance = repo.fetchMonthlyBalance();
    final summary = repo.fetchMonthSummary();
    final transactions = repo.fetchRecentTransactions();
    final userProfile = repo.fetchUserProfile();
    return HomeData(
      balance: await balance,
      summary: await summary,
      recentTransactions: await transactions,
      userProfile: await userProfile,
    );
  }

  /// 下拉刷新：重新加载（显示加载态）
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  /// 静默刷新：不重置到 Loading，直接更新数据（记账后调用）
  Future<void> silentRefresh() async {
    final newData = await AsyncValue.guard(_load);
    if (newData is AsyncData) state = newData;
  }
}

final homeNotifierProvider = AsyncNotifierProvider<HomeNotifier, HomeData>(
  HomeNotifier.new,
);
