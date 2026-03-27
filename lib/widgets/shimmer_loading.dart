import 'package:flutter/material.dart';
import '../core/app_theme.dart';

// ── Shimmer Effect ──────────────────────────────────────────────────────────

class Shimmer extends StatefulWidget {
  final Widget child;

  const Shimmer({super.key, required this.child});

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF2A2B45) : const Color(0xFFEEEFF3);
    final midColor = isDark ? const Color(0xFF383958) : const Color(0xFFF8F8FB);
    final highlightColor = isDark ? const Color(0xFF2A2B45) : const Color(0xFFEEEFF3);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [baseColor, midColor, highlightColor],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(-1.5 + 3.0 * _controller.value, -0.3),
              end: Alignment(-0.5 + 3.0 * _controller.value, 0.3),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// ── Shimmer Box ─────────────────────────────────────────────────────────────

class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

// ── Shimmer Circle ──────────────────────────────────────────────────────────

class ShimmerCircle extends StatelessWidget {
  final double size;
  const ShimmerCircle({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}

// ── Overview Shimmer ────────────────────────────────────────────────────────

class OverviewShimmer extends StatelessWidget {
  const OverviewShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 800;
          final padding = isNarrow ? 16.0 : 24.0;

          return SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                if (isNarrow)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      ShimmerBox(width: 200, height: 24),
                      SizedBox(height: 8),
                      ShimmerBox(width: 180, height: 14),
                      SizedBox(height: 14),
                      ShimmerBox(width: 160, height: 34, borderRadius: 20),
                    ],
                  )
                else
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          ShimmerBox(width: 220, height: 24),
                          SizedBox(height: 8),
                          ShimmerBox(width: 200, height: 14),
                        ],
                      ),
                      const Spacer(),
                      const ShimmerBox(width: 160, height: 34, borderRadius: 20),
                      const SizedBox(width: 12),
                      const ShimmerBox(width: 100, height: 38, borderRadius: 8),
                    ],
                  ),
                SizedBox(height: isNarrow ? 16 : 24),

                // Stats cards
                if (isNarrow)
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: List.generate(4, (_) => SizedBox(
                      width: (constraints.maxWidth - padding * 2 - 12) / 2,
                      child: _StatCardShimmer(),
                    )),
                  )
                else
                  Row(
                    children: List.generate(
                      5,
                      (i) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: i < 4 ? 12 : 0),
                          child: _StatCardShimmer(),
                        ),
                      ),
                    ),
                  ),
                SizedBox(height: isNarrow ? 16 : 24),

                // Chart + Activity
                if (isNarrow)
                  Column(
                    children: const [
                      _ChartShimmer(),
                      SizedBox(height: 16),
                      _ActivityShimmer(),
                    ],
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Expanded(flex: 6, child: _ChartShimmer()),
                      SizedBox(width: 16),
                      Expanded(flex: 4, child: _ActivityShimmer()),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCardShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardColorOf(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColorOf(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              ShimmerBox(width: 40, height: 40, borderRadius: 12),
              Spacer(),
              ShimmerCircle(size: 6),
            ],
          ),
          const SizedBox(height: 14),
          const ShimmerBox(width: 60, height: 28, borderRadius: 6),
          const SizedBox(height: 8),
          const ShimmerBox(width: 90, height: 12),
          const SizedBox(height: 4),
          const ShimmerBox(width: 60, height: 10),
        ],
      ),
    );
  }
}

class _ChartShimmer extends StatelessWidget {
  const _ChartShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColorOf(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColorOf(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart header
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ShimmerBox(width: 140, height: 16),
                  SizedBox(height: 6),
                  ShimmerBox(width: 110, height: 12),
                ],
              ),
              const Spacer(),
              const ShimmerBox(width: 120, height: 26, borderRadius: 16),
            ],
          ),
          const SizedBox(height: 28),

          // Chart bars
          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final heights = [0.65, 0.85, 0.45, 0.72, 0.90, 0.55, 0.38];
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ShimmerBox(
                          width: double.infinity,
                          height: 180 * heights[i],
                          borderRadius: 4,
                        ),
                        const SizedBox(height: 8),
                        const ShimmerBox(width: 24, height: 10, borderRadius: 4),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityShimmer extends StatelessWidget {
  const _ActivityShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      constraints: const BoxConstraints(minHeight: 300),
      decoration: BoxDecoration(
        color: AppTheme.cardColorOf(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColorOf(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox(width: 130, height: 16),
          const SizedBox(height: 4),
          const ShimmerBox(width: 100, height: 12),
          const SizedBox(height: 20),

          // Activity items
          ...List.generate(5, (_) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                const ShimmerBox(width: 38, height: 38, borderRadius: 10),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      ShimmerBox(width: 120, height: 13),
                      SizedBox(height: 4),
                      ShimmerBox(width: 70, height: 11),
                    ],
                  ),
                ),
                const ShimmerBox(width: 56, height: 22, borderRadius: 20),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

// ── Table Shimmer ───────────────────────────────────────────────────────────

class TableShimmer extends StatelessWidget {
  final int rows;
  final int columns;

  const TableShimmer({super.key, this.rows = 6, this.columns = 5});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColorOf(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderColorOf(context)),
        ),
        child: Column(
          children: [
            // Table header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: List.generate(
                  columns,
                  (i) => Expanded(
                    flex: i == 0 ? 2 : 1,
                    child: Padding(
                      padding: EdgeInsets.only(right: i < columns - 1 ? 16 : 0),
                      child: ShimmerBox(
                        width: double.infinity,
                        height: 12,
                        borderRadius: 4,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Divider(height: 1, color: AppTheme.borderColorOf(context)),

            // Table rows
            ...List.generate(rows, (rowIndex) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: List.generate(columns, (i) {
                        // First column gets avatar + text
                        if (i == 0) {
                          return Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: Row(
                                children: const [
                                  ShimmerBox(width: 32, height: 32, borderRadius: 8),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: ShimmerBox(width: double.infinity, height: 13, borderRadius: 4),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        // Last column gets a chip-like shape
                        if (i == columns - 1) {
                          return Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: ShimmerBox(
                                width: 60,
                                height: 22,
                                borderRadius: 20,
                              ),
                            ),
                          );
                        }
                        // Middle columns
                        final widths = [0.8, 0.6, 0.7, 0.5, 0.65];
                        final factor = widths[i % widths.length];
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: factor,
                              child: const ShimmerBox(
                                width: double.infinity,
                                height: 13,
                                borderRadius: 4,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  if (rowIndex < rows - 1)
                    Divider(height: 1, color: AppTheme.borderColorOf(context)),
                ],
              );
            }),

            Divider(height: 1, color: AppTheme.borderColorOf(context)),

            // Pagination shimmer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  const ShimmerBox(width: 160, height: 13, borderRadius: 4),
                  const Spacer(),
                  const ShimmerBox(width: 100, height: 13, borderRadius: 4),
                  const SizedBox(width: 12),
                  const ShimmerBox(width: 34, height: 34, borderRadius: 8),
                  const SizedBox(width: 6),
                  const ShimmerBox(width: 34, height: 34, borderRadius: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reports Shimmer ─────────────────────────────────────────────────────────

class ReportsShimmer extends StatelessWidget {
  const ReportsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColorOf(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderColorOf(context)),
        ),
        child: Column(
          children: [
            // Header row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: const [
                  Expanded(flex: 2, child: ShimmerBox(width: double.infinity, height: 12, borderRadius: 4)),
                  SizedBox(width: 16),
                  Expanded(child: ShimmerBox(width: double.infinity, height: 12, borderRadius: 4)),
                  SizedBox(width: 16),
                  Expanded(child: ShimmerBox(width: double.infinity, height: 12, borderRadius: 4)),
                  SizedBox(width: 16),
                  Expanded(child: ShimmerBox(width: double.infinity, height: 12, borderRadius: 4)),
                ],
              ),
            ),
            Divider(height: 1, color: AppTheme.borderColorOf(context)),

            // Rows
            ...List.generate(6, (rowIndex) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      const Expanded(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.only(right: 16),
                          child: ShimmerBox(width: double.infinity, height: 13, borderRadius: 4),
                        ),
                      ),
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: 16),
                          child: ShimmerBox(width: double.infinity, height: 13, borderRadius: 4),
                        ),
                      ),
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: 16),
                          child: ShimmerBox(width: double.infinity, height: 13, borderRadius: 4),
                        ),
                      ),
                      // Progress bar + percentage
                      Expanded(
                        child: Row(
                          children: const [
                            ShimmerBox(width: 60, height: 6, borderRadius: 3),
                            SizedBox(width: 8),
                            ShimmerBox(width: 40, height: 13, borderRadius: 4),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (rowIndex < 5)
                  Divider(height: 1, color: AppTheme.borderColorOf(context)),
              ],
            )),
          ],
        ),
      ),
    );
  }
}
