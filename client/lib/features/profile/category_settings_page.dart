import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  ConsumerState<CategorySettingsPage> createState() => _CategorySettingsPageState();
}

class _CategorySettingsPageState extends ConsumerState<CategorySettingsPage> {
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7),
      body: categoriesAsync.when(
              data: (categories) {
                final expenses = categories.where((e) => e.type == 'expense').toList();
                final incomes = categories.where((e) => e.type == 'income').toList();

                return Column(
                  children: [
                    _buildAppBar(isDark),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
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
                           Icon(Icons.error_outline, size: 48, color: AppColors.expense),
                           const SizedBox(height: 16),
                           Text('加载失败\n${ApiClient.readableError(error)}', textAlign: TextAlign.center),
                           const SizedBox(height: 16),
                           ElevatedButton(
                             onPressed: () => ref.invalidate(categoriesProvider),
                             child: const Text('重试'),
                           )
                         ]
                       )
                     )
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
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20,
                  color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              '分类管理',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, bool isDark, String title, String type, List<Category> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white.withValues(alpha: 0.9) : const Color(0xFF1C1C1E),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.02),
                blurRadius: 16,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth / 4;
              return Wrap(
                runSpacing: 24,
                alignment: WrapAlignment.start,
                children: [
                  ...items.map((cat) => SizedBox(width: itemWidth, child: _buildGridItem(isDark, cat))),
                  SizedBox(width: itemWidth, child: _buildAddButton(isDark, type)),
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
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: tone.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      oneKeepIconFont(category.icon) ?? Icons.category,
                      color: tone,
                      size: 24,
                    ),
                  ),
                ),
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF3C3C3E) : const Color(0xFFE5E5EA),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.more_horiz,
                      size: 10,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? Colors.white.withValues(alpha: 0.85) : const Color(0xFF3C3C43),
                fontSize: 12,
                fontWeight: FontWeight.w500,
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
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF3C3C3E) : const Color(0xFFE5E5EA),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.add,
                  color: isDark ? Colors.white54 : const Color(0xFF8E8E93),
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '添加',
              style: TextStyle(
                color: isDark ? Colors.white54 : const Color(0xFF8E8E93),
                fontSize: 12,
                fontWeight: FontWeight.w500,
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
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true), 
              child: Text('删除', style: TextStyle(color: AppColors.expense)),
            ),
          ],
        ),
      );
      if (confirm != true) return;
      
      _runMutation(() async {
        await ref.read(apiClientProvider).dio.delete('/api/categories/${category.id}');
        ref.invalidate(categoriesProvider);
      });
      return;
    }

    _runMutation(() async {
      final api = ref.read(apiClientProvider);
      if (category != null) {
        await api.dio.put('/api/categories/${category.id}', data: result.toJson());
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ApiClient.readableError(error, fallback: '操作失败'))),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('操作失败')));
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

  Map<String, dynamic> toJson() => {'name': name, 'icon': icon, 'type': type, 'color': color};
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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
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
    final nameLength = _nameController.text.length;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
          children: [
            // 独立设计的大标题头部
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close_rounded, size: 20, color: isDark ? Colors.white : const Color(0xFF1C1C1E)),
                  ),
                ),
                if (widget.isEdit)
                  GestureDetector(
                    onTap: () => Navigator.pop(context, const _CategoryEditorResult(name: '', icon: '', type: '', color: '', isDelete: true)),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.expense.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.expense),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.isEdit ? '编辑分类' : '添加分类',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                fontSize: 34,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 40),
            // 分类名称输入区域
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '分类名称',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      maxLength: 4,
                      onChanged: (val) => setState(() {}),
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: '不要与已有类型名重复',
                        hintStyle: TextStyle(
                          color: isDark ? const Color(0xFF5C5C5E) : const Color(0xFFC7C7CC),
                          fontSize: 16,
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
                  const SizedBox(width: 8),
                  Text(
                    '$nameLength/4',
                    style: TextStyle(
                      color: isDark ? const Color(0xFF5C5C5E) : const Color(0xFFC7C7CC),
                      fontSize: 14,
                    ),
                  )
                ],
              ),
            ),
              const SizedBox(height: 32),

              // 分类图标
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '分类图标',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '请点击选择下方图标',
                    style: TextStyle(
                      color: isDark ? const Color(0xFF5C5C5E) : const Color(0xFFC7C7CC),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 图标网格
              GridView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 20,
                ),
                itemCount: oneKeepCategoryIconKeys.length,
                itemBuilder: (context, index) {
                  final key = oneKeepCategoryIconKeys[index];
                  final isSelected = _icon == key;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _icon = key);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected ? _color.withValues(alpha: 0.12) : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        oneKeepIconFont(key) ?? Icons.category,
                        color: isSelected ? _color : (isDark ? const Color(0xFF5C5C5E) : const Color(0xFF999999)),
                        size: 28,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 72), // extra space for bottom bar
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: SafeArea(
          top: false,
          child: GestureDetector(
            onTap: () {
              final name = _nameController.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(context, _CategoryEditorResult(name: name, icon: _icon, type: widget.initialType, color: oneKeepColorToHex(_color)));
            },
            child: OneKeepBouncingCard(
              onTap: () {
                final name = _nameController.text.trim();
                if (name.isEmpty) return;
                Navigator.pop(context, _CategoryEditorResult(name: name, icon: _icon, type: widget.initialType, color: oneKeepColorToHex(_color)));
              },
              child: Container(
                height: 52,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _nameController.text.isEmpty 
                      ? (isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA)) 
                      : const Color(0xFF2563EB).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: _nameController.text.isEmpty 
                        ? Colors.transparent 
                        : const Color(0xFF2563EB),
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '确认',
                  style: TextStyle(
                    color: _nameController.text.isEmpty 
                        ? (isDark ? const Color(0xFF5C5C5E) : const Color(0xFFC7C7CC)) 
                        : const Color(0xFF2563EB),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
