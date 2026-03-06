class HomeSummary {
  const HomeSummary({required this.income, required this.expense});

  final String income;
  final String expense;
}

enum HomeRecordKind { meal, taxi, drink }

class HomeRecordItem {
  const HomeRecordItem({
    required this.id,
    required this.name,
    required this.amount,
    required this.kind,
  });

  final String id;
  final String name;
  final String amount;
  final HomeRecordKind kind;
}

class HomeDayGroup {
  const HomeDayGroup({
    required this.dateText,
    required this.totalText,
    required this.items,
  });

  final String dateText;
  final String totalText;
  final List<HomeRecordItem> items;
}
