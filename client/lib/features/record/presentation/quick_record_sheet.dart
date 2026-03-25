import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../transaction/domain/entities/transaction.dart';
import '../../transaction/domain/entities/transaction_category.dart';

const _expenseCategories = [
  TransactionCategory.food,
  TransactionCategory.transport,
  TransactionCategory.shopping,
  TransactionCategory.other,
];

const _incomeCategories = [
  TransactionCategory.salary,
  TransactionCategory.other,
];

class QuickRecordSheet extends StatefulWidget {
  const QuickRecordSheet({super.key});

  @override
  State<QuickRecordSheet> createState() => _QuickRecordSheetState();
}

class _QuickRecordSheetState extends State<QuickRecordSheet> {
  TransactionType _type = TransactionType.expense;
  TransactionCategory _category = TransactionCategory.food;
  String _amount = '0';

  List<TransactionCategory> get _categories =>
      _type == TransactionType.expense ? _expenseCategories : _incomeCategories;

  void _onKey(String key) {
    setState(() {
      if (key == '⌫') {
        _amount = _amount.length <= 1 ? '0' : _amount.substring(0, _amount.length - 1);
      } else if (key == '.') {
        if (!_amount.contains('.')) _amount += '.';
      } else {
        if (_amount == '0') {
          _amount = key;
        } else if (_amount.length < 10) {
          final dotIndex = _amount.indexOf('.');
          if (dotIndex >= 0 && _amount.length - dotIndex > 2) return;
          _amount += key;
        }
      }
    });
  }

  void _onTypeChange(TransactionType type) {
    setState(() {
      _type = type;
      _category = _categories.first;
    });
  }

  void _confirm() {
    final sign = _type == TransactionType.expense ? '-' : '+';
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已记录 $sign¥$_amount'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, 16 + bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Type toggle
          _TypeToggle(type: _type, onChanged: _onTypeChange),
          const SizedBox(height: 20),
          // Amount display
          SizedBox(
            width: double.infinity,
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: '¥ ',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  TextSpan(
                    text: _amount,
                    style: const TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          // Category grid
          _CategoryGrid(
            categories: _categories,
            selected: _category,
            onSelected: (c) => setState(() => _category = c),
          ),
          const SizedBox(height: 20),
          // Number pad
          _NumPad(onKey: _onKey),
          const SizedBox(height: 16),
          // Confirm button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _amount == '0' ? null : _confirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGreen,
                disabledBackgroundColor: AppColors.borderSubtle,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                elevation: 0,
              ),
              child: Text(
                '保存',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _amount == '0' ? AppColors.textTertiary : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeToggle extends StatelessWidget {
  const _TypeToggle({required this.type, required this.onChanged});

  final TransactionType type;
  final ValueChanged<TransactionType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _tab('支出', TransactionType.expense, AppColors.accentRed),
        const SizedBox(width: 12),
        _tab('收入', TransactionType.income, AppColors.accentGreen),
      ],
    );
  }

  Widget _tab(String label, TransactionType t, Color activeColor) {
    final isActive = type == t;
    return GestureDetector(
      onTap: () => onChanged(t),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? activeColor : AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: isActive ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  final List<TransactionCategory> categories;
  final TransactionCategory selected;
  final ValueChanged<TransactionCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: categories.map((c) {
        final isActive = c.id == selected.id;
        return GestureDetector(
          onTap: () => onSelected(c),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: isActive ? c.iconBgColor : AppColors.bgCard,
                  shape: BoxShape.circle,
                  border: isActive
                      ? Border.all(color: c.iconColor, width: 2)
                      : null,
                ),
                child: Icon(
                  c.icon,
                  color: isActive ? c.iconColor : AppColors.textTertiary,
                  size: 24,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                c.name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      isActive ? FontWeight.w700 : FontWeight.w400,
                  color: isActive
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _NumPad extends StatelessWidget {
  const _NumPad({required this.onKey});

  final ValueChanged<String> onKey;

  static const _rows = [
    ['7', '8', '9'],
    ['4', '5', '6'],
    ['1', '2', '3'],
    ['.', '0', '⌫'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _rows.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: row.map((key) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _KeyButton(label: key, onTap: () => onKey(key)),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDelete = label == '⌫';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isDelete ? AppColors.bgExpense : AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        child: Center(
          child: isDelete
              ? const Icon(
                  Icons.backspace_outlined,
                  color: AppColors.accentRed,
                  size: 18,
                )
              : Text(
                  label,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
        ),
      ),
    );
  }
}
