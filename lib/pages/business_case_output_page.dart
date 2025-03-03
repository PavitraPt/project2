import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BusinessCaseOutputPage extends StatelessWidget {
  final double previousVCM;
  final double newVCM;
  final double vcmImpact;
  final double upfrontCost;
  final double breakeven;
  final double marginDifference;
  final String currency;
  final String unit;
  final double totalVolume;

  const BusinessCaseOutputPage({
    super.key,
    required this.previousVCM,
    required this.newVCM,
    required this.vcmImpact,
    required this.upfrontCost,
    required this.breakeven,
    required this.marginDifference,
    required this.currency,
    required this.unit,
    required this.totalVolume,
  });

  List<FlSpot> _calculateNetSavings() {
    List<FlSpot> spots = [];

    // สร้างจุดบนกราฟโดยใช้ Total Volume เป็นแกน x
    // แบ่งช่วง x เป็น 7 จุด (0 ถึง 6)
    for (int i = 0; i <= 6; i++) {
      // คำนวณ x (Total Volume) ที่เพิ่มขึ้นเป็นสัดส่วน
      double x =
          i * (totalVolume / 6); // แบ่ง Total Volume เป็น 6 ส่วนเท่าๆ กัน

      // คำนวณ y (Net Saving) ตามสมการ y = (Margin Difference × x) - Upfront Cost
      double y = (marginDifference * x) - upfrontCost;

      spots.add(FlSpot(i.toDouble(), y));
    }

    return spots;
  }

  @override
  Widget build(BuildContext context) {
    // คำนวณจุดข้อมูลสำหรับกราฟ
    final List<FlSpot> spots = _calculateNetSavings();

    // หาค่า min และ max ของ Y axis
    double minY = spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
    double maxY = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    // เพิ่มระยะขอบ 10%
    double padding = (maxY - minY).abs() * 0.1;

    return Dialog(
      child: Container(
        width: 800,
        height: 800,
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Business Case',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B365C),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF5B9BD5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // First Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            _buildOutputField('Old VCM [%]'),
                            const SizedBox(height: 16),
                            _buildOutputField('New VCM [%]'),
                            const SizedBox(height: 16),
                            _buildOutputField('VCM Impact [%]'),
                            const SizedBox(height: 16),
                            _buildOutputField('Upfront Cost'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 32),
                      Expanded(
                        child: Column(
                          children: [
                            _buildOutputField('Piece Price Saving\nImpact'),
                            const SizedBox(height: 16),
                            const SizedBox(height: 48), // Spacing for alignment
                            const SizedBox(height: 48), // Spacing for alignment
                            _buildOutputField('Breakeven (days)'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Net Saving',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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
                                  return Text(
                                    '${value.toInt()} $currency',
                                    style: const TextStyle(fontSize: 10),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 22,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    '${((value / 6) * totalVolume).toInt()}',
                                    style: const TextStyle(fontSize: 10),
                                  );
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
                              spots: spots,
                              isCurved: false,
                              color: Colors.blue,
                              barWidth: 2,
                              dotData: const FlDotData(show: false),
                            ),
                          ],
                          minX: 0,
                          maxX: 6,
                          minY: minY - padding,
                          maxY: maxY + padding,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        'Years',
                        style: TextStyle(fontSize: 12),
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

  Widget _buildOutputField(String label) {
    String value = '';
    String suffix = '';

    switch (label) {
      case 'Old VCM [%]':
        value = previousVCM.toStringAsFixed(2);
        suffix = '%';
        break;
      case 'New VCM [%]':
        value = newVCM.toStringAsFixed(2);
        suffix = '%';
        break;
      case 'VCM Impact [%]':
        value = vcmImpact.toStringAsFixed(2);
        suffix = '%';
        break;
      case 'Upfront Cost':
        value = upfrontCost.toStringAsFixed(2);
        suffix = ' $currency';
        break;
      case 'Piece Price Saving\nImpact':
        value = marginDifference.toStringAsFixed(2);
        suffix = ' $currency/$unit';
        break;
      case 'Breakeven (days)':
        value = breakeven.isInfinite
            ? breakeven.isNegative
                ? 'Negative margin'
                : 'No profit'
            : '${breakeven.toStringAsFixed(2)} days';
        break;
    }

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: TextField(
              enabled: false,
              controller: TextEditingController(text: '$value$suffix'),
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                border: OutlineInputBorder(borderSide: BorderSide.none),
                disabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
              ),
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }
}
