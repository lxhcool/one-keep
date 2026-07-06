import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/providers/api_provider.dart';
import '../../core/providers/data_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/category_icons.dart';
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
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF000000)
          : const Color(0xFFF8F8FA),
      body: categoriesAsync.when(
        data: (categories) {
          final expenses = categories
              .where((e) => e.type == 'expense')
              .toList();
          final incomes = categories.where((e) => e.type == 'income').toList();

          return Column(
            children: [
              _buildAppBar(isDark),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  children: [
                    _buildSection(context, isDark, '支出管理', 'expense', expenses),
                    const SizedBox(height: 24),
                    _buildSection(context, isDark, '收入管理', 'income', incomes),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => Column(
          children: [
            _buildAppBar(isDark),
            const Expanded(child: Center(child: CircularProgressIndicator())),
          ],
        ),
        error: (error, _) => Column(
          children: [
            _buildAppBar(isDark),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppColors.expense,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '加载失败\n${ApiClient.readableError(error)}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(categoriesProvider),
                      child: const Text('重试'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isDark) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: oneKeepTextSecondary(context),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Text(
              '分类管理',
              style: oneKeepGrotesk(
                color: oneKeepTextPrimary(context),
                size: 22,
                weight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    bool isDark,
    String title,
    String type,
    List<Category> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Row(
            children: [
              Text(
                title,
                style: oneKeepManrope(
                  color: oneKeepTextPrimary(context),
                  size: 15,
                  weight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color:
                      (type == 'expense' ? AppColors.expense : AppColors.income)
                          .withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${items.length}',
                  style: oneKeepInter(
                    color: type == 'expense'
                        ? AppColors.expense
                        : AppColors.income,
                    size: 12,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03),
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              const columns = 4;
              final itemWidth = constraints.maxWidth / columns;
              return Wrap(
                runSpacing: 16,
                alignment: WrapAlignment.start,
                children: [
                  ...items.map(
                    (cat) => SizedBox(
                      width: itemWidth,
                      child: _buildGridItem(isDark, cat),
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _buildAddButton(isDark, type),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGridItem(bool isDark, Category category) {
    final tone = oneKeepCategoryTone(
      colorHex: category.color,
      categoryId: category.id,
      categoryName: category.name,
      categoryIcon: category.icon,
    );

    return GestureDetector(
      onTap: () => _showEditor(category: category),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Image.asset(
                resolveCategoryIconAsset(
                  category.icon.isNotEmpty ? category.icon : category.name,
                ),
                width: 26,
                height: 26,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.category, color: tone, size: 26),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            category.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: oneKeepInter(
              color: oneKeepTextSecondary(context),
              size: 12,
              weight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(bool isDark, String type) {
    return GestureDetector(
      onTap: _isSaving ? null : () => _showEditor(type: type),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06),
                width: 1,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.add_rounded,
                color: oneKeepTextTertiary(context),
                size: 22,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '添加',
            style: oneKeepInter(
              color: oneKeepTextTertiary(context),
              size: 12,
              weight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditor({Category? category, String? type}) async {
    final result = await Navigator.of(context).push<_CategoryEditorResult>(
      MaterialPageRoute(
        builder: (_) => CategoryEditorPage(
          isEdit: category != null,
          initialType: type ?? category!.type,
          initialName: category?.name ?? '',
          initialIcon: category?.icon ?? 'a-068_yongcan',
          initialColor: category?.color,
        ),
      ),
    );

    if (result == null) return;

    if (result.isDelete && category != null) {
      if (!mounted) return;
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('删除分类'),
          content: Text('确定要删除“${category.name}”吗？此操作不可逆。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('删除', style: TextStyle(color: AppColors.expense)),
            ),
          ],
        ),
      );
      if (confirm != true) return;

      _runMutation(() async {
        await ref
            .read(apiClientProvider)
            .dio
            .delete('/api/categories/${category.id}');
        ref.invalidate(categoriesProvider);
      });
      return;
    }

    _runMutation(() async {
      final api = ref.read(apiClientProvider);
      if (category != null) {
        await api.dio.put(
          '/api/categories/${category.id}',
          data: result.toJson(),
        );
      } else {
        await api.dio.post('/api/categories', data: result.toJson());
      }
      ref.invalidate(categoriesProvider);
    });
  }

  Future<void> _runMutation(Future<void> Function() action) async {
    setState(() => _isSaving = true);
    try {
      await action();
    } on DioException catch (error) {
      if (!mounted) return;
      showOneKeepToast(
        context,
        message: ApiClient.readableError(error, fallback: '操作失败'),
        type: OneKeepToastType.error,
      );
    } catch (_) {
      if (!mounted) return;
      showOneKeepToast(context, message: '操作失败', type: OneKeepToastType.error);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class _CategoryEditorResult {
  final String name;
  final String icon;
  final String type;
  final String color;
  final bool isDelete;

  const _CategoryEditorResult({
    required this.name,
    required this.icon,
    required this.type,
    required this.color,
    this.isDelete = false,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'icon': icon,
    'type': type,
    'color': color,
  };
}

class CategoryEditorPage extends StatefulWidget {
  final bool isEdit;
  final String initialType;
  final String initialName;
  final String initialIcon;
  final String? initialColor;

  const CategoryEditorPage({
    super.key,
    required this.isEdit,
    required this.initialType,
    this.initialName = '',
    this.initialIcon = 'a-068_yongcan',
    this.initialColor,
  });

  @override
  State<CategoryEditorPage> createState() => _CategoryEditorPageState();
}

class _CategoryEditorPageState extends State<CategoryEditorPage> {
  late TextEditingController _nameController;
  late String _icon;
  late Color _color;

  bool _userEditedName = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _icon = widget.initialIcon;
    _color =
        oneKeepParseHexColor(widget.initialColor) ??
        (widget.initialType == 'expense'
            ? AppColors.expense
            : AppColors.income);
    _userEditedName = widget.initialName.isNotEmpty;
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
    final nameLength = _nameController.text.length;
    final canSave = _nameController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF000000)
          : const Color(0xFFF8F8FA),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + bottomInset),
          children: [
            // Header — close & delete
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: oneKeepTextSecondary(context),
                    ),
                  ),
                ),
                Text(
                  widget.isEdit ? '编辑分类' : '添加分类',
                  style: oneKeepManrope(
                    color: oneKeepTextPrimary(context),
                    size: 17,
                    weight: FontWeight.w700,
                  ),
                ),
                if (widget.isEdit)
                  GestureDetector(
                    onTap: () => Navigator.pop(
                      context,
                      const _CategoryEditorResult(
                        name: '',
                        icon: '',
                        type: '',
                        color: '',
                        isDelete: true,
                      ),
                    ),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.expense.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        size: 18,
                        color: AppColors.expense,
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 36),
              ],
            ),
            const SizedBox(height: 24),

            // Preview card — large centered icon + name
            Center(
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: _color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: _color.withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: _icon.isNotEmpty
                          ? Image.asset(
                              resolveCategoryIconAsset(_icon),
                              width: 38,
                              height: 38,
                              errorBuilder: (_, __, ___) =>
                                  Icon(Icons.category, size: 38, color: _color),
                            )
                          : Icon(
                              Icons.add_rounded,
                              size: 32,
                              color: _color.withValues(alpha: 0.4),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Inline editable name
                  SizedBox(
                    width: 160,
                    child: TextField(
                      controller: _nameController,
                      maxLength: 4,
                      textAlign: TextAlign.center,
                      onChanged: (val) {
                        _userEditedName = val.isNotEmpty;
                        setState(() {});
                      },
                      style: oneKeepGrotesk(
                        color: oneKeepTextPrimary(context),
                        size: 20,
                        weight: FontWeight.w700,
                      ),
                      decoration: InputDecoration(
                        hintText: '分类名称',
                        hintStyle: oneKeepGrotesk(
                          color: oneKeepTextTertiary(
                            context,
                          ).withValues(alpha: 0.35),
                          size: 20,
                          weight: FontWeight.w500,
                        ),
                        counterText: '',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 4),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                  Text(
                    '$nameLength / 4',
                    style: oneKeepInter(
                      color: oneKeepTextTertiary(
                        context,
                      ).withValues(alpha: 0.35),
                      size: 12,
                      weight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Icon section header
            Text(
              '选择图标',
              style: oneKeepManrope(
                color: oneKeepTextPrimary(context),
                size: 15,
                weight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),

            // Icon grid — 5 columns with labels
            GridView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 6,
                childAspectRatio: 0.78,
              ),
              itemCount: categoryIconEntries.length,
              itemBuilder: (context, index) {
                final entry = categoryIconEntries[index];
                final isSelected = _icon == entry.key;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _icon = entry.key;
                      // Auto-fill name if user hasn't manually edited
                      if (!_userEditedName) {
                        _nameController.text = entry.label;
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _color.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: isSelected
                          ? Border.all(
                              color: _color.withValues(alpha: 0.3),
                              width: 1.5,
                            )
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          entry.asset,
                          width: 30,
                          height: 30,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.category,
                            color: isSelected
                                ? _color
                                : oneKeepTextTertiary(context),
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry.label,
                          style: oneKeepInter(
                            color: isSelected
                                ? _color
                                : oneKeepTextSecondary(context),
                            size: 11,
                            weight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        child: SafeArea(
          top: false,
          child: OneKeepBouncingCard(
            onTap: canSave
                ? () {
                    final name = _nameController.text.trim();
                    Navigator.pop(
                      context,
                      _CategoryEditorResult(
                        name: name,
                        icon: _icon,
                        type: widget.initialType,
                        color: oneKeepColorToHex(_color),
                      ),
                    );
                  }
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 52,
              width: double.infinity,
              decoration: BoxDecoration(
                color: canSave
                    ? AppColors.teal
                    : (isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.03)),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Text(
                '确认',
                style: oneKeepManrope(
                  color: canSave
                      ? Colors.white
                      : oneKeepTextTertiary(context).withValues(alpha: 0.4),
                  size: 16,
                  weight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
