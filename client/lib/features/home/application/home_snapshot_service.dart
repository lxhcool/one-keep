import '../domain/home_snapshot.dart';

class HomeSnapshotService {
  const HomeSnapshotService();

  static int _idSeed = 100;

  static final Map<String, HomeSummary> _summaryStore = <String, HomeSummary>{
    '2025-07': const HomeSummary(income: '3000.00', expense: '1816.48'),
    '2025-06': const HomeSummary(income: '4520.00', expense: '2207.60'),
    '2025-05': const HomeSummary(income: '3899.00', expense: '0.00'),
  };

  static final Map<String, List<HomeDayGroup>> _dayGroupStore =
      <String, List<HomeDayGroup>>{
        '2025-07': const <HomeDayGroup>[
          HomeDayGroup(
            dateText: '07月26日 星期六',
            totalText: '支出：26.9',
            items: <HomeRecordItem>[
              HomeRecordItem(
                id: 'tx_1',
                name: '午饭',
                amount: '-12.9',
                kind: HomeRecordKind.meal,
              ),
              HomeRecordItem(
                id: 'tx_2',
                name: '早餐',
                amount: '-14',
                kind: HomeRecordKind.meal,
              ),
            ],
          ),
          HomeDayGroup(
            dateText: '07月25日 星期五',
            totalText: '支出：53',
            items: <HomeRecordItem>[
              HomeRecordItem(
                id: 'tx_3',
                name: '打车',
                amount: '-13',
                kind: HomeRecordKind.taxi,
              ),
              HomeRecordItem(
                id: 'tx_4',
                name: '午饭',
                amount: '-16',
                kind: HomeRecordKind.meal,
              ),
              HomeRecordItem(
                id: 'tx_5',
                name: '早餐',
                amount: '-8',
                kind: HomeRecordKind.meal,
              ),
              HomeRecordItem(
                id: 'tx_6',
                name: '晚餐',
                amount: '-16',
                kind: HomeRecordKind.meal,
              ),
            ],
          ),
          HomeDayGroup(
            dateText: '07月24日 星期四',
            totalText: '支出：51.07',
            items: <HomeRecordItem>[
              HomeRecordItem(
                id: 'tx_7',
                name: '果汁',
                amount: '-12',
                kind: HomeRecordKind.drink,
              ),
              HomeRecordItem(
                id: 'tx_8',
                name: '午饭',
                amount: '-17.9',
                kind: HomeRecordKind.meal,
              ),
              HomeRecordItem(
                id: 'tx_9',
                name: '晚餐',
                amount: '-16.17',
                kind: HomeRecordKind.meal,
              ),
            ],
          ),
        ],
        '2025-06': const <HomeDayGroup>[
          HomeDayGroup(
            dateText: '06月30日 星期一',
            totalText: '支出：18',
            items: <HomeRecordItem>[
              HomeRecordItem(
                id: 'tx_10',
                name: '午饭',
                amount: '-18',
                kind: HomeRecordKind.meal,
              ),
            ],
          ),
        ],
        '2025-05': const <HomeDayGroup>[],
      };

  Future<HomeSummary> fetchSummary(DateTime month) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return _summaryStore[_monthKey(month)] ??
        const HomeSummary(income: '0.00', expense: '0.00');
  }

  Future<List<HomeDayGroup>> fetchDayGroups(DateTime month) async {
    await Future<void>.delayed(const Duration(milliseconds: 420));
    return List<HomeDayGroup>.from(
      _dayGroupStore[_monthKey(month)] ?? const [],
    );
  }

  Future<void> createTransaction({
    required DateTime month,
    required String name,
    required double amount,
    required bool isIncome,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 240));

    final String key = _monthKey(month);
    final HomeSummary currentSummary =
        _summaryStore[key] ??
        const HomeSummary(income: '0.00', expense: '0.00');
    final double income = double.tryParse(currentSummary.income) ?? 0;
    final double expense = double.tryParse(currentSummary.expense) ?? 0;
    final double safeAmount = amount.abs();

    _summaryStore[key] = HomeSummary(
      income: isIncome ? _fixed2(income + safeAmount) : _fixed2(income),
      expense: isIncome ? _fixed2(expense) : _fixed2(expense + safeAmount),
    );

    final List<HomeDayGroup> groups = List<HomeDayGroup>.from(
      _dayGroupStore[key] ?? const [],
    );

    final HomeRecordItem newItem = HomeRecordItem(
      id: 'tx_${_idSeed++}',
      name: name,
      amount: '${isIncome ? '+' : '-'}${_trimAmount(safeAmount)}',
      kind: _guessKind(name, isIncome),
    );

    if (groups.isEmpty) {
      final String monthText = month.month.toString().padLeft(2, '0');
      groups.add(
        HomeDayGroup(
          dateText: '$monthText月01日 星期一',
          totalText: '支出：${isIncome ? '0' : _trimAmount(safeAmount)}',
          items: <HomeRecordItem>[newItem],
        ),
      );
    } else {
      final HomeDayGroup first = groups.first;
      final List<HomeRecordItem> items = <HomeRecordItem>[
        newItem,
        ...first.items,
      ];
      final double currentDayExpense = _parseExpense(first.totalText);
      final double nextDayExpense = isIncome
          ? currentDayExpense
          : currentDayExpense + safeAmount;
      groups[0] = HomeDayGroup(
        dateText: first.dateText,
        totalText: '支出：${_trimAmount(nextDayExpense)}',
        items: items,
      );
    }

    _dayGroupStore[key] = groups;
  }

  HomeRecordKind _guessKind(String name, bool isIncome) {
    if (isIncome) {
      return HomeRecordKind.drink;
    }
    if (name.contains('车')) {
      return HomeRecordKind.taxi;
    }
    if (name.contains('汁') || name.contains('饮')) {
      return HomeRecordKind.drink;
    }
    return HomeRecordKind.meal;
  }

  double _parseExpense(String totalText) {
    final String normalized = totalText.replaceFirst('支出：', '');
    return double.tryParse(normalized) ?? 0;
  }

  String _fixed2(double value) => value.toStringAsFixed(2);

  String _trimAmount(double value) {
    final String fixed = value.toStringAsFixed(2);
    return fixed
        .replaceFirst(RegExp(r'\.00$'), '')
        .replaceFirst(RegExp(r'0$'), '');
  }

  String _monthKey(DateTime month) {
    final String monthText = month.month.toString().padLeft(2, '0');
    return '${month.year}-$monthText';
  }
}
