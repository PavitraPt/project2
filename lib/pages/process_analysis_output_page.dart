import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ProcessAnalysisOutputPage extends StatelessWidget {
  final double upfrontCost;
  final double breakeven;
  final double marginDifference;
  final String currency;
  final double totalVolume;
  final double workingDays;

  const ProcessAnalysisOutputPage({
    super.key,
    required this.upfrontCost,
    required this.breakeven,
    required this.marginDifference,
    required this.currency,
    required this.totalVolume,
    required this.workingDays,
  });

  // Format number with currency
  String _formatCurrency(double value) {
    return "$currency ${value.toStringAsFixed(2)}";
  }

  // Calculate net saving points for graph
  List<FlSpot> _calculateNetSavings() {
    List<FlSpot> spots = [];
    double dailySaving = (marginDifference * totalVolume) / workingDays;

    for (int month = 0; month <= 12; month++) {
      double days = month * (workingDays / 12);
      double netSaving = (dailySaving * days) - upfrontCost;
      spots.add(FlSpot(month.toDouble(), netSaving));
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 800,
        height: 800,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Process Analysis Result',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B365C),
              ),
            ),
            const SizedBox(height: 24),

            // Key Metrics
            Row(
              children: [
                // Upfront Cost
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B365C),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Upfront Cost',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatCurrency(upfrontCost),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Breakeven
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B365C),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Breakeven (days)',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          breakeven.isInfinite
                              ? 'No profit'
                              : breakeven.isNegative
                                  ? 'Negative margin'
                                  : '${breakeven.toStringAsFixed(1)} days',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Net Saving Graph
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF1B365C)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Net Saving (1 Year)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B365C),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: true),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 60,
                                getTitlesWidget: (value, meta) {
                                  return Text(_formatCurrency(value),
                                      style: const TextStyle(fontSize: 10));
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value % 1 == 0) {
                                    return Text('Month ${value.toInt()}',
                                        style: const TextStyle(fontSize: 10));
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: true),
                          lineBarsData: [
                            LineChartBarData(
                              spots: _calculateNetSavings(),
                              isCurved: true,
                              color: const Color(0xFF1B365C),
                              barWidth: 2,
                              dotData: const FlDotData(show: false),
                            ),
                          ],
                        ),
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
