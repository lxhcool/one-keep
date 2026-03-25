class Money {
  final int amountCents;
  final String currency;

  const Money({required this.amountCents, this.currency = 'CNY'});

  double get amount => amountCents / 100;

  bool get isPositive => amountCents > 0;
  bool get isNegative => amountCents < 0;
  bool get isZero => amountCents == 0;

  /// 格式化为 ¥#,###.## 形式（例如 ¥8,240.50）
  String format({int decimals = 2}) {
    final absAmount = amountCents.abs() / 100.0;
    final sign = amountCents < 0 ? '-' : '';
    return '¥$sign${_formatNumber(absAmount, decimals)}';
  }

  /// 格式化为 ¥#,### 形式（整数，例如 ¥12,450）
  String formatWhole() => format(decimals: 0);

  /// 不含货币符号，仅数字（例如 8,240.50）
  String formatRaw({int decimals = 2}) {
    final absAmount = amountCents.abs() / 100.0;
    return _formatNumber(absAmount, decimals);
  }

  static String _formatNumber(double value, int decimals) {
    final fixed = value.toStringAsFixed(decimals);
    final dotIndex = fixed.indexOf('.');
    final intPart = dotIndex >= 0 ? fixed.substring(0, dotIndex) : fixed;
    final decPart = dotIndex >= 0 ? fixed.substring(dotIndex) : '';
    final withCommas = intPart.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (m) => '${m[0]},',
    );
    return '$withCommas$decPart';
  }

  @override
  String toString() => format();

  @override
  bool operator ==(Object other) =>
      other is Money && amountCents == other.amountCents && currency == other.currency;

  @override
  int get hashCode => Object.hash(amountCents, currency);
}
