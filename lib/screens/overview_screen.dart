import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/overview_controller.dart';
import '../core/app_theme.dart';
import '../services/dashboard_service.dart';
import '../widgets/shimmer_loading.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<OverviewController>()) {
      if (!Get.isRegistered<DashboardService>()) {
        Get.put(DashboardService(), permanent: true);
      }
      Get.put(OverviewController());
    }
    final controller = Get.find<OverviewController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return const OverviewShimmer();
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return _ErrorView(
          message: controller.errorMessage.value,
          onRetry: controller.refresh,
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refresh,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 800;
            final isMedium = constraints.maxWidth < 1100;
            final contentPadding = isNarrow ? 16.0 : 24.0;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(contentPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ResponsiveHeader(
                    controller: controller,
                    isNarrow: isNarrow,
                  ),

                  SizedBox(height: isNarrow ? 16 : 24),

                  _ResponsiveStatsCards(
                    controller: controller,
                    isNarrow: isNarrow,
                    isMedium: isMedium,
                  ),

                  SizedBox(height: isNarrow ? 16 : 24),

                  if (isNarrow)
                    Column(
                      children: [
                        _WeeklyChartCard(weeklyData: controller.weeklyData),
                        const SizedBox(height: 16),
                        _TodayActivityCard(activities: controller.todayActivity),
                      ],
                    )
                  else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 6,
                          child: _WeeklyChartCard(weeklyData: controller.weeklyData),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 4,
                          child: _TodayActivityCard(activities: controller.todayActivity),
                        ),
                      ],
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      );
    });
  }
}

// ── Responsive Header ────────────────────────────────────────────────────

class _ResponsiveHeader extends StatelessWidget {
  final OverviewController controller;
  final bool isNarrow;

  const _ResponsiveHeader({required this.controller, required this.isNarrow});

  @override
  Widget build(BuildContext context) {
    if (isNarrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimaryOf(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Real-time attendance statistics',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondaryOf(context),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _AttendanceRateBadge(rate: controller.attendanceRate),
              OutlinedButton.icon(
                onPressed: controller.refresh,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Refresh'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  side: const BorderSide(color: AppTheme.primaryColor),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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
              'Dashboard Overview',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimaryOf(context),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Real-time attendance statistics',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryOf(context),
              ),
            ),
          ],
        ),
        const Spacer(),
        _AttendanceRateBadge(rate: controller.attendanceRate),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: controller.refresh,
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('Refresh'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.primaryColor,
            side: const BorderSide(color: AppTheme.primaryColor),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Responsive Stats Cards ───────────────────────────────────────────────

class _ResponsiveStatsCards extends StatelessWidget {
  final OverviewController controller;
  final bool isNarrow;
  final bool isMedium;

  const _ResponsiveStatsCards({
    required this.controller,
    required this.isNarrow,
    required this.isMedium,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      _StatCardData(
        label: 'Total Employees',
        value: controller.totalEmployees.value,
        icon: Icons.people,
        iconBg: const Color(0xFF1565C0),
        accentColor: const Color(0xFF1565C0),
        subtitle: 'Active staff',
      ),
      _StatCardData(
        label: 'Face Registered',
        value: controller.registeredFaces.value,
        icon: Icons.face_retouching_natural,
        iconBg: const Color(0xFF7B1FA2),
        accentColor: const Color(0xFF7B1FA2),
        subtitle:
            '${controller.totalEmployees.value > 0 ? ((controller.registeredFaces.value / controller.totalEmployees.value) * 100).toStringAsFixed(0) : 0}% enrolled',
      ),
      _StatCardData(
        label: 'Present Today',
        value: controller.presentToday.value,
        icon: Icons.check_circle,
        iconBg: AppTheme.successColor,
        accentColor: AppTheme.successColor,
        subtitle: 'On time',
      ),
      _StatCardData(
        label: 'Late Today',
        value: controller.lateToday.value,
        icon: Icons.schedule,
        iconBg: AppTheme.warningColor,
        accentColor: AppTheme.warningColor,
        subtitle: 'Late arrivals',
      ),
      _StatCardData(
        label: 'Absent Today',
        value: controller.absentToday.value,
        icon: Icons.cancel,
        iconBg: AppTheme.errorColor,
        accentColor: AppTheme.errorColor,
        subtitle: 'Not checked in',
      ),
    ];

    if (isNarrow) {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: cards.map((card) {
          return SizedBox(
            width: (MediaQuery.of(context).size.width - 44) / 2,
            child: _StatCard(data: card),
          );
        }).toList(),
      );
    }

    if (isMedium) {
      return Column(
        children: [
          Row(
            children: cards.sublist(0, 3).map((card) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: card == cards[2] ? 0 : 12),
                child: _StatCard(data: card),
              ),
            )).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ...cards.sublist(3).map((card) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: card == cards.last ? 0 : 12),
                  child: _StatCard(data: card),
                ),
              )),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      );
    }

    return Row(
      children: cards
          .map(
            (card) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: card == cards.last ? 0 : 12,
                ),
                child: _StatCard(data: card),
              ),
            ),
          )
          .toList(),
    );
  }
}

// ── Attendance rate badge ──────────────────────────────────────────────────

class _AttendanceRateBadge extends StatelessWidget {
  final double rate;
  const _AttendanceRateBadge({required this.rate});

  Color get _color {
    if (rate >= 80) return AppTheme.successColor;
    if (rate >= 60) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.trending_up, size: 16, color: _color),
          const SizedBox(width: 6),
          Text(
            '${rate.toStringAsFixed(1)}% Attendance Rate',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats card data & widget ─────────────────────────────────────────────

class _StatCardData {
  final String label;
  final int value;
  final IconData icon;
  final Color iconBg;
  final Color accentColor;
  final String subtitle;

  const _StatCardData({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconBg,
    required this.accentColor,
    required this.subtitle,
  });
}

class _StatCard extends StatelessWidget {
  final _StatCardData data;
  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardColorOf(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColorOf(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: data.iconBg.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(data.icon, color: data.iconBg, size: 20),
              ),
              const Spacer(),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: data.accentColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              data.value.toString(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: data.accentColor,
                height: 1,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryOf(context),
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            data.subtitle,
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondaryOf(context),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Weekly chart card ──────────────────────────────────────────────────────

class _WeeklyChartCard extends StatelessWidget {
  final List<Map<String, dynamic>> weeklyData;
  const _WeeklyChartCard({required this.weeklyData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColorOf(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColorOf(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Attendance Trend',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimaryOf(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Obx(() => Text(
                      'Last ${Get.find<OverviewController>().chartDays.value} days breakdown',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryOf(context),
                      ),
                    )),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _ChartRangeChips(),
                  _ChartLegend(color: AppTheme.primaryColor, label: 'Present'),
                  _ChartLegend(color: AppTheme.warningColor, label: 'Late'),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          if (weeklyData.isEmpty)
            SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  'No attendance data for the past week',
                  style: TextStyle(color: AppTheme.textSecondaryOf(context)),
                ),
              ),
            )
          else
            SizedBox(
              height: 220,
              child: _WeeklyBarChart(weeklyData: weeklyData),
            ),
        ],
      ),
    );
  }
}

class _ChartRangeChips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OverviewController>();
    return Obx(() {
      final current = controller.chartDays.value;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [7, 14, 30].map((days) {
          final isSelected = current == days;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => controller.setChartRange(days),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${days}D',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppTheme.primaryColor,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}

class _ChartLegend extends StatelessWidget {
  final Color color;
  final String label;
  const _ChartLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondaryOf(context),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _WeeklyBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> weeklyData;
  const _WeeklyBarChart({required this.weeklyData});

  @override
  Widget build(BuildContext context) {
    int maxVal = 1;
    for (final d in weeklyData) {
      final p = (d['presentCount'] as int?) ?? 0;
      final l = (d['lateCount'] as int?) ?? 0;
      if (p + l > maxVal) maxVal = p + l;
    }
    maxVal = ((maxVal / 5).ceil() * 5).clamp(5, 999);

    List<BarChartGroupData> groups = [];
    for (int i = 0; i < weeklyData.length; i++) {
      final d = weeklyData[i];
      final present = (d['presentCount'] as int?)?.toDouble() ?? 0;
      final late = (d['lateCount'] as int?)?.toDouble() ?? 0;

      groups.add(BarChartGroupData(
        x: i,
        groupVertically: false,
        barRods: [
          BarChartRodData(
            toY: present,
            color: AppTheme.primaryColor,
            width: 14,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
          BarChartRodData(
            toY: late,
            color: AppTheme.warningColor,
            width: 14,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
        barsSpace: 4,
      ));
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxVal.toDouble(),
        minY: 0,
        barGroups: groups,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxVal / 5).clamp(1, 999).toDouble(),
          getDrawingHorizontalLine: (_) => FlLine(
            color: AppTheme.borderColorOf(context),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= weeklyData.length) {
                  return const SizedBox.shrink();
                }
                final date = weeklyData[idx]['date'] as DateTime;
                final label = DateFormat('E').format(date);
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondaryOf(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
              reservedSize: 28,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: (maxVal / 5).clamp(1, 999).toDouble(),
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondaryOf(context),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppTheme.textPrimary,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final label = rodIndex == 0 ? 'Present' : 'Late';
              return BarTooltipItem(
                '$label\n${rod.toY.toInt()}',
                const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ── Today's activity card ──────────────────────────────────────────────────

class _TodayActivityCard extends StatelessWidget {
  final List<Map<String, dynamic>> activities;
  const _TodayActivityCard({required this.activities});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColorOf(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColorOf(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Activity",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimaryOf(context),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Recent check-ins',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondaryOf(context),
            ),
          ),

          const SizedBox(height: 16),

          if (activities.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 40,
                      color: AppTheme.borderColorOf(context),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No check-ins today yet',
                      style: TextStyle(color: AppTheme.textSecondaryOf(context)),
                    ),
                  ],
                ),
              ),
            )
          else
            ...activities.map((activity) => _ActivityItem(activity: activity)),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final Map<String, dynamic> activity;
  const _ActivityItem({required this.activity});

  Color _statusColor(String status) {
    switch (status) {
      case 'present':
        return AppTheme.successColor;
      case 'late':
        return AppTheme.warningColor;
      case 'absent':
        return AppTheme.errorColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _statusLabel(String status) {
    return status[0].toUpperCase() + status.substring(1);
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '-';
    return DateFormat('hh:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final name = activity['name'] as String? ?? 'Unknown';
    final status = activity['status'] as String? ?? 'unknown';
    final checkInTime = activity['checkInTime'] as DateTime?;
    final initials = name.isNotEmpty
        ? name.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join()
        : '?';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                initials.toUpperCase(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryOf(context),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _formatTime(checkInTime),
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondaryOf(context),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _statusColor(status).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _statusColor(status).withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              _statusLabel(status),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _statusColor(status),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error view ─────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 56, color: AppTheme.errorColor),
            const SizedBox(height: 16),
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
