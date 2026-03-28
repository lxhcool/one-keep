import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/providers/data_providers.dart';
import '../../core/theme/app_colors.dart';
import '../models/models.dart';
import 'onekeep_ui.dart';

class TransactionEditDraft {
  final double amount;
  final String categoryId;
  final String? merchant;
  final String? note;
  final DateTime occurredAt;

  const TransactionEditDraft({
    required this.amount,
    required this.categoryId,
    required this.occurredAt,
    this.merchant,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
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
    _occurredAt = widget.transaction.occurredAt;
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

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    final categories = ref.watch(categoriesProvider);
    final tone = widget.transaction.isExpense
        ? AppColors.expense
        : AppColors.income;
    final amount = double.tryParse(_amountController.text.trim());
    final canSave =
        amount != null &&
        amount > 0 &&
        (_selectedCategoryId?.isNotEmpty ?? false);

    return OneKeepSheetSurface(
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + viewInsets.bottom),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: oneKeepTextTertiary(
                          context,
                        ).withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _HeaderCard(
                    transaction: widget.transaction,
                    amountText: _amountController.text.trim().isEmpty
                        ? '0.00'
                        : _amountController.text.trim(),
                    tone: tone,
                  ),
                  const SizedBox(height: 16),
                  OneKeepGlassCard(
                    radius: 22,
                    blurSigma: 18,
                    fillColor: oneKeepGlass(context),
                    borderColor: oneKeepBorder(context),
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionTitle(label: '交易信息'),
                        const SizedBox(height: 14),
                        _EditorField(
                          label: '金额',
                          child: TextFormField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.]'),
                              ),
                            ],
                            onChanged: (_) => setState(() {}),
                            validator: (value) {
                              final parsed = double.tryParse(
                                value?.trim() ?? '',
                              );
                              if (parsed == null || parsed <= 0) {
                                return '请输入有效金额';
                              }
                              return null;
                            },
                            style: oneKeepGrotesk(
                              color: oneKeepTextPrimary(context),
                              size: 22,
                              weight: FontWeight.w700,
                            ),
                            decoration: _inputDecoration(
                              context,
                              prefixText: '¥ ',
                              prefixStyle: oneKeepGrotesk(
                                color: tone,
                                size: 22,
                                weight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _EditorField(
                          label: '分类',
                          child: categories.when(
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
                              return _CategorySelector(
                                categories: filtered,
                                selectedCategoryId: _selectedCategoryId,
                                tone: tone,
                                onSelect: (id) {
                                  setState(() => _selectedCategoryId = id);
                                },
                              );
                            },
                            loading: () => const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                            error: (error, stackTrace) => Text(
                              '分类加载失败',
                              style: oneKeepInter(
                                color: AppColors.expense,
                                size: 12,
                                weight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _PickerTile(
                                icon: Icons.calendar_month_rounded,
                                label: '日期',
                                value: DateFormat(
                                  'yyyy/MM/dd',
                                ).format(_occurredAt),
                                tone: tone,
                                onTap: _pickDate,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _PickerTile(
                                icon: Icons.schedule_rounded,
                                label: '时间',
                                value: DateFormat('HH:mm').format(_occurredAt),
                                tone: tone,
                                onTap: _pickTime,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  OneKeepGlassCard(
                    radius: 22,
                    blurSigma: 16,
                    fillColor: oneKeepGlass(context),
                    borderColor: oneKeepBorder(context),
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionTitle(label: '补充信息'),
                        const SizedBox(height: 14),
                        _EditorField(
                          label: '商家',
                          child: TextFormField(
                            controller: _merchantController,
                            style: oneKeepInter(
                              color: oneKeepTextPrimary(context),
                              size: 14,
                              weight: FontWeight.w500,
                            ),
                            decoration: _inputDecoration(
                              context,
                              hintText: '填写商家名称',
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _EditorField(
                          label: '备注',
                          child: TextFormField(
                            controller: _noteController,
                            minLines: 3,
                            maxLines: 4,
                            style: oneKeepInter(
                              color: oneKeepTextPrimary(context),
                              size: 14,
                              weight: FontWeight.w500,
                            ),
                            decoration: _inputDecoration(
                              context,
                              hintText: '记录这笔交易的背景信息',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  GestureDetector(
                    onTap: canSave ? _submit : null,
                    child: Opacity(
                      opacity: canSave ? 1 : 0.5,
                      child: Container(
                        width: double.infinity,
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [tone, tone.withValues(alpha: 0.78)],
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child: Text(
                            '保存修改',
                            style: oneKeepManrope(
                              color: Colors.white,
                              size: 15,
                              weight: FontWeight.w800,
                              letterSpacing: 0.3,
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
    );
  }

  String? _resolveFallbackCategoryId(List<Category> categories) {
    final byName = categories.where(
      (item) => item.name == widget.transaction.categoryName,
    );
    if (byName.isNotEmpty) {
      return byName.first.id;
    }
    return categories.isNotEmpty ? categories.first.id : null;
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    String? hintText,
    String? prefixText,
    TextStyle? prefixStyle,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      hintText: hintText,
      hintStyle: oneKeepInter(
        color: oneKeepTextTertiary(context),
        size: 13,
        weight: FontWeight.w400,
      ),
      prefixText: prefixText,
      prefixStyle: prefixStyle,
      filled: true,
      fillColor: isDark ? AppColors.darkInputBg : AppColors.lightInputBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: oneKeepBorder(context), width: 0.8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: oneKeepBorder(context), width: 0.8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: oneKeepAccent(context), width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
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
    final picked = await showTimePicker(
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
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final amount = double.tryParse(_amountController.text.trim());
    final categoryId = _selectedCategoryId;
    if (amount == null ||
        amount <= 0 ||
        categoryId == null ||
        categoryId.isEmpty) {
      return;
    }

    Navigator.of(context).pop(
      TransactionEditDraft(
        amount: amount,
        categoryId: categoryId,
        occurredAt: _occurredAt,
        merchant: _merchantController.text.trim().isEmpty
            ? null
            : _merchantController.text.trim(),
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final Transaction transaction;
  final String amountText;
  final Color tone;

  const _HeaderCard({
    required this.transaction,
    required this.amountText,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    final icon = oneKeepCategoryIcon(
      transaction.title,
      transaction.categoryName,
      transaction.categoryIcon,
    );
    return OneKeepGlassCard(
      radius: 24,
      blurSigma: 24,
      fillColor: oneKeepGlassStrong(context),
      borderColor: oneKeepBorderStrong(context),
      padding: const EdgeInsets.all(18),
      shadows: [
        BoxShadow(
          color: tone.withValues(alpha: 0.12),
          blurRadius: 28,
          offset: const Offset(0, 12),
        ),
      ],
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: tone.withValues(alpha: 0.22),
                width: 0.8,
              ),
            ),
            child: Icon(icon, color: tone, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '编辑记账',
                  style: oneKeepGrotesk(
                    color: oneKeepTextPrimary(context),
                    size: 20,
                    weight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${transaction.categoryName} · ${oneKeepDayTime(transaction.occurredAt)}',
                  style: oneKeepInter(
                    color: oneKeepTextSecondary(context),
                    size: 12,
                    weight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${transaction.isExpense ? '-' : '+'}¥$amountText',
            style: oneKeepGrotesk(
              color: tone,
              size: 22,
              weight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String label;

  const _SectionTitle({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: oneKeepManrope(
        color: oneKeepTextPrimary(context),
        size: 14,
        weight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _EditorField extends StatelessWidget {
  final String label;
  final Widget child;

  const _EditorField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: oneKeepManrope(
            color: oneKeepTextSecondary(context),
            size: 12,
            weight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _CategorySelector extends StatelessWidget {
  final List<Category> categories;
  final String? selectedCategoryId;
  final Color tone;
  final ValueChanged<String> onSelect;

  const _CategorySelector({
    required this.categories,
    required this.selectedCategoryId,
    required this.tone,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: categories.map((category) {
        final selected = category.id == selectedCategoryId;
        return GestureDetector(
          onTap: () => onSelect(category.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? tone.withValues(alpha: 0.14)
                  : oneKeepGlassStrong(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected
                    ? tone.withValues(alpha: 0.36)
                    : oneKeepBorder(context),
                width: 0.9,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  oneKeepCategoryIcon(
                    category.name,
                    category.name,
                    category.icon,
                  ),
                  size: 16,
                  color: selected ? tone : oneKeepTextSecondary(context),
                ),
                const SizedBox(width: 6),
                Text(
                  category.name,
                  style: oneKeepInter(
                    color: selected ? tone : oneKeepTextPrimary(context),
                    size: 12,
                    weight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color tone;
  final VoidCallback onTap;

  const _PickerTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.tone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 62,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: oneKeepGlassStrong(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: oneKeepBorder(context), width: 0.8),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: tone.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 16, color: tone),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: oneKeepInter(
                      color: oneKeepTextTertiary(context),
                      size: 11,
                      weight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: oneKeepInter(
                      color: oneKeepTextPrimary(context),
                      size: 13,
                      weight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
