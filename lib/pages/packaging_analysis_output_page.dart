import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'packaging_analysis_page.dart';

class PackagingAnalysisOutputPage extends StatelessWidget {
  final PackagingData oldPackagingData;
  final PackagingData newPackagingData;
  final double piecePerPackage;
  final List<double> yearlyVolumes;
  final double additionalCosts;
  final String currency;

  const PackagingAnalysisOutputPage({
    super.key,
    required this.oldPackagingData,
    required this.newPackagingData,
    required this.piecePerPackage,
    required this.yearlyVolumes,
    required this.additionalCosts,
    required this.currency,
  });

  // คำนวณต้นทุนบรรจุภัณฑ์ต่อปี
  double _calculateYearlyPackagingCost(
      PackagingData data, double yearlyVolume) {
    double packagesPerYear = yearlyVolume / piecePerPackage;
    return (data.costPerPackage * packagesPerYear) + data.costPerCycle;
  }

  // คำนวณต้นทุนรวมตลอด 6 ปี
  double _calculateTotalPackagingCost() {
    return yearlyVolumes.fold(
      0.0,
      (sum, volume) =>
          sum + _calculateYearlyPackagingCost(newPackagingData, volume),
    );
  }

  // คำนวณ Cost Saving ต่อปี
  double _calculateCostSavingPerYear(double yearlyVolume) {
    double oldCost =
        _calculateYearlyPackagingCost(oldPackagingData, yearlyVolume);
    double newCost =
        _calculateYearlyPackagingCost(newPackagingData, yearlyVolume);
    return oldCost - newCost;
  }

  // คำนวณ Net Saving
  double _calculateNetSaving() {
    double totalSaving = yearlyVolumes.fold(
      0.0,
      (sum, volume) => sum + _calculateCostSavingPerYear(volume),
    );
    return totalSaving - additionalCosts;
  }

  // คำนวณ Breakeven (days)
  double _calculateBreakeven() {
    double dailyCostSaving =
        _calculateCostSavingPerYear(yearlyVolumes[0]) / 240;
    if (dailyCostSaving <= 0) return double.infinity;
    return additionalCosts / dailyCostSaving;
  }

  // Helper method สำหรับ format ตัวเลขตาม currency
  String _formatCurrency(double value, {bool showCurrency = true}) {
    String formattedValue = value.toStringAsFixed(2);
    if (!showCurrency) {
      return formattedValue;
    }

    if (currency == 'EUR') {
      return '€$formattedValue';
    } else if (currency == 'USD') {
      return '\$$formattedValue';
    } else {
      return '$formattedValue $currency';
    }
  }

  // แยก method สำหรับ breakeven โดยเฉพาะ
  Widget _buildBreakevenField(String label, double breakeven) {
    String displayValue = breakeven.isInfinite
        ? 'No breakeven'
        : '${breakeven.toStringAsFixed(1)} days';

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
              controller: TextEditingController(text: displayValue),
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

  // ฟังก์ชันสร้างกราฟเปรียบเทียบ Net Saving ระหว่าง Old และ New
  Widget buildNetSavingComparisonChart(
      double oldNetSaving, double newNetSaving) {
    // หาค่าสูงสุดและต่ำสุดเพื่อกำหนดขอบเขตของกราฟ
    double maxY = oldNetSaving > newNetSaving ? oldNetSaving : newNetSaving;
    double minY = oldNetSaving < newNetSaving ? oldNetSaving : newNetSaving;
    double absMaxY = maxY.abs() > minY.abs() ? maxY.abs() : minY.abs();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Net Saving Comparison',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: BarChart(
            BarChartData(
              // กำหนดขอบเขตกราฟให้สมมาตร
              minY: -absMaxY * 1.2,
              maxY: absMaxY * 1.2,

              // ข้อมูลแท่งกราฟ
              barGroups: [
                // แท่ง Old
                BarChartGroupData(
                  x: 0,
                  barRods: [
                    BarChartRodData(
                      toY: oldNetSaving,
                      color: oldNetSaving >= 0 ? Colors.green : Colors.red,
                      width: 40,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
                // แท่ง New
                BarChartGroupData(
                  x: 1,
                  barRods: [
                    BarChartRodData(
                      toY: newNetSaving,
                      color: newNetSaving >= 0 ? Colors.green : Colors.red,
                      width: 40,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ],

              // กำหนดการแสดงผลของ titles
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          value == 0 ? 'Old' : 'New',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  axisNameWidget: Text(
                    'Net Saving ($currency)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 60,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toStringAsFixed(0),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),

              // แสดงเส้น grid
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.white.withOpacity(0.2),
                    strokeWidth: 1,
                  );
                },
              ),

              // กำหนด border
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.white.withOpacity(0.5)),
              ),

              // กำหนด tooltip
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  tooltipRoundedRadius: 8,
                  tooltipPadding: const EdgeInsets.all(8),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      _formatCurrency(rod.toY),
                      TextStyle(
                        color: rod.toY >= 0 ? Colors.black : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double averageOldCost = yearlyVolumes.fold(
          0.0,
          (sum, volume) =>
              sum + _calculateYearlyPackagingCost(oldPackagingData, volume),
        ) /
        yearlyVolumes.length;

    double averageNewCost = yearlyVolumes.fold(
          0.0,
          (sum, volume) =>
              sum + _calculateYearlyPackagingCost(newPackagingData, volume),
        ) /
        yearlyVolumes.length;

    double costSavingPerYear = averageOldCost - averageNewCost;
    double totalPackagingCost = _calculateTotalPackagingCost();
    double netSaving = _calculateNetSaving();
    double breakeven = _calculateBreakeven();

    // คำนวณ Net Saving สำหรับ Old และ New แบบใหม่
    double oldTotalCost = yearlyVolumes.fold(
      0.0,
      (sum, volume) =>
          sum + _calculateYearlyPackagingCost(oldPackagingData, volume),
    );

    double newTotalCost = yearlyVolumes.fold(
      0.0,
      (sum, volume) =>
          sum + _calculateYearlyPackagingCost(newPackagingData, volume),
    );

    // Net Saving คือผลต่างระหว่าง Old และ New
    double netSavingNew = oldTotalCost - newTotalCost - additionalCosts;

    return Dialog(
      child: Container(
        width: 800,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Packaging Analysis',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B365C),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Results Section
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B365C),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildOutputField(
                            'Old Packaging Cost/Year (Avg)',
                            averageOldCost,
                          ),
                          const SizedBox(height: 8),
                          _buildOutputField(
                            'New Packaging Cost/Year (Avg)',
                            averageNewCost,
                          ),
                          const SizedBox(height: 8),
                          _buildOutputField(
                            'Cost Saving/Year',
                            costSavingPerYear,
                          ),
                          const SizedBox(height: 8),
                          _buildOutputField(
                            'Total Packaging Cost (6 years)',
                            totalPackagingCost,
                          ),
                          const SizedBox(height: 8),
                          _buildOutputField(
                            'Upfront Additional Cost',
                            additionalCosts,
                          ),
                          const SizedBox(height: 8),
                          _buildOutputField(
                            'Net Saving',
                            netSavingNew,
                            textColor:
                                netSavingNew >= 0 ? Colors.black : Colors.red,
                            showCurrency: true,
                          ),
                          const SizedBox(height: 8),
                          _buildBreakevenField('Breakeven', breakeven),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Chart Section - เปลี่ยนเป็นใช้กราฟเปรียบเทียบ
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B365C),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: buildNetSavingComparisonChart(
                          averageOldCost, netSavingNew),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutputField(String label, double value,
      {Color? textColor, bool showCurrency = true}) {
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
              controller: TextEditingController(
                  text: _formatCurrency(value, showCurrency: showCurrency)),
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                border: OutlineInputBorder(borderSide: BorderSide.none),
                disabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
              ),
              style: TextStyle(
                color: textColor ?? Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
