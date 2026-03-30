import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/providers/api_provider.dart';
import '../../core/providers/data_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/onekeep_iconfont.dart';
import '../../shared/models/models.dart';
import '../../shared/widgets/onekeep_ui.dart';

class CategorySettingsSheet extends ConsumerStatefulWidget {
  const CategorySettingsSheet({super.key});

  @override
  ConsumerState<CategorySettingsSheet> createState() {
    return _CategorySettingsSheetState();
  }
}

class _CategorySettingsSheetState extends ConsumerState<CategorySettingsSheet> {
  String _activeType = 'expense';
  bool _isSaving = false;
  List<Category>? _draftCategories;

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0A0B) : const Color(0xFFF8F9FA),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: categoriesAsync.when(
          data: (items) {
            _hydrateCategories(items);
            final categories = _draftCategories ?? items;
            final filtered = categories
                .where((item) => item.type == _activeType)
                .toList();

            return Column(
              children: [
                // 头部
                _buildHeader(isDark),
                // 切换标签
                _buildTypeTabs(isDark),
                const SizedBox(height: 8),
                // 列表
                Expanded(
                  child: filtered.isEmpty
                      ? _EmptyCategoryState(
                          type: _activeType,
                          onAdd: () => _handleCreate(),
                        )
                      : ReorderableListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: filtered.length,
                          buildDefaultDragHandles: false,
                          onReorder: (oldIndex, newIndex) =>
                              _handleReorder(filtered, oldIndex, newIndex),
                          itemBuilder: (context, index) {
                            final category = filtered[index];
                            return _CategoryItem(
                              key: ValueKey(category.id),
                              index: index,
                              category: category,
                              onEdit: () => _handleEdit(category),
                              onDelete: () => _handleDelete(category),
                            );
                          },
                        ),
                ),
                // 底部添加按钮
                _buildBottomButton(isDark),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => _CategoryErrorState(
            message: ApiClient.readableError(error, fallback: '分类加载失败'),
            onRetry: _refreshCategories,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E7EB),
          ),
        ),
      ),
      child: Row(
        children: [
          // 关闭按钮
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.close,
                size: 18,
                color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B7280),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 标题
          Expanded(
            child: Text(
              '分类管理',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1F2937),
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // 保存按钮（这里主要是完成，因为没有需要保存的）
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.teal,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '完成',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeTabs(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _activeType = 'expense'),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: _activeType == 'expense' ? AppColors.expense : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '支出',
                    style: TextStyle(
                      color: _activeType == 'expense' 
                          ? Colors.white 
                          : (isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B7280)),
                      fontSize: 13,
                      fontWeight: _activeType == 'expense' ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _activeType = 'income'),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: _activeType == 'income' ? AppColors.income : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '收入',
                    style: TextStyle(
                      color: _activeType == 'income' 
                          ? Colors.white 
                          : (isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B7280)),
                      fontSize: 13,
                      fontWeight: _activeType == 'income' ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton(bool isDark) {
    final color = _activeType == 'expense' ? AppColors.expense : AppColors.income;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1F) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E7EB),
          ),
        ),
      ),
      child: GestureDetector(
        onTap: _isSaving ? null : () => _handleCreate(),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add, size: 18, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                _activeType == 'expense' ? '新增支出分类' : '新增收入分类',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _hydrateCategories(List<Category> categories) {
    final shouldReplace =
        _draftCategories == null ||
        (_draftCategories!.length != categories.length) ||
        _draftCategories!.asMap().entries.any(
          (entry) =>
              _categoryFingerprint(entry.value) !=
              _categoryFingerprint(categories[entry.key]),
        );

    if (shouldReplace) {
      _draftCategories = List<Category>.from(categories);
    }
  }

  String _categoryFingerprint(Category category) {
    return '${category.id}|${category.name}|${category.icon}|${category.type}|${category.color ?? ''}';
  }

  Future<void> _handleCreate() async {
    final result = await showModalBottomSheet<_CategoryEditorResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CategoryEditorSheet(initialType: _activeType),
    );
    if (result == null) return;

    await _runMutation(() async {
      final api = ref.read(apiClientProvider);
      await api.dio.post('/api/categories', data: result.toJson());
      _activeType = result.type;
      await _refreshCategories();
    });
  }

  Future<void> _handleEdit(Category category) async {
    final result = await showModalBottomSheet<_CategoryEditorResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CategoryEditorSheet(
        initialType: category.type,
        initialName: category.name,
        initialIcon: category.icon,
        initialColor: category.color,
      ),
    );
    if (result == null) return;

    await _runMutation(() async {
      final api = ref.read(apiClientProvider);
      await api.dio.put(
        '/api/categories/${category.id}',
        data: result.toJson(),
      );
      _activeType = result.type;
      await _refreshCategories();
    });
  }

  Future<void> _handleDelete(Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1C1C1F) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            '删除分类',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF18181B),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            '确定要删除"${category.name}"吗？此操作不可撤销。',
            style: TextStyle(
              color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B7280),
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                '取消',
                style: TextStyle(
                  color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                '删除',
                style: TextStyle(
                  color: AppColors.expense,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await _runMutation(() async {
      final api = ref.read(apiClientProvider);
      await api.dio.delete('/api/categories/${category.id}');
      await _refreshCategories();
    });
  }

  Future<void> _handleReorder(
    List<Category> filtered,
    int oldIndex,
    int newIndex,
  ) async {
    if (_draftCategories == null || filtered.length <= 1) return;

    final normalizedNewIndex = oldIndex < newIndex ? newIndex - 1 : newIndex;
    if (oldIndex == normalizedNewIndex) return;

    final reordered = List<Category>.from(filtered);
    final moved = reordered.removeAt(oldIndex);
    reordered.insert(normalizedNewIndex, moved);

    final remaining = _draftCategories!
        .where((item) => item.type != _activeType)
        .toList();
    final merged = [...remaining, ...reordered];

    setState(() {
      _draftCategories = merged;
    });

    await _runMutation(
      () async {
        final api = ref.read(apiClientProvider);
        await api.dio.put(
          '/api/categories/reorder',
          data: {
            'type': _activeType,
            'categoryIds': reordered.map((item) => item.id).toList(),
          },
        );
        await _refreshCategories();
      },
      rollback: () {
        setState(() {
          _draftCategories = [...remaining, ...filtered];
        });
      },
    );
  }

  Future<void> _refreshCategories() async {
    ref.invalidate(categoriesProvider);
    final categories = await ref.read(categoriesProvider.future);
    if (!mounted) return;
    setState(() {
      _draftCategories = List<Category>.from(categories);
    });
  }

  Future<void> _runMutation(
    Future<void> Function() action, {
    VoidCallback? rollback,
  }) async {
    setState(() => _isSaving = true);
    try {
      await action();
    } on DioException catch (error) {
      rollback?.call();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ApiClient.readableError(error, fallback: '分类操作失败')),
        ),
      );
    } catch (_) {
      rollback?.call();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('分类操作失败')));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class _CategoryItem extends StatelessWidget {
  final int index;
  final Category category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryItem({
    super.key,
    required this.index,
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tone = oneKeepCategoryTone(
      colorHex: category.color,
      categoryId: category.id,
      categoryName: category.name,
      categoryIcon: category.icon,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 12, right: 4),
        dense: true,
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: tone.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            oneKeepIconFont(category.icon) ?? Icons.category_outlined,
            color: tone,
            size: 18,
          ),
        ),
        title: Text(
          category.name,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1F2937),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: onEdit,
              icon: Icon(
                Icons.edit_outlined,
                size: 18,
                color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF9CA3AF),
              ),
              splashRadius: 18,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
            IconButton(
              onPressed: onDelete,
              icon: Icon(
                Icons.delete_outline,
                size: 18,
                color: AppColors.expense,
              ),
              splashRadius: 18,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
            ReorderableDragStartListener(
              index: index,
              child: Padding(
                padding: const EdgeInsets.only(left: 4, right: 8),
                child: Icon(
                  Icons.drag_handle,
                  size: 18,
                  color: isDark ? const Color(0xFF8E8E93) : const Color(0xFFD1D5DB),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCategoryState extends StatelessWidget {
  final String type;
  final VoidCallback onAdd;

  const _EmptyCategoryState({required this.type, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tone = type == 'expense' ? AppColors.expense : AppColors.income;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.category_outlined, size: 24, color: tone),
          ),
          const SizedBox(height: 12),
          Text(
            type == 'expense' ? '暂无支出分类' : '暂无收入分类',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1F2937),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '点击下方按钮添加',
            style: TextStyle(
              color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF9CA3AF),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _CategoryErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 40,
            color: AppColors.expense,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1F2937),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }
}

class _CategoryEditorResult {
  final String name;
  final String icon;
  final String type;
  final String color;

  const _CategoryEditorResult({
    required this.name,
    required this.icon,
    required this.type,
    required this.color,
  });

  Map<String, dynamic> toJson() {
    return {'name': name, 'icon': icon, 'type': type, 'color': color};
  }
}

class _CategoryEditorSheet extends StatefulWidget {
  final String initialType;
  final String initialName;
  final String initialIcon;
  final String? initialColor;

  const _CategoryEditorSheet({
    required this.initialType,
    this.initialName = '',
    this.initialIcon = 'a-068_yongcan',
    this.initialColor,
  });

  @override
  State<_CategoryEditorSheet> createState() => _CategoryEditorSheetState();
}

class _CategoryEditorSheetState extends State<_CategoryEditorSheet> {
  late final TextEditingController _nameController;
  late String _type;
  late String _icon;
  late Color _color;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _type = widget.initialType;
    _icon = widget.initialIcon;
    _color = oneKeepParseHexColor(widget.initialColor) ??
        (widget.initialType == 'expense' ? AppColors.expense : AppColors.income);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1F) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头部
              Row(
                children: [
                  // 关闭
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 标题
                  Expanded(
                    child: Text(
                      widget.initialName.isEmpty ? '新增分类' : '编辑分类',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1F2937),
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // 保存按钮（右上角）
                  GestureDetector(
                    onTap: _submit,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: _color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '保存',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // 名称输入
              TextField(
                controller: _nameController,
                maxLength: 20,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: '分类名称',
                  filled: true,
                  fillColor: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF3F4F6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  counterText: '',
                ),
              ),
              const SizedBox(height: 16),
              // 类型
              Text(
                '类型',
                style: TextStyle(
                  color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B7280),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _type = 'expense'),
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: _type == 'expense' ? AppColors.expense : (isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF3F4F6)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '支出',
                          style: TextStyle(
                            color: _type == 'expense' ? Colors.white : (isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B7280)),
                            fontSize: 14,
                            fontWeight: _type == 'expense' ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _type = 'income'),
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: _type == 'income' ? AppColors.income : (isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF3F4F6)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '收入',
                          style: TextStyle(
                            color: _type == 'income' ? Colors.white : (isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B7280)),
                            fontSize: 14,
                            fontWeight: _type == 'income' ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 颜色
              Text(
                '颜色',
                style: TextStyle(
                  color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B7280),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: oneKeepCategoryColorPresets.map((preset) {
                  final selected = preset.toARGB32() == _color.toARGB32();
                  return GestureDetector(
                    onTap: () => setState(() => _color = preset),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: preset,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected ? (isDark ? Colors.white : Colors.black) : Colors.transparent,
                          width: selected ? 2.5 : 0,
                        ),
                      ),
                      child: selected ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              // 图标
              Text(
                '图标',
                style: TextStyle(
                  color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B7280),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 52,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: oneKeepCategoryIconKeys.length,
                  itemBuilder: (context, index) {
                    final key = oneKeepCategoryIconKeys[index];
                    final selected = key == _icon;
                    return GestureDetector(
                      onTap: () => setState(() => _icon = key),
                      child: Container(
                        width: 48,
                        height: 48,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: selected ? _color.withValues(alpha: 0.12) : (isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF3F4F6)),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selected ? _color : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          oneKeepIconFont(key) ?? Icons.help_outline,
                          color: selected ? _color : (isDark ? const Color(0xFF8E8E93) : const Color(0xFF9CA3AF)),
                          size: 22,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入分类名称')),
      );
      return;
    }

    Navigator.of(context).pop(
      _CategoryEditorResult(
        name: name,
        icon: _icon,
        type: _type,
        color: oneKeepColorToHex(_color),
      ),
    );
  }
}
