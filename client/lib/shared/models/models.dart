class Transaction {
  final String transactionId;
  final String title;
  final String categoryName;
  final String categoryIcon;
  final DateTime occurredAt;
  final double amount;
  final String direction;
  final String? note;
  final String? merchant;

  const Transaction({
    required this.transactionId,
    required this.title,
    required this.categoryName,
    required this.categoryIcon,
    required this.occurredAt,
    required this.amount,
    required this.direction,
    this.note,
    this.merchant,
  });

  bool get isExpense => direction == 'expense';
  bool get isIncome => direction == 'income';

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        transactionId: json['transactionId'] as String,
        title: json['title'] as String,
        categoryName: json['categoryName'] as String,
        categoryIcon: json['categoryIcon'] as String,
        occurredAt: DateTime.parse(json['occurredAt'] as String),
        amount: (json['amount'] as num).toDouble(),
        direction: json['direction'] as String,
        note: json['note'] as String?,
        merchant: json['merchant'] as String?,
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
  final String name;
  final String email;

  const UserInfo({required this.id, required this.name, required this.email});

  factory UserInfo.fromJson(Map<String, dynamic> json) => UserInfo(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
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
        totalIncome: (json['totals']['income'] as num).toDouble(),
        totalExpense: (json['totals']['expense'] as num).toDouble(),
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
        label: json['label'] as String,
        value: (json['value'] as num).toDouble(),
      );
}

class CategoryRank {
  final String categoryId;
  final String categoryName;
  final String categoryIcon;
  final double amount;
  final double progressRatio;

  const CategoryRank({
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.amount,
    required this.progressRatio,
  });

  factory CategoryRank.fromJson(Map<String, dynamic> json) => CategoryRank(
        categoryId: json['categoryId'] as String,
        categoryName: json['categoryName'] as String,
        categoryIcon: json['categoryIcon'] as String,
        amount: (json['amount'] as num).toDouble(),
        progressRatio: (json['progressRatio'] as num).toDouble(),
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
        date: json['date'] as String,
        expenseTotal: (json['summary']['expense'] as num).toDouble(),
        incomeTotal: (json['summary']['income'] as num).toDouble(),
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

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'] as String,
        name: json['name'] as String,
        icon: json['icon'] as String,
        type: json['type'] as String,
      );
}
