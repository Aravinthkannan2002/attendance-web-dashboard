import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/attendance_controller.dart';
import '../core/app_theme.dart';
import '../models/attendance_model.dart';
import '../services/dashboard_service.dart';
import '../widgets/shimmer_loading.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AttendanceController>()) {
      if (!Get.isRegistered<DashboardService>()) {
        Get.put(DashboardService(), permanent: true);
      }
      Get.put(AttendanceController());
    }
    final controller = Get.find<AttendanceController>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 800;
        final contentPadding = isNarrow ? 16.0 : 24.0;

        return SingleChildScrollView(
          padding: EdgeInsets.all(contentPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AttendanceHeader(controller: controller, isNarrow: isNarrow),
              SizedBox(height: isNarrow ? 12 : 16),

              Obx(() => _SummaryChips(
                total: controller.records.length,
                present: controller.presentCount,
                lateCount: controller.lateCount,
                absent: controller.absentCount,
                isNarrow: isNarrow,
              )),
              SizedBox(height: isNarrow ? 16 : 20),

              Obx(() {
                if (controller.isLoading.value) {
                  return const TableShimmer(rows: 6, columns: 6);
                }

                if (controller.errorMessage.value.isNotEmpty) {
                  return _ErrorCard(
                    message: controller.errorMessage.value,
                    onRetry: controller.refresh,
                  );
                }

                if (controller.records.isEmpty) {
                  return _EmptyState();
                }

                return _AttendanceTableCard(controller: controller);
              }),
            ],
          ),
        );
      },
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────

class _AttendanceHeader extends StatefulWidget {
  final AttendanceController controller;
  final bool isNarrow;
  const _AttendanceHeader({required this.controller, required this.isNarrow});

  @override
  State<_AttendanceHeader> createState() => _AttendanceHeaderState();
}

class _AttendanceHeaderState extends State<_AttendanceHeader> {
  late DateTime _from;
  late DateTime _to;

  @override
  void initState() {
    super.initState();
    _from = widget.controller.fromDate.value;
    _to = widget.controller.toDate.value;
  }

  Future<void> _pickFrom() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _from,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme:
              const ColorScheme.light(primary: AppTheme.primaryColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _from = picked);
  }

  Future<void> _pickTo() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _to,
      firstDate: _from,
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme:
              const ColorScheme.light(primary: AppTheme.primaryColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _to = picked);
  }

  String _fmt(DateTime dt) => DateFormat('MMM d, yyyy').format(dt);

  @override
  Widget build(BuildContext context) {
    if (widget.isNarrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attendance Records',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimaryOf(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'View and export attendance history',
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondaryOf(context)),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _DatePickerButton(label: 'From', value: _fmt(_from), onTap: _pickFrom),
              Icon(Icons.arrow_forward, size: 14, color: AppTheme.textSecondaryOf(context)),
              _DatePickerButton(label: 'To', value: _fmt(_to), onTap: _pickTo),
              ElevatedButton.icon(
                onPressed: () => widget.controller.applyFilter(_from, _to),
                icon: const Icon(Icons.filter_alt_outlined, size: 16),
                label: const Text('Apply'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
              OutlinedButton.icon(
                onPressed: widget.controller.exportCsv,
                icon: const Icon(Icons.download_outlined, size: 16),
                label: const Text('Export CSV'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.successColor,
                  side: const BorderSide(color: AppTheme.successColor),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendance Records',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimaryOf(context),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'View and export attendance history',
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondaryOf(context)),
            ),
          ],
        ),
        const Spacer(),
        _DatePickerButton(label: 'From', value: _fmt(_from), onTap: _pickFrom),
        const SizedBox(width: 8),
        Icon(Icons.arrow_forward, size: 14, color: AppTheme.textSecondaryOf(context)),
        const SizedBox(width: 8),
        _DatePickerButton(label: 'To', value: _fmt(_to), onTap: _pickTo),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: () => widget.controller.applyFilter(_from, _to),
          icon: const Icon(Icons.filter_alt_outlined, size: 16),
          label: const Text('Apply'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
        ),
        const SizedBox(width: 10),
        OutlinedButton.icon(
          onPressed: widget.controller.exportCsv,
          icon: const Icon(Icons.download_outlined, size: 16),
          label: const Text('Export CSV'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.successColor,
            side: const BorderSide(color: AppTheme.successColor),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }
}

class _DatePickerButton extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  const _DatePickerButton({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.cardColorOf(context),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.borderColorOf(context)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 14,
              color: AppTheme.textSecondaryOf(context),
            ),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.textSecondaryOf(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textPrimaryOf(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Summary chips ──────────────────────────────────────────────────────────

class _SummaryChips extends StatelessWidget {
  final int total;
  final int present;
  final int lateCount;
  final int absent;
  final bool isNarrow;
  const _SummaryChips({
    required this.total,
    required this.present,
    required this.lateCount,
    required this.absent,
    required this.isNarrow,
  });

  @override
  Widget build(BuildContext context) {
    final chips = [
      _SummaryChip(label: 'Total Records', count: total, color: AppTheme.primaryColor, icon: Icons.list_alt),
      _SummaryChip(label: 'Present', count: present, color: AppTheme.successColor, icon: Icons.check_circle_outline),
      _SummaryChip(label: 'Late', count: lateCount, color: AppTheme.warningColor, icon: Icons.schedule),
      _SummaryChip(label: 'Absent', count: absent, color: AppTheme.errorColor, icon: Icons.cancel_outlined),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: chips,
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;
  const _SummaryChip({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            '$count $label',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Table card ─────────────────────────────────────────────────────────────

class _AttendanceTableCard extends StatelessWidget {
  final AttendanceController controller;
  const _AttendanceTableCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppTheme.cardColorOf(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColorOf(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width - 80,
              ),
              child: Column(
                children: [
                  _TableHeader(),
                  Obx(() {
                    final rows = controller.paginatedRecords;
                    return Column(
                      children: rows.asMap().entries.map((entry) {
                        return _AttendanceRow(
                          record: entry.value,
                          isEven: entry.key % 2 == 0,
                        );
                      }).toList(),
                    );
                  }),
                ],
              ),
            ),
          ),

          Divider(height: 1, color: AppTheme.borderColorOf(context)),

          Obx(() => _PaginationBar(
                currentPage: controller.currentPage.value,
                totalPages: controller.totalPages,
                totalItems: controller.records.length,
                pageSize: AttendanceController.pageSize,
                hasPrev: controller.hasPrevPage,
                hasNext: controller.hasNextPage,
                onPrev: controller.prevPage,
                onNext: controller.nextPage,
              )),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerBg = isDark
        ? Colors.white.withValues(alpha: 0.04)
        : AppTheme.primaryColor.withValues(alpha: 0.03);
    final style = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: AppTheme.textSecondaryOf(context),
      letterSpacing: 0.8,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: headerBg,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderColorOf(context)),
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text('DATE', style: style)),
          SizedBox(width: 160, child: Text('EMPLOYEE NAME', style: style)),
          SizedBox(width: 100, child: Text('EMP ID', style: style)),
          SizedBox(width: 100, child: Text('CHECK IN', style: style)),
          SizedBox(width: 100, child: Text('CHECK OUT', style: style)),
          SizedBox(width: 80, child: Text('BREAK', style: style)),
          SizedBox(width: 120, child: Text('WORKING HOURS', style: style)),
          SizedBox(width: 80, child: Text('STATUS', style: style)),
        ],
      ),
    );
  }
}

class _AttendanceRow extends StatefulWidget {
  final AttendanceModel record;
  final bool isEven;
  const _AttendanceRow({required this.record, required this.isEven});

  @override
  State<_AttendanceRow> createState() => _AttendanceRowState();
}

class _AttendanceRowState extends State<_AttendanceRow> {
  bool _hovered = false;

  AttendanceModel get record => widget.record;

  String _fmt(DateTime? dt) {
    if (dt == null) return '-';
    return DateFormat('hh:mm a').format(dt);
  }

  String _fmtDate(DateTime dt) => DateFormat('MMM d, yyyy').format(dt);

  String _durationStr(Duration d) {
    if (d.inSeconds <= 0) return '-';
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  Color _statusColor(AttendanceStatus s) {
    switch (s) {
      case AttendanceStatus.present:
        return AppTheme.successColor;
      case AttendanceStatus.late:
        return AppTheme.warningColor;
      case AttendanceStatus.absent:
        return AppTheme.errorColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(record.status);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stripeBg = widget.isEven
        ? Colors.transparent
        : (isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.015));
    final hoverBg = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : AppTheme.primaryColor.withValues(alpha: 0.04);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: _hovered ? hoverBg : stripeBg,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderColorOf(context).withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              _fmtDate(record.date),
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textPrimaryOf(context),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(
            width: 160,
            child: Row(
              children: [
                _Avatar(name: record.employeeName ?? '?'),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    record.employeeName ?? '-',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimaryOf(context),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              record.employeeId?.isNotEmpty == true ? record.employeeId! : '-',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondaryOf(context),
                fontFamily: 'monospace',
              ),
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              _fmt(record.checkInTime),
              style: TextStyle(fontSize: 13, color: AppTheme.textPrimaryOf(context)),
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              _fmt(record.checkOutTime),
              style: TextStyle(fontSize: 13, color: AppTheme.textPrimaryOf(context)),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              _durationStr(record.breakDuration),
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondaryOf(context)),
            ),
          ),
          SizedBox(
            width: 120,
            child: Text(
              _durationStr(record.workingDuration),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryOf(context),
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Text(
                record.statusLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  const _Avatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final initials = name.isNotEmpty
        ? name.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join()
        : '?';
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          initials.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryColor,
          ),
        ),
      ),
    );
  }
}

// ── Pagination bar ─────────────────────────────────────────────────────────

class _PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int pageSize;
  final bool hasPrev;
  final bool hasNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _PaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.pageSize,
    required this.hasPrev,
    required this.hasNext,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final from = (currentPage * pageSize + 1).clamp(1, totalItems);
    final to = ((currentPage + 1) * pageSize).clamp(1, totalItems);
    final isNarrow = MediaQuery.of(context).size.width < 600;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        alignment: WrapAlignment.spaceBetween,
        children: [
          Text(
            'Showing $from\u2013$to of $totalItems records',
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondaryOf(context)),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isNarrow) ...[
                Text(
                  'Page ${currentPage + 1} of $totalPages',
                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondaryOf(context)),
                ),
                const SizedBox(width: 12),
              ],
              _PageButton(icon: Icons.chevron_left, enabled: hasPrev, onTap: onPrev),
              const SizedBox(width: 6),
              _PageButton(icon: Icons.chevron_right, enabled: hasNext, onTap: onNext),
            ],
          ),
        ],
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _PageButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.borderColorOf(context)),
          borderRadius: BorderRadius.circular(8),
          color: enabled ? AppTheme.cardColorOf(context) : AppTheme.surfaceColorOf(context),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? AppTheme.textPrimaryOf(context) : AppTheme.textSecondaryOf(context),
        ),
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
      decoration: BoxDecoration(
        color: AppTheme.cardColorOf(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColorOf(context)),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.event_busy, size: 56, color: AppTheme.borderColorOf(context)),
            const SizedBox(height: 16),
            Text(
              'No attendance records found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondaryOf(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Try adjusting the date range filter',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondaryOf(context)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error card ─────────────────────────────────────────────────────────────

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppTheme.cardColorOf(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColorOf(context)),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.error_outline,
                size: 48, color: AppTheme.errorColor),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(color: AppTheme.textSecondaryOf(context)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
