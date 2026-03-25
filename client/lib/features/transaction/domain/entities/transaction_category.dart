import 'package:flutter/material.dart';

class TransactionCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  const TransactionCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });

  static const food = TransactionCategory(
    id: 'food',
    name: '餐饮',
    icon: Icons.restaurant_outlined,
    iconColor: Color(0xFFF97316),
    iconBgColor: Color(0xFFFFF7ED),
  );

  static const transport = TransactionCategory(
    id: 'transport',
    name: '出行',
    icon: Icons.directions_car_outlined,
    iconColor: Color(0xFF3B82F6),
    iconBgColor: Color(0xFFEFF6FF),
  );

  static const salary = TransactionCategory(
    id: 'salary',
    name: '工资',
    icon: Icons.account_balance_wallet_outlined,
    iconColor: Color(0xFF22C55E),
    iconBgColor: Color(0xFFF0FDF4),
  );

  static const shopping = TransactionCategory(
    id: 'shopping',
    name: '购物',
    icon: Icons.shopping_bag_outlined,
    iconColor: Color(0xFFF59E0B),
    iconBgColor: Color(0xFFFEF3C7),
  );

  static const other = TransactionCategory(
    id: 'other',
    name: '其他',
    icon: Icons.account_balance_wallet_outlined,
    iconColor: Color(0xFF9CA3AF),
    iconBgColor: Color(0xFFF3F4F6),
  );

  static TransactionCategory fromId(String id) {
    switch (id) {
      case 'food':
        return food;
      case 'transport':
        return transport;
      case 'salary':
        return salary;
      case 'shopping':
        return shopping;
      default:
        return other;
    }
  }
}
