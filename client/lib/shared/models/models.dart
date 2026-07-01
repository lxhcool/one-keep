String _readString(
  Map<String, dynamic> json,
  String key, {
  String fallback = '',
}) {
  final value = json[key];
  if (value == null) return fallback;
  return value.toString();
}

String? _readNullableString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  final text = value.toString();
  return text.isEmpty ? null : text;
}

double _readDouble(
  Map<String, dynamic> json,
  String key, {
  double fallback = 0,
}) {
  final value = json[key];
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

class Transaction {
  final String transactionId;
  final String categoryId;
  final String title;
  final String categoryName;
  final String categoryIcon;
  final String? categoryColor;
  final DateTime occurredAt;
  final double amount;
  final String direction;
  final String? note;
  final String? merchant;

  const Transaction({
    required this.transactionId,
    required this.categoryId,
    required this.title,
    required this.categoryName,
    required this.categoryIcon,
    this.categoryColor,
    required this.occurredAt,
    required this.amount,
    required this.direction,
    this.note,
    this.merchant,
  });

  bool get isExpense => direction == 'expense';
  bool get isIncome => direction == 'income';

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    transactionId: _readString(json, 'transactionId'),
    categoryId: _readString(json, 'categoryId'),
    title: _readString(json, 'title', fallback: '未命名交易'),
    categoryName: _readString(json, 'categoryName', fallback: '未分类'),
    categoryIcon: _readString(json, 'categoryIcon', fallback: 'receipt_long'),
    categoryColor:
        _readNullableString(json, 'categoryColor') ??
        _readNullableString(json, 'color'),
    occurredAt:
        (DateTime.tryParse(_readString(json, 'occurredAt')) ?? DateTime.now()).toLocal(),
    amount: _readDouble(json, 'amount'),
    direction: _readString(json, 'direction', fallback: 'expense'),
    note: _readNullableString(json, 'note'),
    merchant: _readNullableString(json, 'merchant'),
  );
}

class HomeSummary {
  final UserInfo user;
  final double balance;
  final double income;
  final double expense;
  final List<Transaction> recentTransactions;

  const HomeSummary({
    required this.user,
    required this.balance,
    required this.income,
    required this.expense,
    required this.recentTransactions,
  });

  factory HomeSummary.fromJson(Map<String, dynamic> json) => HomeSummary(
    user: UserInfo.fromJson(json['user'] as Map<String, dynamic>),
    balance: (json['balanceSummary']['amount'] as num).toDouble(),
    income: (json['incomeSummary']['amount'] as num).toDouble(),
    expense: (json['expenseSummary']['amount'] as num).toDouble(),
    recentTransactions: (json['recentTransactions'] as List)
        .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

class UserInfo {
  final String id;
  final String? username;
  final String name;
  final String email;

  const UserInfo({
    required this.id,
    this.username,
    required this.name,
    required this.email,
  });

  UserInfo copyWith({
    String? id,
    String? username,
    String? name,
    String? email,
  }) {
    return UserInfo(
      id: id ?? this.id,
      username: username ?? this.username,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }

  factory UserInfo.fromJson(Map<String, dynamic> json) => UserInfo(
    id: _readString(json, 'id'),
    username: _readNullableString(json, 'username'),
    name: _readString(
      json,
      'displayName',
      fallback: _readString(json, 'name', fallback: '厘清用户'),
    ),
    email: _readString(json, 'email'),
  );
}

class StatsOverview {
  final double totalIncome;
  final double totalExpense;
  final List<TrendPoint> trendSeries;
  final List<CategoryRank> categoryRanks;

  const StatsOverview({
    required this.totalIncome,
    required this.totalExpense,
    required this.trendSeries,
    required this.categoryRanks,
  });

  factory StatsOverview.fromJson(Map<String, dynamic> json) => StatsOverview(
    totalIncome: _readDouble(json['totals'] as Map<String, dynamic>, 'income'),
    totalExpense: _readDouble(
      json['totals'] as Map<String, dynamic>,
      'expense',
    ),
    trendSeries: (json['trendSeries'] as List)
        .map((e) => TrendPoint.fromJson(e as Map<String, dynamic>))
        .toList(),
    categoryRanks: (json['categoryRanks'] as List)
        .map((e) => CategoryRank.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

class TrendPoint {
  final String label;
  final double value;

  const TrendPoint({required this.label, required this.value});

  factory TrendPoint.fromJson(Map<String, dynamic> json) => TrendPoint(
    label: _readString(json, 'label'),
    value: _readDouble(json, 'value'),
  );
}

class CategoryRank {
  final String categoryId;
  final String categoryName;
  final String categoryIcon;
  final String? categoryColor;
  final double amount;
  final double progressRatio;

  const CategoryRank({
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    this.categoryColor,
    required this.amount,
    required this.progressRatio,
  });

  factory CategoryRank.fromJson(Map<String, dynamic> json) => CategoryRank(
    categoryId: _readString(json, 'categoryId'),
    categoryName: _readString(json, 'categoryName', fallback: '未分类'),
    categoryIcon: _readString(json, 'categoryIcon', fallback: 'receipt_long'),
    categoryColor:
        _readNullableString(json, 'categoryColor') ??
        _readNullableString(json, 'color'),
    amount: _readDouble(json, 'amount'),
    progressRatio: _readDouble(json, 'progressRatio'),
  );
}

class BillGroup {
  final String date;
  final double expenseTotal;
  final double incomeTotal;
  final List<Transaction> items;

  const BillGroup({
    required this.date,
    required this.expenseTotal,
    required this.incomeTotal,
    required this.items,
  });

  factory BillGroup.fromJson(Map<String, dynamic> json) => BillGroup(
    date: _readString(json, 'date'),
    expenseTotal: _readDouble(
      json['summary'] as Map<String, dynamic>,
      'expense',
    ),
    incomeTotal: _readDouble(json['summary'] as Map<String, dynamic>, 'income'),
    items: (json['items'] as List)
        .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

class BillsResponse {
  final List<BillGroup> groupedBills;
  final String? nextCursor;

  const BillsResponse({required this.groupedBills, this.nextCursor});

  factory BillsResponse.fromJson(Map<String, dynamic> json) => BillsResponse(
    groupedBills: (json['groupedBills'] as List)
        .map((e) => BillGroup.fromJson(e as Map<String, dynamic>))
        .toList(),
    nextCursor: json['nextCursor'] as String?,
  );
}

class Category {
  final String id;
  final String name;
  final String icon;
  final String type;
  final String? color;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
    this.color,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: _readString(json, 'id'),
    name: _readString(json, 'name', fallback: '未分类'),
    icon: _readString(json, 'icon', fallback: 'receipt_long'),
    type: _readString(json, 'type', fallback: 'expense'),
    color:
        _readNullableString(json, 'color') ??
        _readNullableString(json, 'categoryColor'),
  );
}
