import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../network/api_client.dart';
import '../../shared/models/models.dart';
import 'api_provider.dart';

// ============ Home ============

class HomeState {
  final HomeSummary? summary;
  final bool isLoading;
  final String? error;

  const HomeState({this.summary, this.isLoading = false, this.error});
}

class HomeNotifier extends StateNotifier<HomeState> {
  final ApiClient _api;

  HomeNotifier(this._api) : super(const HomeState());

  Future<void> load([String? month]) async {
    state = HomeState(isLoading: true);
    try {
      final m = month ?? DateFormat('yyyy-MM').format(DateTime.now());
      final res = await _api.dio.get('/api/home/summary', queryParameters: {'month': m});
      state = HomeState(summary: HomeSummary.fromJson(res.data as Map<String, dynamic>));
    } catch (e) {
      state = HomeState(error: '加载失败');
    }
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier(ref.read(apiClientProvider));
});

// ============ Stats ============

class StatsState {
  final StatsOverview? overview;
  final bool isLoading;
  final String? error;

  const StatsState({this.overview, this.isLoading = false, this.error});
}

class StatsNotifier extends StateNotifier<StatsState> {
  final ApiClient _api;

  StatsNotifier(this._api) : super(const StatsState());

  Future<void> load({String? month, String metricType = 'expense'}) async {
    state = StatsState(isLoading: true);
    try {
      final m = month ?? DateFormat('yyyy-MM').format(DateTime.now());
      final res = await _api.dio.get('/api/stats/overview', queryParameters: {
        'month': m,
        'metricType': metricType,
      });
      state = StatsState(overview: StatsOverview.fromJson(res.data as Map<String, dynamic>));
    } catch (e) {
      state = StatsState(error: '加载失败');
    }
  }
}

final statsProvider = StateNotifierProvider<StatsNotifier, StatsState>((ref) {
  return StatsNotifier(ref.read(apiClientProvider));
});

// ============ Bills ============

class BillsState {
  final List<BillGroup> groups;
  final bool isLoading;
  final bool hasMore;
  final String? nextCursor;
  final String? error;

  const BillsState({
    this.groups = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.nextCursor,
    this.error,
  });
}

class BillsNotifier extends StateNotifier<BillsState> {
  final ApiClient _api;

  BillsNotifier(this._api) : super(const BillsState());

  Future<void> load({
    String? month,
    String filterType = 'all',
    String? query,
  }) async {
    state = const BillsState(isLoading: true);
    try {
      final m = month ?? DateFormat('yyyy-MM').format(DateTime.now());
      final res = await _api.dio.get('/api/bills', queryParameters: {
        'month': m,
        'filterType': filterType,
        if (query != null && query.isNotEmpty) 'query': query,
      });
      final data = BillsResponse.fromJson(res.data as Map<String, dynamic>);
      state = BillsState(
        groups: data.groupedBills,
        hasMore: data.nextCursor != null,
        nextCursor: data.nextCursor,
      );
    } catch (e) {
      state = BillsState(error: '加载失败');
    }
  }

  Future<void> loadMore({
    String? month,
    String filterType = 'all',
    String? query,
  }) async {
    if (state.isLoading || !state.hasMore) return;
    state = BillsState(
      groups: state.groups,
      isLoading: true,
      hasMore: state.hasMore,
      nextCursor: state.nextCursor,
    );
    try {
      final m = month ?? DateFormat('yyyy-MM').format(DateTime.now());
      final res = await _api.dio.get('/api/bills', queryParameters: {
        'month': m,
        'filterType': filterType,
        if (query != null && query.isNotEmpty) 'query': query,
        if (state.nextCursor != null) 'cursor': state.nextCursor,
      });
      final data = BillsResponse.fromJson(res.data as Map<String, dynamic>);
      final merged = [...state.groups];
      for (final g in data.groupedBills) {
        final idx = merged.indexWhere((e) => e.date == g.date);
        if (idx >= 0) {
          merged[idx] = BillGroup(
            date: g.date,
            expenseTotal: g.expenseTotal,
            incomeTotal: g.incomeTotal,
            items: [...merged[idx].items, ...g.items],
          );
        } else {
          merged.add(g);
        }
      }
      state = BillsState(
        groups: merged,
        hasMore: data.nextCursor != null,
        nextCursor: data.nextCursor,
      );
    } catch (e) {
      state = BillsState(
        groups: state.groups,
        error: '加载更多失败',
        hasMore: state.hasMore,
        nextCursor: state.nextCursor,
      );
    }
  }
}

final billsProvider = StateNotifierProvider<BillsNotifier, BillsState>((ref) {
  return BillsNotifier(ref.read(apiClientProvider));
});

// ============ Categories ============

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final api = ref.read(apiClientProvider);
  final res = await api.dio.get('/api/categories');
  return (res.data['categories'] as List)
      .map((e) => Category.fromJson(e as Map<String, dynamic>))
      .toList();
});
