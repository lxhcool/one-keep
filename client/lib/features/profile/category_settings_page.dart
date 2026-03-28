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

class CategorySettingsPage extends ConsumerStatefulWidget {
  const CategorySettingsPage({super.key});

  @override
  ConsumerState<CategorySettingsPage> createState() =>
      _CategorySettingsPageState();
}

class _CategorySettingsPageState extends ConsumerState<CategorySettingsPage> {
  String _activeType = 'expense';
  bool _isSaving = false;
  List<Category>? _draftCategories;

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: OneKeepPageBackground(
        variant: OneKeepPageVariant.profile,
        child: SafeArea(
          bottom: false,
          child: categoriesAsync.when(
            data: (items) {
              _hydrateCategories(items);
              final categories = _draftCategories ?? items;
              final filtered = categories
                  .where((item) => item.type == _activeType)
                  .toList();

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: _CategoryPageHeader(
                      activeType: _activeType,
                      onBack: () => Navigator.of(context).maybePop(),
                      onTypeChanged: (value) {
                        setState(() => _activeType = value);
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: filtered.isEmpty
                          ? _EmptyCategoryState(
                              type: _activeType,
                              onAdd: _handleCreate,
                            )
                          : ReorderableListView.builder(
                              padding: const EdgeInsets.only(bottom: 140),
                              itemCount: filtered.length,
                              buildDefaultDragHandles: false,
                              onReorder: (oldIndex, newIndex) =>
                                  _handleReorder(filtered, oldIndex, newIndex),
                              itemBuilder: (context, index) {
                                final category = filtered[index];
                                return Padding(
                                  key: ValueKey(category.id),
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _CategoryCard(
                                    index: index,
                                    category: category,
                                    onEdit: () => _handleEdit(category),
                                    onDelete: () => _handleDelete(category),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
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
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: FilledButton.icon(
            onPressed: _isSaving ? null : _handleCreate,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              backgroundColor: AppColors.teal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            icon: const Icon(Icons.add_rounded, size: 20),
            label: Text(
              _activeType == 'expense' ? '新增支出分类' : '新增收入分类',
              style: oneKeepManrope(
                color: Colors.white,
                size: 15,
                weight: FontWeight.w800,
              ),
            ),
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
    return '${category.id}|${category.name}|${category.icon}|${category.type}';
  }

  Future<void> _handleCreate() async {
    final result = await showModalBottomSheet<_CategoryEditorResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: oneKeepDimOverlay(context),
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
      barrierColor: oneKeepDimOverlay(context),
      builder: (_) => _CategoryEditorSheet(
        initialType: category.type,
        initialName: category.name,
        initialIcon: category.icon,
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
        return AlertDialog(
          backgroundColor: oneKeepSurface(dialogContext),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: oneKeepBorder(dialogContext), width: 0.8),
          ),
          title: Text(
            '删除分类',
            style: oneKeepGrotesk(
              color: oneKeepTextPrimary(dialogContext),
              size: 22,
              weight: FontWeight.w700,
            ),
          ),
          content: Text(
            '删除后，这个分类会从快速记账里移除。已有记账记录的分类不能删除。',
            style: oneKeepInter(
              color: oneKeepTextSecondary(dialogContext),
              size: 14,
              weight: FontWeight.w500,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(backgroundColor: AppColors.expense),
              child: const Text('删除'),
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

class _CategoryPageHeader extends StatelessWidget {
  final String activeType;
  final VoidCallback onBack;
  final ValueChanged<String> onTypeChanged;

  const _CategoryPageHeader({
    required this.activeType,
    required this.onBack,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: onBack,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: oneKeepGlass(context),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: oneKeepBorder(context), width: 0.8),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: oneKeepTextPrimary(context),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '分类设置',
                    style: oneKeepGrotesk(
                      color: oneKeepTextPrimary(context),
                      size: 28,
                      weight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '管理快速记账使用的分类、图标和排序。',
                    style: oneKeepInter(
                      color: oneKeepTextSecondary(context),
                      size: 13,
                      weight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          height: 48,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: oneKeepGlassStrong(context),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: oneKeepBorder(context), width: 0.8),
          ),
          child: Row(
            children: [
              Expanded(
                child: _TypeTab(
                  label: '支出分类',
                  active: activeType == 'expense',
                  tone: AppColors.expense,
                  onTap: () => onTypeChanged('expense'),
                ),
              ),
              Expanded(
                child: _TypeTab(
                  label: '收入分类',
                  active: activeType == 'income',
                  tone: AppColors.income,
                  onTap: () => onTypeChanged('income'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TypeTab extends StatelessWidget {
  final String label;
  final bool active;
  final Color tone;
  final VoidCallback onTap;

  const _TypeTab({
    required this.label,
    required this.active,
    required this.tone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? tone.withValues(alpha: 0.14) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? tone.withValues(alpha: 0.3) : Colors.transparent,
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: oneKeepManrope(
            color: active ? tone : oneKeepTextSecondary(context),
            size: 14,
            weight: active ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final int index;
  final Category category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryCard({
    required this.index,
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final tone = category.type == 'expense'
        ? AppColors.expense
        : AppColors.income;
    return OneKeepGlassCard(
      radius: 24,
      blurSigma: 18,
      fillColor: oneKeepGlass(context),
      borderColor: oneKeepBorder(context),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: tone.withValues(alpha: 0.22),
                width: 0.8,
              ),
            ),
            child: Icon(
              oneKeepResolvedCategoryIcon(
                category.name,
                category.name,
                category.icon,
              ),
              color: tone,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: oneKeepManrope(
                    color: oneKeepTextPrimary(context),
                    size: 16,
                    weight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  oneKeepIconLabel(category.icon),
                  style: oneKeepInter(
                    color: oneKeepTextSecondary(context),
                    size: 12,
                    weight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: Icon(
              Icons.edit_outlined,
              size: 20,
              color: oneKeepTextSecondary(context),
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(
              Icons.delete_outline_rounded,
              size: 20,
              color: AppColors.expense,
            ),
          ),
          ReorderableDragStartListener(
            index: index,
            child: Icon(
              Icons.drag_indicator_rounded,
              size: 22,
              color: oneKeepTextTertiary(context),
            ),
          ),
        ],
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
    final tone = type == 'expense' ? AppColors.expense : AppColors.income;
    return Center(
      child: OneKeepGlassCard(
        radius: 28,
        blurSigma: 22,
        fillColor: oneKeepGlass(context),
        borderColor: oneKeepBorderStrong(context),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: tone.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(Icons.category_outlined, size: 32, color: tone),
            ),
            const SizedBox(height: 16),
            Text(
              type == 'expense' ? '还没有支出分类' : '还没有收入分类',
              style: oneKeepGrotesk(
                color: oneKeepTextPrimary(context),
                size: 22,
                weight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '先添加一组分类，快速记账就能直接使用。',
              textAlign: TextAlign.center,
              style: oneKeepInter(
                color: oneKeepTextSecondary(context),
                size: 13,
                weight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: onAdd,
              style: FilledButton.styleFrom(
                backgroundColor: tone,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('立即新增'),
            ),
          ],
        ),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: OneKeepGlassCard(
          radius: 24,
          blurSigma: 18,
          fillColor: oneKeepGlass(context),
          borderColor: oneKeepBorder(context),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 34,
                color: AppColors.expense,
              ),
              const SizedBox(height: 14),
              Text(
                message,
                textAlign: TextAlign.center,
                style: oneKeepInter(
                  color: oneKeepTextPrimary(context),
                  size: 14,
                  weight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              FilledButton(onPressed: onRetry, child: const Text('重新加载')),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryEditorResult {
  final String name;
  final String icon;
  final String type;

  const _CategoryEditorResult({
    required this.name,
    required this.icon,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {'name': name, 'icon': icon, 'type': type};
  }
}

class _CategoryEditorSheet extends StatefulWidget {
  final String initialType;
  final String initialName;
  final String initialIcon;

  const _CategoryEditorSheet({
    required this.initialType,
    this.initialName = '',
    this.initialIcon = 'a-068_yongcan',
  });

  @override
  State<_CategoryEditorSheet> createState() => _CategoryEditorSheetState();
}

class _CategoryEditorSheetState extends State<_CategoryEditorSheet> {
  late final TextEditingController _nameController;
  late String _type;
  late String _icon;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _type = widget.initialType;
    _icon = widget.initialIcon;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final tone = _type == 'expense' ? AppColors.expense : AppColors.income;

    return OneKeepSheetSurface(
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + bottomInset),
          child: SingleChildScrollView(
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
                      ).withValues(alpha: 0.28),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.initialName.isEmpty ? '新增分类' : '编辑分类',
                  style: oneKeepGrotesk(
                    color: oneKeepTextPrimary(context),
                    size: 24,
                    weight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '设置分类名称、图标和归属类型。',
                  style: oneKeepInter(
                    color: oneKeepTextSecondary(context),
                    size: 13,
                    weight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: tone.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: tone.withValues(alpha: 0.22),
                      width: 0.8,
                    ),
                  ),
                  child: Icon(
                    oneKeepIconFont(_icon) ?? Icons.receipt_long_rounded,
                    color: tone,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _nameController,
                  maxLength: 20,
                  style: oneKeepInter(
                    color: oneKeepTextPrimary(context),
                    size: 14,
                    weight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    labelText: '分类名称',
                    hintText: '例如：通勤、零食、项目奖金',
                    filled: true,
                    fillColor: oneKeepGlassStrong(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(
                        color: oneKeepBorder(context),
                        width: 0.8,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(
                        color: oneKeepBorder(context),
                        width: 0.8,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(
                        color: oneKeepAccent(context),
                        width: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  '分类类型',
                  style: oneKeepManrope(
                    color: oneKeepTextPrimary(context),
                    size: 14,
                    weight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _TypeTab(
                        label: '支出',
                        active: _type == 'expense',
                        tone: AppColors.expense,
                        onTap: () => setState(() => _type = 'expense'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _TypeTab(
                        label: '收入',
                        active: _type == 'income',
                        tone: AppColors.income,
                        onTap: () => setState(() => _type = 'income'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  '选择图标',
                  style: oneKeepManrope(
                    color: oneKeepTextPrimary(context),
                    size: 14,
                    weight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: oneKeepCategoryIconKeys.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    mainAxisExtent: 86,
                  ),
                  itemBuilder: (context, index) {
                    final key = oneKeepCategoryIconKeys[index];
                    final selected = key == _icon;
                    return GestureDetector(
                      onTap: () => setState(() => _icon = key),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: selected
                              ? tone.withValues(alpha: 0.12)
                              : oneKeepGlassStrong(context),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: selected
                                ? tone.withValues(alpha: 0.26)
                                : oneKeepBorder(context),
                            width: 0.8,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              oneKeepIconFont(key) ??
                                  Icons.help_outline_rounded,
                              color: selected
                                  ? tone
                                  : oneKeepTextSecondary(context),
                              size: 22,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              oneKeepIconLabel(key),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: oneKeepInter(
                                color: selected
                                    ? tone
                                    : oneKeepTextSecondary(context),
                                size: 11,
                                weight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: _submit,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: tone,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    widget.initialName.isEmpty ? '创建分类' : '保存修改',
                    style: oneKeepManrope(
                      color: Colors.white,
                      size: 15,
                      weight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入分类名称')));
      return;
    }

    Navigator.of(
      context,
    ).pop(_CategoryEditorResult(name: name, icon: _icon, type: _type));
  }
}
