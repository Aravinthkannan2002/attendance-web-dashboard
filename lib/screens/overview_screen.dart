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
                  _FadeSlideIn(
                    delay: 0,
                    child: _ResponsiveHeader(
                      controller: controller,
                      isNarrow: isNarrow,
                    ),
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
                        _FadeSlideIn(
                          delay: 350,
                          child: _WeeklyChartCard(weeklyData: controller.weeklyData),
                        ),
                        const SizedBox(height: 16),
                        _FadeSlideIn(
                          delay: 450,
                          child: _TodayActivityCard(activities: controller.todayActivity),
                        ),
                      ],
                    )
                  else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 6,
                          child: _FadeSlideIn(
                            delay: 350,
                            child: _WeeklyChartCard(weeklyData: controller.weeklyData),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 4,
                          child: _FadeSlideIn(
                            delay: 450,
                            child: _TodayActivityCard(activities: controller.todayActivity),
                          ),
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

// ── Fade + Slide entrance animation ─────────────────────────────────────────

class _FadeSlideIn extends StatefulWidget {
  final Widget child;
  final int delay; // milliseconds

  const _FadeSlideIn({required this.child, this.delay = 0});

  @override
  State<_FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<_FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _offset = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _offset,
        child: widget.child,
      ),
    );
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
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimaryOf(context),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Real-time attendance statistics',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondaryOf(context).withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 16),
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
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimaryOf(context),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Real-time attendance statistics',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryOf(context).withValues(alpha: 0.8),
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
        children: cards.asMap().entries.map((entry) {
          return SizedBox(
            width: (MediaQuery.of(context).size.width - 44) / 2,
            child: _FadeSlideIn(
              delay: 100 + entry.key * 60,
              child: _StatCard(data: entry.value),
            ),
          );
        }).toList(),
      );
    }

    if (isMedium) {
      return Column(
        children: [
          Row(
            children: cards.sublist(0, 3).asMap().entries.map((entry) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: entry.key == 2 ? 0 : 12),
                child: _FadeSlideIn(
                  delay: 100 + entry.key * 60,
                  child: _StatCard(data: entry.value),
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ...cards.sublist(3).asMap().entries.map((entry) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: entry.key == cards.sublist(3).length - 1 ? 0 : 12),
                  child: _FadeSlideIn(
                    delay: 280 + entry.key * 60,
                    child: _StatCard(data: entry.value),
                  ),
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
          .asMap()
          .entries
          .map(
            (entry) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: entry.key == cards.length - 1 ? 0 : 12,
                ),
                child: _FadeSlideIn(
                  delay: 100 + entry.key * 60,
                  child: _StatCard(data: entry.value),
                ),
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

class _StatCard extends StatefulWidget {
  final _StatCardData data;
  const _StatCard({required this.data});

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: _hovering
            ? Matrix4.diagonal3Values(1.01, 1.01, 1.0)
            : Matrix4.identity(),
        transformAlignment: Alignment.center,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              data.accentColor.withValues(alpha: 0.03),
              AppTheme.cardColorOf(context),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border(
            top: BorderSide(color: data.accentColor, width: 2),
            left: BorderSide(color: AppTheme.borderColorOf(context)),
            right: BorderSide(color: AppTheme.borderColorOf(context)),
            bottom: BorderSide(color: AppTheme.borderColorOf(context)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _hovering ? 0.08 : 0.04),
              blurRadius: _hovering ? 16 : 8,
              offset: Offset(0, _hovering ? 4 : 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: data.iconBg.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(data.icon, color: data.iconBg, size: 22),
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
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimaryOf(context),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(() => Text(
                      'Last ${Get.find<OverviewController>().chartDays.value} days breakdown',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondaryOf(context).withValues(alpha: 0.8),
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
            _EmptyState(
              icon: Icons.bar_chart_rounded,
              message: 'No attendance data available',
              submessage: 'Data will appear once employees start checking in.',
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
          BarChartRodData(
            toY: late,
            color: AppTheme.warningColor,
            width: 14,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ],
        barsSpace: 4,
      ));
    }

    final interval = (maxVal / 5).clamp(1, 999).toDouble();

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
          horizontalInterval: interval,
          getDrawingHorizontalLine: (_) => FlLine(
            color: AppTheme.borderColorOf(context).withValues(alpha: 0.5),
            strokeWidth: 0.8,
            dashArray: [4, 4],
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
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondaryOf(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              interval: interval,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondaryOf(context).withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
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
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's Activity",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimaryOf(context),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Recent check-ins',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondaryOf(context).withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              if (activities.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${activities.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          if (activities.isEmpty)
            _EmptyState(
              icon: Icons.access_time_rounded,
              message: 'No check-ins today yet',
              submessage: 'Activity will appear here as employees check in.',
            )
          else
            ...activities.asMap().entries.map((entry) {
              final isLast = entry.key == activities.length - 1;
              return Column(
                children: [
                  _ActivityItem(activity: entry.value),
                  if (!isLast)
                    Divider(
                      height: 1,
                      thickness: 0.5,
                      color: AppTheme.borderColorOf(context).withValues(alpha: 0.5),
                      indent: 50,
                    ),
                ],
              );
            }),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatefulWidget {
  final Map<String, dynamic> activity;
  const _ActivityItem({required this.activity});

  @override
  State<_ActivityItem> createState() => _ActivityItemState();
}

class _ActivityItemState extends State<_ActivityItem> {
  bool _hovering = false;

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

  String _timeAgo(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final activity = widget.activity;
    final name = activity['name'] as String? ?? 'Unknown';
    final status = activity['status'] as String? ?? 'unknown';
    final checkInTime = activity['checkInTime'] as DateTime?;
    final statusClr = _statusColor(status);
    final initials = name.isNotEmpty
        ? name.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join()
        : '?';

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: _hovering
              ? AppTheme.primaryColor.withValues(alpha: 0.03)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    statusClr.withValues(alpha: 0.15),
                    statusClr.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: statusClr.withValues(alpha: 0.2),
                  width: 0.5,
                ),
              ),
              child: Center(
                child: Text(
                  initials.toUpperCase(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: statusClr,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
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
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        _formatTime(checkInTime),
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondaryOf(context),
                        ),
                      ),
                      if (checkInTime != null) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            '\u00B7',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondaryOf(context).withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                        Text(
                          _timeAgo(checkInTime),
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondaryOf(context).withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusClr.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: statusClr.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                _statusLabel(status),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: statusClr,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state widget ─────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String submessage;

  const _EmptyState({
    required this.icon,
    required this.message,
    required this.submessage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: AppTheme.primaryColor.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryOf(context).withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              submessage,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondaryOf(context).withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: AppTheme.errorColor.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimaryOf(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryOf(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
