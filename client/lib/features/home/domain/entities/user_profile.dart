class UserProfile {
  final String id;
  final String displayName;

  const UserProfile({required this.id, required this.displayName});

  /// 根据当前时间返回问候语（不含"，"）
  String get greeting {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) return '早上好';
    if (hour >= 12 && hour < 18) return '下午好';
    return '晚上好';
  }

  /// 超过 20 字截断加省略号
  String get truncatedName {
    if (displayName.length <= 20) return displayName;
    return '${displayName.substring(0, 20)}...';
  }
}
