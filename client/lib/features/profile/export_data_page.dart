import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/providers/api_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/onekeep_ui.dart';
import 'profile_page.dart'; // for OneKeepGlassSheet

// Platform-specific download implementation
//   - Native (default): saves to temp dir & shares via system sheet
//   - Web (dart.library.html): triggers browser download via Blob URL
import 'export_download_impl.dart';

enum ExportFormat { csv, xlsx }

class ExportDataSheet extends ConsumerStatefulWidget {
  const ExportDataSheet({super.key});

  @override
  ConsumerState<ExportDataSheet> createState() => _ExportDataSheetState();
}

class _ExportDataSheetState extends ConsumerState<ExportDataSheet> {
  ExportFormat _format = ExportFormat.csv;
  late DateTime _startMonth;
  late DateTime _endMonth;
  bool _isExporting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startMonth = DateTime(now.year, now.month, 1);
    _endMonth = DateTime(now.year, now.month, 1);
  }

  String _formatMonth(DateTime date) {
    return DateFormat('yyyy-MM').format(date);
  }

  String _displayMonth(DateTime date) {
    return DateFormat('yyyy年M月').format(date);
  }

  Future<void> _pickMonth({required bool isStart}) async {
    final now = DateTime.now();
    final initial = isStart ? _startMonth : _endMonth;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime(now.year, now.month + 1, 0),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppColors.teal),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        final monthDate = DateTime(picked.year, picked.month, 1);
        if (isStart) {
          _startMonth = monthDate;
          if (_startMonth.isAfter(_endMonth)) {
            _endMonth = _startMonth;
          }
        } else {
          _endMonth = monthDate;
          if (_endMonth.isBefore(_startMonth)) {
            _startMonth = _endMonth;
          }
        }
      });
    }
  }

  Future<void> _doExport() async {
    setState(() {
      _isExporting = true;
      _error = null;
    });

    try {
      final api = ref.read(apiClientProvider);
      final startMonth = _formatMonth(_startMonth);
      final endMonth = _formatMonth(_endMonth);
      final isXlsx = _format == ExportFormat.xlsx;
      final endpoint = isXlsx ? '/api/export/xlsx' : '/api/export/csv';
      final ext = isXlsx ? 'xlsx' : 'csv';

      final response = await api.dio.get(
        endpoint,
        queryParameters: {'startMonth': startMonth, 'endMonth': endMonth},
        options: Options(
          responseType: ResponseType.bytes,
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      final bytes = _extractBytes(response.data);
      final filename = 'onekeep-$startMonth-$endMonth.$ext';

      await exportDownload(bytes, filename, ext);

      if (!mounted) return;

      setState(() => _isExporting = false);

      if (!kIsWeb) {
        Navigator.of(context).pop();
      }
      showOneKeepToast(
        context,
        message: '导出成功',
        type: OneKeepToastType.success,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '导出失败：${_readableError(e)}';
          _isExporting = false;
        });
      }
    }
  }

  /// Extract bytes from Dio response data
  Uint8List _extractBytes(dynamic data) {
    if (data is Uint8List) return data;
    if (data is List<int>) return Uint8List.fromList(data);
    throw Exception('无法解析响应数据');
  }

  String _readableError(Object error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 401) return '请重新登录';
      if (statusCode == 400) return '请求参数错误';
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return '网络超时，请重试';
      }
      if (error.type == DioExceptionType.connectionError) {
        return '网络连接失败';
      }
      return '服务器错误（${statusCode ?? '未知'}）';
    }
    return error.toString();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return OneKeepGlassSheet(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 拖拽指示条
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF3C3C3E)
                    : const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            // 标题
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFF0EA5E9,
                    ).withValues(alpha: isDark ? 0.15 : 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.file_download_outlined,
                    size: 22,
                    color: Color(0xFF0EA5E9),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '导出记账数据',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF18181B),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '选择时间范围和格式，导出你的记账记录',
              style: TextStyle(
                color: isDark
                    ? const Color(0xFF8E8E93)
                    : const Color(0xFF6B7280),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 28),

            // ── 时间范围选择 ──
            _buildSectionLabel('时间范围', isDark),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _MonthPickerButton(
                    label: '起始月份',
                    value: _displayMonth(_startMonth),
                    onTap: () => _pickMonth(isStart: true),
                    isDark: isDark,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: isDark
                        ? const Color(0xFF8E8E93)
                        : const Color(0xFF9CA3AF),
                  ),
                ),
                Expanded(
                  child: _MonthPickerButton(
                    label: '结束月份',
                    value: _displayMonth(_endMonth),
                    onTap: () => _pickMonth(isStart: false),
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── 格式选择 ──
            _buildSectionLabel('导出格式', isDark),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _FormatOptionCard(
                    icon: Icons.table_chart_outlined,
                    title: 'CSV',
                    subtitle: '通用表格格式',
                    active: _format == ExportFormat.csv,
                    onTap: () => setState(() => _format = ExportFormat.csv),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FormatOptionCard(
                    icon: Icons.grid_on_rounded,
                    title: 'Excel',
                    subtitle: '带样式表格',
                    active: _format == ExportFormat.xlsx,
                    onTap: () => setState(() => _format = ExportFormat.xlsx),
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ── 错误提示 ──
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.expense.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 16,
                      color: AppColors.expense,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: AppColors.expense,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── 导出按钮 ──
            OneKeepBouncingCard(
              onTap: _isExporting ? null : _doExport,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: _isExporting
                      ? null
                      : const LinearGradient(
                          colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                        ),
                  color: _isExporting
                      ? (isDark
                            ? const Color(0xFF2C2C2E)
                            : const Color(0xFFE5E7EB))
                      : null,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _isExporting
                      ? null
                      : [
                          BoxShadow(
                            color: const Color(
                              0xFF0EA5E9,
                            ).withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isExporting) ...[
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark ? Colors.white70 : const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '正在导出...',
                        style: TextStyle(
                          color: isDark
                              ? Colors.white70
                              : const Color(0xFF6B7280),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ] else ...[
                      const Icon(
                        Icons.file_download_outlined,
                        size: 20,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '导出 ${_format == ExportFormat.csv ? 'CSV' : 'Excel'} 文件',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text, bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          color: isDark ? const Color(0xFFA1A1AA) : const Color(0xFF6B7280),
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _MonthPickerButton extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool isDark;

  const _MonthPickerButton({
    required this.label,
    required this.value,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return OneKeepBouncingCard(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.06),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isDark
                    ? const Color(0xFF8E8E93)
                    : const Color(0xFF9CA3AF),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1D1D1F),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_month_rounded,
                  size: 16,
                  color: isDark
                      ? const Color(0xFF8E8E93)
                      : const Color(0xFF9CA3AF),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FormatOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool active;
  final VoidCallback onTap;
  final bool isDark;

  const _FormatOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.active,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return OneKeepBouncingCard(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: active
              ? (isDark
                    ? const Color(0xFF0EA5E9).withValues(alpha: 0.12)
                    : const Color(0xFF0EA5E9).withValues(alpha: 0.06))
              : (isDark ? const Color(0xFF2C2C2E) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active
                ? const Color(0xFF0EA5E9)
                : (isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.06)),
            width: active ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: active
                    ? const Color(0xFF0EA5E9).withValues(alpha: 0.15)
                    : (isDark
                          ? const Color(0xFF1C1C1F)
                          : const Color(0xFFF3F4F6)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 22,
                color: active
                    ? const Color(0xFF0EA5E9)
                    : (isDark
                          ? const Color(0xFF8E8E93)
                          : const Color(0xFF9CA3AF)),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                color: active
                    ? const Color(0xFF0EA5E9)
                    : (isDark ? Colors.white : const Color(0xFF18181B)),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                color: isDark
                    ? const Color(0xFF8E8E93)
                    : const Color(0xFF9CA3AF),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
