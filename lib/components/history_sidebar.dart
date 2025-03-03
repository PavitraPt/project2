import 'package:flutter/material.dart';

class HistorySidebar extends StatelessWidget {
  final List<Map<String, dynamic>> historyItems;
  final Function(Map<String, dynamic>) onItemSelected;
  final String currency;

  const HistorySidebar({
    super.key,
    required this.historyItems,
    required this.onItemSelected,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        border: Border(
          right: BorderSide(
            color: Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF1B365C),
            child: const Row(
              children: [
                Icon(
                  Icons.history,
                  color: Colors.white,
                ),
                SizedBox(width: 8),
                Text(
                  'Analysis History',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // History List
          Expanded(
            child: ListView.builder(
              itemCount: historyItems.length,
              itemBuilder: (context, index) {
                final item = historyItems[index];
                final DateTime date = item['date'];
                final double netSaving = item['netSaving'];
                final bool isPositive = netSaving >= 0;

                return InkWell(
                  onTap: () => onItemSelected(item),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${date.day}/${date.month}/${date.year}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Net Saving: ${_formatCurrency(netSaving)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isPositive ? Colors.green : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Old Cost: ${_formatCurrency(item['oldCost'])}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          'New Cost: ${_formatCurrency(item['newCost'])}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double value) {
    String formattedValue = value.toStringAsFixed(2);
    if (currency == 'EUR') {
      return '€$formattedValue';
    } else if (currency == 'USD') {
      return '\$$formattedValue';
    } else {
      return '$formattedValue $currency';
    }
  }
}
