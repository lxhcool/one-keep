import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

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

  InputDecoration _buildPremiumDecoration({
    required BuildContext context,
    String? hintText,
    Widget? prefixIcon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // 使用更通透的背景色
    final bgColor = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04);
    
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(fontSize: 14, color: isDark ? Colors.white30 : Colors.grey),
      prefixIcon: prefixIcon,
      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      filled: true,
      fillColor: bgColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05), width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05), width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.emerald.withValues(alpha: 0.4), width: 1.2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final viewInsets = MediaQuery.of(context).viewInsets;
    final categories = ref.watch(categoriesProvider);
    final tone = widget.transaction.isExpense ? AppColors.rose : AppColors.emerald;
    final canSave = double.tryParse(_amountController.text.trim()) != null && 
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
            border: Border(top: BorderSide(color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.6), width: 0.5)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 12, 24, 20 + viewInsets.bottom),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 32, height: 4,
                          decoration: BoxDecoration(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(2)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      Row(
                        children: [
                          Text('编辑记录', style: oneKeepManrope(color: oneKeepTextPrimary(context), size: 22, weight: FontWeight.w800)),
                          const Spacer(),
                          OneKeepBouncingCard(onTap: () => Navigator.pop(context), child: Icon(Icons.close_rounded, color: oneKeepTextSecondary(context))),
                        ],
                      ),
                      const SizedBox(height: 24),

                      _EditorLabel(label: '账单金额'),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                        onChanged: (_) => setState(() {}),
                        style: oneKeepGrotesk(color: oneKeepTextPrimary(context), size: 24, weight: FontWeight.w700),
                        cursorColor: tone,
                        decoration: _buildPremiumDecoration(
                          context: context,
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(left: 16, right: 8, bottom: 2),
                            child: Text('¥', style: oneKeepGrotesk(color: tone, size: 24, weight: FontWeight.w700)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      _EditorLabel(label: '选择分类'),
                      categories.when(
                        data: (items) {
                          final filtered = items.where((item) => item.type == widget.transaction.direction).toList();
                          _selectedCategoryId ??= _resolveFallbackCategoryId(filtered);
                          return _CategoryGrid(
                            categories: filtered,
                            selectedCategoryId: _selectedCategoryId,
                            tone: tone,
                            onSelect: (id) => setState(() => _selectedCategoryId = id),
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (_, __) => const Text('分类加载失败'),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _EditorLabel(label: '日期'),
                                _PremiumPickerTile(
                                  icon: LucideIcons.calendar,
                                  value: DateFormat('yyyy/MM/dd').format(_occurredAt),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _EditorLabel(label: '时间'),
                                _PremiumPickerTile(
                                  icon: LucideIcons.clock,
                                  value: DateFormat('HH:mm').format(_occurredAt),
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
                        style: oneKeepInter(color: oneKeepTextPrimary(context), size: 15, weight: FontWeight.w600),
                        cursorColor: tone,
                        decoration: _buildPremiumDecoration(context: context, hintText: '填写商家或地点'),
                      ),
                      const SizedBox(height: 16),

                      _EditorLabel(label: '备注说明'),
                      TextFormField(
                        controller: _noteController,
                        minLines: 2,
                        maxLines: 4,
                        style: oneKeepInter(color: oneKeepTextPrimary(context), size: 15, weight: FontWeight.w600),
                        cursorColor: tone,
                        decoration: _buildPremiumDecoration(context: context, hintText: '记录这笔交易的背景...'),
                      ),
                      const SizedBox(height: 32),

                      OneKeepBouncingCard(
                        onTap: canSave ? _submit : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            color: canSave ? tone : tone.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: canSave ? [BoxShadow(color: tone.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 6))] : null,
                          ),
                          child: Center(
                            child: Text('保存修改', style: oneKeepManrope(color: Colors.white, size: 16, weight: FontWeight.w800)),
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
    final byName = categories.where((item) => item.name == widget.transaction.categoryName);
    if (byName.isNotEmpty) return byName.first.id;
    return categories.isNotEmpty ? categories.first.id : null;
  }

  Future<void> _pickDate() async {
    HapticFeedback.lightImpact();
    final picked = await showDatePicker(
      context: context, initialDate: _occurredAt, firstDate: DateTime(2020), lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: ColorScheme.fromSeed(seedColor: AppColors.emerald, primary: AppColors.emerald, surface: oneKeepSurface(context))), child: child!),
    );
    if (picked == null || !mounted) return;
    setState(() { _occurredAt = DateTime(picked.year, picked.month, picked.day, _occurredAt.hour, _occurredAt.minute); });
  }

  Future<void> _pickTime() async {
    HapticFeedback.lightImpact();
    final picked = await showTimePicker(
      context: context, initialTime: TimeOfDay.fromDateTime(_occurredAt),
      builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: ColorScheme.fromSeed(seedColor: AppColors.emerald, primary: AppColors.emerald, surface: oneKeepSurface(context))), child: child!),
    );
    if (picked == null || !mounted) return;
    setState(() { _occurredAt = DateTime(_occurredAt.year, _occurredAt.month, _occurredAt.day, picked.hour, picked.minute); });
  }

  void _submit() {
    HapticFeedback.heavyImpact();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final amount = double.tryParse(_amountController.text.trim());
    final categoryId = _selectedCategoryId;
    if (amount == null || amount <= 0 || categoryId == null) return;
    Navigator.of(context).pop(TransactionEditDraft(amount: amount, categoryId: categoryId, occurredAt: _occurredAt, merchant: _merchantController.text.trim().isEmpty ? null : _merchantController.text.trim(), note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim()));
  }
}

class _EditorLabel extends StatelessWidget {
  final String label;
  const _EditorLabel({required this.label});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(label, style: oneKeepInter(color: oneKeepTextTertiary(context), size: 12, weight: FontWeight.w700, letterSpacing: 0.5)),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  final List<Category> categories;
  final String? selectedCategoryId;
  final Color tone;
  final ValueChanged<String> onSelect;
  const _CategoryGrid({required this.categories, required this.selectedCategoryId, required this.tone, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // 改进未选中态颜色：更有质感的石板灰/半透白
    final unselectedColor = isDark ? Colors.white.withValues(alpha: 0.4) : const Color(0xFF64748B);
    final unselectedBg = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04);

    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final item = categories[index];
          final selected = item.id == selectedCategoryId;
          return GestureDetector(
            onTap: () { HapticFeedback.lightImpact(); onSelect(item.id); },
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: selected ? tone.withValues(alpha: 0.15) : unselectedBg,
                    borderRadius: BorderRadius.circular(16),
                    border: selected ? Border.all(color: tone.withValues(alpha: 0.4), width: 1.5) : null,
                  ),
                  child: Icon(
                    oneKeepResolvedCategoryIcon(item.name, item.name, item.icon), 
                    size: 22, 
                    color: selected ? tone : unselectedColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.name, 
                  style: oneKeepInter(
                    color: selected ? tone : unselectedColor, 
                    size: 11, 
                    weight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
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
  const _PremiumPickerTile({required this.icon, required this.value, required this.tone, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OneKeepBouncingCard(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05), width: 0.5),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: tone.withValues(alpha: 0.6)),
            const SizedBox(width: 10),
            Text(value, style: oneKeepInter(color: oneKeepTextPrimary(context), size: 13, weight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
