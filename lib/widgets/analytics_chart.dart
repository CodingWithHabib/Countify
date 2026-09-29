import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme_colors.dart';

class AnalyticsChart extends StatelessWidget {
  final int increaseCount;
  final int decreaseCount;
  final int resetCount;

  const AnalyticsChart({
    super.key,
    required this.increaseCount,
    required this.decreaseCount,
    required this.resetCount,
  });

  int get total => increaseCount + decreaseCount + resetCount;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final double maxVal = [
      increaseCount,
      decreaseCount,
      resetCount,
      5,
    ].reduce((a, b) => a > b ? a : b).toDouble();

    final double maxYWithPadding = maxVal * 1.25;
    final double intervalStep = (maxYWithPadding / 4).clamp(1.0, 10000.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.blue.withOpacity(0.25), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(isDark ? 0.12 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.bar_chart_rounded,
                      color: Color(0xFF3B82F6),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Action Volume Chart",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colors.primaryText,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.2)),
                ),
                child: Text(
                  "$total Total",
                  style: const TextStyle(
                    color: Color(0xFF3B82F6),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          AspectRatio(
            aspectRatio: 1.7,
            child: BarChart(
              BarChartData(
                maxY: maxYWithPadding,
                alignment: BarChartAlignment.spaceAround,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: intervalStep,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: (isDark ? Colors.white : Colors.black).withOpacity(0.06),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) =>
                        isDark ? const Color(0xFF0F172A) : Colors.black87,
                    tooltipPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final title = switch (group.x) {
                        0 => "Increments",
                        1 => "Decrements",
                        2 => "Resets",
                        _ => "",
                      };
                      final count = rod.toY.toInt();
                      final pct = total > 0
                          ? ((count / total) * 100).toStringAsFixed(1)
                          : "0.0";
                      return BarTooltipItem(
                        "$title\n",
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        children: [
                          TextSpan(
                            text: "$count actions ($pct%)",
                            style: const TextStyle(
                              color: Color(0xFF60A5FA),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: intervalStep,
                      getTitlesWidget: (value, meta) {
                        if (value == 0 || value > maxYWithPadding) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: colors.secondaryText,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (value, meta) {
                        final String label;
                        final Color labelColor;
                        final IconData labelIcon;

                        switch (value.toInt()) {
                          case 0:
                            label = "Increase";
                            labelColor = const Color(0xFF10B981);
                            labelIcon = Icons.arrow_upward_rounded;
                            break;
                          case 1:
                            label = "Decrease";
                            labelColor = const Color(0xFFEF4444);
                            labelIcon = Icons.arrow_downward_rounded;
                            break;
                          case 2:
                            label = "Reset";
                            labelColor = const Color(0xFFF59E0B);
                            labelIcon = Icons.refresh_rounded;
                            break;
                          default:
                            return const SizedBox.shrink();
                        }

                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(labelIcon, size: 14, color: labelColor),
                              const SizedBox(width: 4),
                              Text(
                                label,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: colors.primaryText,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  // Increase Bar
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: increaseCount.toDouble(),
                        gradient: const LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Color(0xFF059669),
                            Color(0xFF34D399),
                          ],
                        ),
                        width: 26,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxYWithPadding,
                          color: const Color(0xFF10B981).withOpacity(0.08),
                        ),
                      ),
                    ],
                  ),
                  // Decrease Bar
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: decreaseCount.toDouble(),
                        gradient: const LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Color(0xFFDC2626),
                            Color(0xFFF87171),
                          ],
                        ),
                        width: 26,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxYWithPadding,
                          color: const Color(0xFFEF4444).withOpacity(0.08),
                        ),
                      ),
                    ],
                  ),
                  // Reset Bar
                  BarChartGroupData(
                    x: 2,
                    barRods: [
                      BarChartRodData(
                        toY: resetCount.toDouble(),
                        gradient: const LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Color(0xFFD97706),
                            Color(0xFFFBBF24),
                          ],
                        ),
                        width: 26,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxYWithPadding,
                          color: const Color(0xFFF59E0B).withOpacity(0.08),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Legend Pills with Percentage Shares (Wrapped to prevent any overflow)
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildLegendPill(
                  label: "Increase",
                  count: increaseCount,
                  total: total,
                  color: const Color(0xFF10B981),
                  colors: colors,
                ),
                _buildLegendPill(
                  label: "Decrease",
                  count: decreaseCount,
                  total: total,
                  color: const Color(0xFFEF4444),
                  colors: colors,
                ),
                _buildLegendPill(
                  label: "Reset",
                  count: resetCount,
                  total: total,
                  color: const Color(0xFFF59E0B),
                  colors: colors,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendPill({
    required String label,
    required int count,
    required int total,
    required Color color,
    required AppThemeColors colors,
  }) {
    final pct = total > 0 ? ((count / total) * 100).toInt() : 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            "$label $pct%",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: colors.primaryText,
            ),
          ),
        ],
      ),
    );
  }
}
