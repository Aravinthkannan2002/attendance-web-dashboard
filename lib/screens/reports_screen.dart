import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/reports_controller.dart';
import '../core/app_theme.dart';
import '../services/dashboard_service.dart';
import '../widgets/shimmer_loading.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ReportsController>()) {
      if (!Get.isRegistered<DashboardService>()) {
        Get.put(DashboardService(), permanent: true);
      }
      Get.put(ReportsController());
    }
    final controller = Get.find<ReportsController>();
    final cardBg = AppTheme.cardColorOf(context);
    final border = AppTheme.borderColorOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 800;
        final contentPadding = isNarrow ? 16.0 : 24.0;

        return SingleChildScrollView(
          padding: EdgeInsets.all(contentPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────────
              _ReportsHeader(
                controller: controller,
                isNarrow: isNarrow,
              ),

              SizedBox(height: isNarrow ? 16 : 20),

              // ── Summary cards ───────────────────────────────────────────
              Obx(() {
                final workDays = controller.totalWorkDays;
                final avgRate = controller.avgAttendanceRate;
                final late = controller.totalLate;
                final absent = controller.totalAbsent;

                final cards = [
                  _SummaryCardData('Work Days', '$workDays', Icons.calendar_month, AppTheme.primaryColor),
                  _SummaryCardData('Avg Attendance', '${avgRate.toStringAsFixed(1)}%', Icons.trending_up, AppTheme.successColor),
                  _SummaryCardData('Total Late', '$late', Icons.schedule, AppTheme.warningColor),
                  _SummaryCardData('Total Absent', '$absent', Icons.cancel_outlined, AppTheme.errorColor),
                ];

                if (isNarrow) {
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: cards.map((card) {
                      return SizedBox(
                        width: (MediaQuery.of(context).size.width - 44) / 2,
                        child: _SummaryCard(
                          label: card.label,
                          value: card.value,
                          icon: card.icon,
                          color: card.color,
                          cardBg: cardBg,
                          border: border,
                        ),
                      );
                    }).toList(),
                  );
                }

                return Row(
                  children: cards.asMap().entries.map((entry) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: entry.key < cards.length - 1 ? 12 : 0),
                        child: _SummaryCard(
                          label: entry.value.label,
                          value: entry.value.value,
                          icon: entry.value.icon,
                          color: entry.value.color,
                          cardBg: cardBg,
                          border: border,
                        ),
                      ),
                    );
                  }).toList(),
                );
              }),

              SizedBox(height: isNarrow ? 16 : 20),

              // ── Table ───────────────────────────────────────────────────
              Obx(() {
                if (controller.isLoading.value) {
                  return const TableShimmer(rows: 6, columns: 6);
                }

                if (controller.employeeReports.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 72, horizontal: 24),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: border),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.primaryColor.withValues(alpha: 0.08),
                            ),
                            child: Icon(
                              Icons.assessment_outlined,
                              size: 40,
                              color: AppTheme.primaryColor.withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'No reports available',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimaryOf(context),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'There is no attendance data recorded for this month.\nTry selecting a different month above.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.5,
                              color: AppTheme.textSecondaryOf(context),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth - (contentPadding * 2),
                      ),
                      child: Column(
                        children: [
                          _ReportsTableHeader(),
                          ...controller.employeeReports.asMap().entries.map((entry) {
                            return _ReportRow(
                              report: entry.value,
                              index: entry.key + 1,
                              isEven: entry.key % 2 == 0,
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

// ── Responsive Header ────────────────────────────────────────────────────

class _ReportsHeader extends StatelessWidget {
  final ReportsController controller;
  final bool isNarrow;

  const _ReportsHeader({required this.controller, required this.isNarrow});

  @override
  Widget build(BuildContext context) {
    final txtPrimary = AppTheme.textPrimaryOf(context);
    final txtSecondary = AppTheme.textSecondaryOf(context);

    if (isNarrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Reports',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: txtPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Per-employee attendance summary',
            style: TextStyle(
              fontSize: 13.5,
              color: txtSecondary,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Obx(() => _MonthPicker(
                    month: controller.selectedMonth.value,
                    onPrev: controller.prevMonth,
                    onNext: controller.nextMonth,
                  )),
              _ExportButton(onPressed: controller.exportReportCsv),
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
              'Monthly Reports',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: txtPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Per-employee attendance summary',
              style: TextStyle(
                fontSize: 14,
                color: txtSecondary,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
        const Spacer(),
        Obx(() => _MonthPicker(
              month: controller.selectedMonth.value,
              onPrev: controller.prevMonth,
              onNext: controller.nextMonth,
            )),
        const SizedBox(width: 12),
        _ExportButton(onPressed: controller.exportReportCsv),
      ],
    );
  }
}

// ── Export Button ──────────────────────────────────────────────────────────

class _ExportButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _ExportButton({required this.onPressed});

  @override
  State<_ExportButton> createState() => _ExportButtonState();
}

class _ExportButtonState extends State<_ExportButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.diagonal3Values(_hovered ? 1.03 : 1.0, _hovered ? 1.03 : 1.0, 1.0),
        transformAlignment: Alignment.center,
        child: ElevatedButton.icon(
          onPressed: widget.onPressed,
          icon: const Icon(Icons.download_rounded, size: 17),
          label: const Text('Export CSV'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: AppTheme.successColor,
            elevation: _hovered ? 3 : 0,
            shadowColor: AppTheme.successColor.withValues(alpha: 0.4),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            textStyle: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Summary Card Data ────────────────────────────────────────────────────

class _SummaryCardData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _SummaryCardData(this.label, this.value, this.icon, this.color);
}

// ── Month Picker ──────────────────────────────────────────────────────────

class _MonthPicker extends StatelessWidget {
  final DateTime month;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _MonthPicker({
    required this.month,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final border = AppTheme.borderColorOf(context);
    final txtPrimary = AppTheme.textPrimaryOf(context);
    final cardBg = AppTheme.cardColorOf(context);
    final canNext = !DateTime(month.year, month.month + 1).isAfter(DateTime.now());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MonthNavButton(
            icon: Icons.chevron_left,
            onPressed: onPrev,
            enabled: true,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('MMMM').format(month),
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: txtPrimary,
                  ),
                ),
                Text(
                  DateFormat('yyyy').format(month),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondaryOf(context),
                  ),
                ),
              ],
            ),
          ),
          _MonthNavButton(
            icon: Icons.chevron_right,
            onPressed: canNext ? onNext : null,
            enabled: canNext,
          ),
        ],
      ),
    );
  }
}

class _MonthNavButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool enabled;

  const _MonthNavButton({
    required this.icon,
    required this.onPressed,
    required this.enabled,
  });

  @override
  State<_MonthNavButton> createState() => _MonthNavButtonState();
}

class _MonthNavButtonState extends State<_MonthNavButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _hovered && widget.enabled
                ? (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : AppTheme.primaryColor.withValues(alpha: 0.08))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            widget.icon,
            size: 20,
            color: widget.enabled
                ? AppTheme.textPrimaryOf(context)
                : AppTheme.textSecondaryOf(context).withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}

// ── Summary Card ──────────────────────────────────────────────────────────

class _SummaryCard extends StatefulWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color cardBg;
  final Color border;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.cardBg,
    required this.border,
  });

  @override
  State<_SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<_SummaryCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: Matrix4.diagonal3Values(_hovered ? 1.02 : 1.0, _hovered ? 1.02 : 1.0, 1.0),
        transformAlignment: Alignment.center,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    widget.cardBg,
                    widget.color.withValues(alpha: 0.06),
                  ]
                : [
                    widget.cardBg,
                    widget.color.withValues(alpha: 0.04),
                  ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border(
            top: BorderSide(color: widget.color, width: 2.5),
            left: BorderSide(color: widget.border),
            right: BorderSide(color: widget.border),
            bottom: BorderSide(color: widget.border),
          ),
          boxShadow: [
            BoxShadow(
              color: _hovered
                  ? widget.color.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: _hovered ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.color.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Icon(widget.icon, color: widget.color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.value,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: widget.color,
                      ),
                    ),
                  ),
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryOf(context),
                    ),
                    overflow: TextOverflow.ellipsis,
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

// ── Table ──────────────────────────────────────────────────────────────────

class _ReportsTableHeader extends StatelessWidget {
  const _ReportsTableHeader();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerBg = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : AppTheme.primaryColor.withValues(alpha: 0.05);
    final style = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: AppTheme.textSecondaryOf(context),
      letterSpacing: 0.8,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: headerBg,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderColorOf(context)),
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 40, child: Text('#', style: style)),
          SizedBox(width: 180, child: Text('EMPLOYEE NAME', style: style)),
          SizedBox(width: 120, child: Text('EMP ID', style: style)),
          SizedBox(width: 80, child: Text('PRESENT', style: style)),
          SizedBox(width: 60, child: Text('LATE', style: style)),
          SizedBox(width: 70, child: Text('ABSENT', style: style)),
          SizedBox(width: 120, child: Text('WORKING HOURS', style: style)),
          SizedBox(width: 160, child: Text('ATTENDANCE RATE', style: style)),
        ],
      ),
    );
  }
}

class _ReportRow extends StatefulWidget {
  final EmployeeReport report;
  final int index;
  final bool isEven;

  const _ReportRow({required this.report, required this.index, required this.isEven});

  @override
  State<_ReportRow> createState() => _ReportRowState();
}

class _ReportRowState extends State<_ReportRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    final txtPrimary = AppTheme.textPrimaryOf(context);
    final txtSecondary = AppTheme.textSecondaryOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final h = report.totalWorkingHours.inHours;
    final m = report.totalWorkingHours.inMinutes.remainder(60);
    final hoursStr = h > 0 ? '${h}h ${m}m' : (m > 0 ? '${m}m' : '-');
    final rateColor = report.attendanceRate >= 90
        ? AppTheme.successColor
        : report.attendanceRate >= 75
            ? const Color(0xFF66BB6A)
            : report.attendanceRate >= 60
                ? AppTheme.warningColor
                : AppTheme.errorColor;

    final stripeBg = widget.isEven
        ? Colors.transparent
        : (isDark ? Colors.white.withValues(alpha: 0.025) : Colors.black.withValues(alpha: 0.02));
    final hoverBg = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : AppTheme.primaryColor.withValues(alpha: 0.05);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: _hovered ? hoverBg : stripeBg,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderColorOf(context).withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text('${widget.index}', style: TextStyle(fontSize: 13, color: txtSecondary)),
          ),
          SizedBox(
            width: 180,
            child: Text(
              report.name,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: txtPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 120,
            child: Text(
              report.employeeId.isNotEmpty ? report.employeeId : '-',
              style: TextStyle(fontSize: 12, color: txtSecondary, fontFamily: 'monospace'),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text('${report.presentDays}', style: TextStyle(fontSize: 13, color: AppTheme.successColor, fontWeight: FontWeight.w600)),
          ),
          SizedBox(
            width: 60,
            child: Text('${report.lateDays}', style: TextStyle(fontSize: 13, color: AppTheme.warningColor, fontWeight: FontWeight.w600)),
          ),
          SizedBox(
            width: 70,
            child: Text('${report.absentDays}', style: TextStyle(fontSize: 13, color: AppTheme.errorColor, fontWeight: FontWeight.w600)),
          ),
          SizedBox(
            width: 120,
            child: Text(hoursStr, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: txtPrimary)),
          ),
          SizedBox(
            width: 160,
            child: Tooltip(
              message: '${report.attendanceRate.toStringAsFixed(1)}% attendance',
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: rateColor.withValues(alpha: 0.18),
                      boxShadow: [
                        BoxShadow(
                          color: rateColor.withValues(alpha: 0.1),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: (report.attendanceRate / 100).clamp(0, 1),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          gradient: LinearGradient(
                            colors: [
                              rateColor,
                              rateColor.withValues(alpha: 0.8),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${report.attendanceRate.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: rateColor,
                    ),
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
}
