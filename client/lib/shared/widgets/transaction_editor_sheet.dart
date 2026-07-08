import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:liqing/core/theme/lucide_icons_compat.dart';

import '../../core/providers/data_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/category_icons.dart';
import '../models/models.dart';
import 'onekeep_ui.dart';

class TransactionEditDraft {
  final String title;
  final double amount;
  final String categoryId;
  final String? merchant;
  final String? note;
  final DateTime occurredAt;

  const TransactionEditDraft({
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.occurredAt,
    this.merchant,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'amount': amount,
      'categoryId': categoryId,
      'occurredAt': occurredAt.toUtc().toIso8601String(),
      'merchant': merchant,
      'note': note,
    };
  }
}

class OneKeepTransactionEditorSheet extends ConsumerStatefulWidget {
  final Transaction transaction;

  const OneKeepTransactionEditorSheet({super.key, required this.transaction});

  @override
  ConsumerState<OneKeepTransactionEditorSheet> createState() =>
      _OneKeepTransactionEditorSheetState();
}

class _OneKeepTransactionEditorSheetState
    extends ConsumerState<OneKeepTransactionEditorSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _amountController;
  late final TextEditingController _merchantController;
  late final TextEditingController _noteController;
  late DateTime _occurredAt;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.transaction.amount.toStringAsFixed(2),
    );
    _merchantController = TextEditingController(
      text: widget.transaction.merchant ?? '',
    );
    _noteController = TextEditingController(
      text: widget.transaction.note ?? '',
    );
    _occurredAt = widget.transaction.occurredAt.toLocal();
    _selectedCategoryId = widget.transaction.categoryId.isNotEmpty
        ? widget.transaction.categoryId
        : null;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _merchantController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  InputDecoration _buildPremiumDecoration({
    required BuildContext context,
    String? hintText,
    Widget? prefixIcon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // 使用更通透的背景色
    final bgColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.04);

    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        fontSize: 14,
        color: isDark ? Colors.white30 : Colors.grey,
      ),
      prefixIcon: prefixIcon,
      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      filled: true,
      fillColor: bgColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
          width: 0.5,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
          width: 0.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: AppColors.emerald.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final viewInsets = MediaQuery.of(context).viewInsets;
    final categories = ref.watch(categoriesProvider);
    final tone = widget.transaction.isExpense
        ? AppColors.rose
        : AppColors.emerald;
    final sheetHeight = math.min(
      MediaQuery.sizeOf(context).height -
          MediaQuery.paddingOf(context).top -
          48,
      720.0,
    );
    final canSave =
        double.tryParse(_amountController.text.trim()) != null &&
        double.parse(_amountController.text.trim()) > 0 &&
        (_selectedCategoryId?.isNotEmpty ?? false);

    // 彻底应用高斯模糊容器
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1C1C1E).withValues(alpha: 0.75)
                : Colors.white.withValues(alpha: 0.8),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.6),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: sheetHeight,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  24,
                  12,
                  24,
                  20 + viewInsets.bottom,
                ),
                child: Form(
                  key: _formKey,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        bottom: 80,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Container(
                                  width: 32,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color:
                                        (isDark ? Colors.white : Colors.black)
                                            .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              Row(
                                children: [
                                  Text(
                                    '编辑记录',
                                    style: oneKeepManrope(
                                      color: oneKeepTextPrimary(context),
                                      size: 22,
                                      weight: FontWeight.w800,
                                    ),
                                  ),
                                  const Spacer(),
                                  OneKeepBouncingCard(
                                    onTap: () => Navigator.pop(context),
                                    child: Icon(
                                      Icons.close_rounded,
                                      color: oneKeepTextSecondary(context),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              _EditorLabel(label: '账单金额'),
                              TextFormField(
                                controller: _amountController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9.]'),
                                  ),
                                ],
                                onChanged: (_) => setState(() {}),
                                style: oneKeepGrotesk(
                                  color: oneKeepTextPrimary(context),
                                  size: 24,
                                  weight: FontWeight.w700,
                                ),
                                cursorColor: tone,
                                decoration: _buildPremiumDecoration(
                                  context: context,
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 16,
                                      right: 8,
                                      bottom: 2,
                                    ),
                                    child: Text(
                                      '¥',
                                      style: oneKeepGrotesk(
                                        color: tone,
                                        size: 24,
                                        weight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              _EditorLabel(label: '选择分类'),
                              categories.when(
                                data: (items) {
                                  final filtered = items
                                      .where(
                                        (item) =>
                                            item.type ==
                                            widget.transaction.direction,
                                      )
                                      .toList();
                                  _selectedCategoryId ??=
                                      _resolveFallbackCategoryId(filtered);
                                  return _CategoryGrid(
                                    categories: filtered,
                                    selectedCategoryId: _selectedCategoryId,
                                    onSelect: (id) => setState(
                                      () => _selectedCategoryId = id,
                                    ),
                                  );
                                },
                                loading: () => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                error: (_, __) => const Text('分类加载失败'),
                              ),
                              const SizedBox(height: 16),

                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _EditorLabel(label: '日期'),
                                        _PremiumPickerTile(
                                          icon: LucideIcons.calendar,
                                          value: DateFormat(
                                            'yyyy/MM/dd',
                                          ).format(_occurredAt),
                                          tone: tone,
                                          isDark: isDark,
                                          onTap: _pickDate,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _EditorLabel(label: '时间'),
                                        _PremiumPickerTile(
                                          icon: LucideIcons.clock,
                                          value: DateFormat(
                                            'HH:mm',
                                          ).format(_occurredAt),
                                          tone: tone,
                                          isDark: isDark,
                                          onTap: _pickTime,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              _EditorLabel(label: '商家名称'),
                              TextFormField(
                                controller: _merchantController,
                                style: oneKeepInter(
                                  color: oneKeepTextPrimary(context),
                                  size: 15,
                                  weight: FontWeight.w600,
                                ),
                                cursorColor: tone,
                                decoration: _buildPremiumDecoration(
                                  context: context,
                                  hintText: '填写商家或地点',
                                ),
                              ),
                              const SizedBox(height: 16),

                              _EditorLabel(label: '备注说明'),
                              TextFormField(
                                controller: _noteController,
                                minLines: 2,
                                maxLines: 4,
                                style: oneKeepInter(
                                  color: oneKeepTextPrimary(context),
                                  size: 15,
                                  weight: FontWeight.w600,
                                ),
                                cursorColor: tone,
                                decoration: _buildPremiumDecoration(
                                  context: context,
                                  hintText: '记录这笔交易的背景...',
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: OneKeepBouncingCard(
                          onTap: canSave ? _submit : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              color: canSave
                                  ? tone
                                  : tone.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Center(
                              child: Text(
                                '保存修改',
                                style: oneKeepManrope(
                                  color: Colors.white,
                                  size: 16,
                                  weight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _resolveFallbackCategoryId(List<Category> categories) {
    final byName = categories.where(
      (item) => item.name == widget.transaction.categoryName,
    );
    if (byName.isNotEmpty) return byName.first.id;
    return categories.isNotEmpty ? categories.first.id : null;
  }

  Future<void> _pickDate() async {
    HapticFeedback.lightImpact();
    final picked = await showOneKeepDatePicker(
      context: context,
      initialDate: _occurredAt,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _occurredAt = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _occurredAt.hour,
        _occurredAt.minute,
      );
    });
  }

  Future<void> _pickTime() async {
    HapticFeedback.lightImpact();
    final picked = await _showOneKeepTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_occurredAt),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _occurredAt = DateTime(
        _occurredAt.year,
        _occurredAt.month,
        _occurredAt.day,
        picked.hour,
        picked.minute,
      );
    });
  }

  void _submit() {
    HapticFeedback.heavyImpact();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final amount = double.tryParse(_amountController.text.trim());
    final categoryId = _selectedCategoryId;
    if (amount == null || amount <= 0 || categoryId == null) return;
    final categories = ref.read(categoriesProvider).valueOrNull;
    final categoryName =
        categories?.where((item) => item.id == categoryId).firstOrNull?.name ??
        widget.transaction.categoryName;
    final note = _noteController.text.trim();
    Navigator.of(context).pop(
      TransactionEditDraft(
        title: note.isNotEmpty ? note : categoryName,
        amount: amount,
        categoryId: categoryId,
        occurredAt: _occurredAt,
        merchant: _merchantController.text.trim().isEmpty
            ? null
            : _merchantController.text.trim(),
        note: note.isEmpty ? null : note,
      ),
    );
  }
}

Future<TimeOfDay?> _showOneKeepTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
}) {
  return showModalBottomSheet<TimeOfDay>(
    context: context,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    barrierColor: oneKeepDimOverlay(context),
    builder: (_) => _OneKeepTimePickerSheet(initialTime: initialTime),
  );
}

class _OneKeepTimePickerSheet extends StatefulWidget {
  final TimeOfDay initialTime;

  const _OneKeepTimePickerSheet({required this.initialTime});

  @override
  State<_OneKeepTimePickerSheet> createState() =>
      _OneKeepTimePickerSheetState();
}

class _OneKeepTimePickerSheetState extends State<_OneKeepTimePickerSheet> {
  late int _hour;
  late int _minute;
  late final FixedExtentScrollController _hourController;
  late final FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    _hour = widget.initialTime.hour;
    _minute = widget.initialTime.minute;
    _hourController = FixedExtentScrollController(initialItem: _hour);
    _minuteController = FixedExtentScrollController(initialItem: _minute);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return OneKeepSheetSurface(
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: oneKeepTextTertiary(context).withValues(alpha: 0.32),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Text(
                    '选择时间',
                    style: oneKeepManrope(
                      color: oneKeepTextPrimary(context),
                      size: 18,
                      weight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_hour.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')}',
                    style: oneKeepGrotesk(
                      color: AppColors.emerald,
                      size: 20,
                      weight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 180,
                child: Row(
                  children: [
                    Expanded(
                      child: _TimeWheel(
                        controller: _hourController,
                        count: 24,
                        suffix: '时',
                        isDark: isDark,
                        onSelectedItemChanged: (value) =>
                            setState(() => _hour = value),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TimeWheel(
                        controller: _minuteController,
                        count: 60,
                        suffix: '分',
                        isDark: isDark,
                        onSelectedItemChanged: (value) =>
                            setState(() => _minute = value),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              OneKeepBouncingCard(
                onTap: () => Navigator.pop(
                  context,
                  TimeOfDay(hour: _hour, minute: _minute),
                ),
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.emerald,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '确认',
                    style: oneKeepManrope(
                      color: Colors.white,
                      size: 15,
                      weight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeWheel extends StatelessWidget {
  final FixedExtentScrollController controller;
  final int count;
  final String suffix;
  final bool isDark;
  final ValueChanged<int> onSelectedItemChanged;

  const _TimeWheel({
    required this.controller,
    required this.count,
    required this.suffix,
    required this.isDark,
    required this.onSelectedItemChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
      ),
      child: CupertinoPicker(
        scrollController: controller,
        itemExtent: 44,
        magnification: 1.08,
        squeeze: 1.05,
        useMagnifier: true,
        selectionOverlay: Container(
          decoration: BoxDecoration(
            border: Border.symmetric(
              horizontal: BorderSide(
                color: AppColors.emerald.withValues(alpha: 0.22),
              ),
            ),
          ),
        ),
        onSelectedItemChanged: onSelectedItemChanged,
        children: [
          for (var index = 0; index < count; index++)
            Center(
              child: Text(
                '${index.toString().padLeft(2, '0')} $suffix',
                style: oneKeepGrotesk(
                  color: oneKeepTextPrimary(context),
                  size: 20,
                  weight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EditorLabel extends StatelessWidget {
  final String label;
  const _EditorLabel({required this.label});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: oneKeepInter(
          color: oneKeepTextTertiary(context),
          size: 12,
          weight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  final List<Category> categories;
  final String? selectedCategoryId;
  final ValueChanged<String> onSelect;
  const _CategoryGrid({
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    const columns = 5;
    final rows = <List<Category>>[
      for (var i = 0; i < categories.length; i += columns)
        categories.sublist(i, math.min(i + columns, categories.length)),
    ];

    return Container(
      alignment: Alignment.topLeft,
      constraints: const BoxConstraints(maxHeight: 184),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (var index = 0; index < columns; index++)
                      index < rows[rowIndex].length
                          ? _EditorCategoryItem(
                              item: rows[rowIndex][index],
                              selected:
                                  rows[rowIndex][index].id ==
                                  selectedCategoryId,
                              onTap: () {
                                HapticFeedback.lightImpact();
                                onSelect(rows[rowIndex][index].id);
                              },
                            )
                          : const SizedBox(width: 46),
                  ],
                ),
                if (rowIndex < rows.length - 1) const SizedBox(height: 6),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EditorCategoryItem extends StatelessWidget {
  final Category item;
  final bool selected;
  final VoidCallback onTap;

  const _EditorCategoryItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryTone = oneKeepCategoryTone(
      colorHex: item.color,
      categoryId: item.id,
      categoryName: item.name,
      categoryIcon: item.icon,
    );
    final iconCacheSize = (24 * MediaQuery.devicePixelRatioOf(context)).round();

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: selected
                  ? categoryTone.withValues(alpha: 0.2)
                  : (isDark
                        ? Colors.white10
                        : Colors.black.withValues(alpha: 0.05)),
              borderRadius: BorderRadius.circular(14),
              border: selected
                  ? Border.all(
                      color: categoryTone.withValues(alpha: 0.4),
                      width: 1.5,
                    )
                  : null,
            ),
            child: Center(
              child: Image.asset(
                resolveCategoryIconAsset(
                  item.icon.isNotEmpty ? item.icon : item.name,
                ),
                width: 24,
                height: 24,
                cacheWidth: iconCacheSize,
                cacheHeight: iconCacheSize,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.receipt_long_rounded,
                  size: 24,
                  color: selected
                      ? categoryTone
                      : oneKeepTextSecondary(context),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 46,
            child: Text(
              item.name,
              style: oneKeepInter(
                color: selected ? categoryTone : oneKeepTextSecondary(context),
                size: 10,
                weight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumPickerTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color tone;
  final bool isDark;
  final VoidCallback onTap;
  const _PremiumPickerTile({
    required this.icon,
    required this.value,
    required this.tone,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OneKeepBouncingCard(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: (isDark ? Colors.white : Colors.black).withValues(
              alpha: 0.05,
            ),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: tone.withValues(alpha: 0.6)),
            const SizedBox(width: 10),
            Text(
              value,
              style: oneKeepInter(
                color: oneKeepTextPrimary(context),
                size: 13,
                weight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
