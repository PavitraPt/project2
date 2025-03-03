import 'package:flutter/material.dart';
import 'dart:math';
import 'business_case_output_page.dart';

class MaterialAnalysisPage extends StatefulWidget {
  const MaterialAnalysisPage({super.key});

  @override
  State<MaterialAnalysisPage> createState() => _MaterialAnalysisPageState();
}

class _MaterialAnalysisPageState extends State<MaterialAnalysisPage> {
  // Controllers
  final _previousCostController = TextEditingController();
  final _previousSalesController = TextEditingController();
  final _nextCostController = TextEditingController();
  final _nextSalesController = TextEditingController();
  final _testingCostController = TextEditingController();
  final _toolingCostController = TextEditingController();
  final _otherCostController = TextEditingController();
  final _qtyPerCarsetController = TextEditingController();

  // Controllers for years
  final List<TextEditingController> _yearControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  String _selectedCurrency = 'THB';
  String _selectedUnit = 'KG'; // เพิ่มตัวแปรสำหรับหน่วย
  bool _isConstantVolume = false;
  final _totalVolumeController = TextEditingController();

  final List<String> _units = ['KG', 'G', 'TON']; // เพิ่มรายการหน่วย

  // Constants
  static const int daysPerYear = 240;

  // Business case calculation results
  double _previousVCM = 0.0;
  double _newVCM = 0.0;
  double _vcmImpact = 0.0;
  double _marginDifference = 0.0;
  double _totalVolume = 0.0;
  double _upfrontCost = 0.0;
  double _breakeven = 0.0;

  @override
  void dispose() {
    _previousCostController.dispose();
    _previousSalesController.dispose();
    _nextCostController.dispose();
    _nextSalesController.dispose();
    _testingCostController.dispose();
    _toolingCostController.dispose();
    _otherCostController.dispose();
    _qtyPerCarsetController.dispose();
    _totalVolumeController.dispose();
    for (var controller in _yearControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 1000,
        height: 800,
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Material Analysis',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B365C),
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cost & Sales Section
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
                          const Text(
                            'Cost & Sales',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Previous Part Price
                          _buildPartPriceSection(
                            'Previous Part Price',
                            _previousCostController,
                            _previousSalesController,
                            'Previous Cost',
                            'Previous Sales',
                          ),
                          const SizedBox(height: 16),
                          // Part Price To be implemented
                          _buildPartPriceSection(
                            'Part Price To be implemented',
                            _nextCostController,
                            _nextSalesController,
                            'Next Cost',
                            'Next Sales',
                          ),
                          const SizedBox(height: 16),
                          // Other costs
                          _buildCostField(
                              'Testing Cost', _testingCostController),
                          _buildCostField(
                              'Tooling Cost', _toolingCostController),
                          _buildCostField('Other Cost', _otherCostController),
                          const SizedBox(height: 8),
                          // Currency dropdown
                          Row(
                            children: [
                              const Text(
                                'Currency',
                                style: TextStyle(color: Colors.white),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedCurrency,
                                      items: ['THB', 'USD', 'EUR']
                                          .map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedCurrency = newValue!;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Carset Volume Section
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
                          const Text(
                            'Carset Volume',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // QTY/Carset with Unit
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: _buildVolumeField(
                                    'QTY/Carset', _qtyPerCarsetController),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedUnit,
                                      items: _units.map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedUnit = newValue!;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          _buildVolumeField(
                              'Material Volume Year 1', _yearControllers[0]),
                          Row(
                            children: [
                              Checkbox(
                                value: _isConstantVolume,
                                onChanged: (value) {
                                  setState(() {
                                    _isConstantVolume = value!;

                                    if (_isConstantVolume) {
                                      // ถ้า checkbox ถูกเลือก ให้กรอกค่า Year 1 ลงในทุก Year
                                      String year1Value =
                                          _yearControllers[0].text;
                                      for (int i = 1; i < 6; i++) {
                                        _yearControllers[i].text = year1Value;
                                      }
                                    } else {
                                      // ถ้ายกเลิก checkbox ให้เคลียร์ค่า Year 2-6
                                      for (int i = 1; i < 6; i++) {
                                        _yearControllers[i].text = '';
                                      }
                                    }
                                  });
                                },
                                fillColor:
                                    MaterialStateProperty.all(Colors.white),
                                checkColor: const Color(0xFF1B365C),
                              ),
                              const Text(
                                'Constant Volume ?',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          for (int i = 1; i < 6; i++)
                            _buildVolumeField(
                                'Year ${i + 1}', _yearControllers[i]),
                          _buildVolumeField(
                              'Total Carset Volume', _totalVolumeController,
                              enabled: false),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: _calculateBusinessCase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Generate Business Case'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartPriceSection(
    String title,
    TextEditingController costController,
    TextEditingController salesController,
    String costLabel,
    String salesLabel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    costLabel,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: costController,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    salesLabel,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: salesController,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCostField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                border: OutlineInputBorder(borderSide: BorderSide.none),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeField(String label, TextEditingController controller,
      {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              decoration: InputDecoration(
                filled: true,
                fillColor: enabled ? Colors.white : Colors.grey[400],
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                border: const OutlineInputBorder(borderSide: BorderSide.none),
                disabledBorder:
                    const OutlineInputBorder(borderSide: BorderSide.none),
              ),
              style: enabled ? null : TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  // Calculate business case
  void _calculateBusinessCase() {
    try {
      // Get input values
      double prevCost = double.parse(_previousCostController.text);
      double prevSale = double.parse(_previousSalesController.text);
      double nextCost = double.parse(_nextCostController.text);
      double nextSale = double.parse(_nextSalesController.text);
      double testCost = double.parse(_testingCostController.text);
      double toolingCost = double.parse(_toolingCostController.text);
      double otherCost = double.parse(_otherCostController.text);
      double piecePerCarset = double.parse(_qtyPerCarsetController.text);

      // Calculate VCM percentages
      _previousVCM =
          ((prevSale - prevCost) / prevSale) * 100; // (50-20)/50 * 100 = 60%
      _newVCM = (((nextSale - nextCost) / nextSale) * 100).roundToDouble();

      // Calculate VCM Impact - ปรับสูตรให้ตรงกับตัวอย่าง
      _vcmImpact = ((_newVCM - _previousVCM) / _previousVCM) *
          100; // ((65.91-60)/60) * 100 = 15%

      // Calculate margin difference per piece
      _marginDifference = ((nextSale - nextCost) - (prevSale - prevCost));

      // Calculate total volume (2 pieces/carset * 2 units/year * 6 years)
      _totalVolume = piecePerCarset *
          (_yearControllers[0].text.isEmpty
              ? 0
              : double.parse(_yearControllers[0].text)) *
          6;

      // Calculate upfront cost
      _upfrontCost = testCost + toolingCost + otherCost;

      // Calculate breakeven days
      if (_marginDifference == 0) {
        _breakeven = double.infinity; // No profit
      } else if (_marginDifference < 0) {
        _breakeven = double.negativeInfinity; // Negative margin
      } else {
        double dailyVolume =
            (double.parse(_yearControllers[0].text) * piecePerCarset) /
                daysPerYear;
        _breakeven = _upfrontCost / (_marginDifference.abs() * dailyVolume);
      }

      // Update total volume display
      _totalVolumeController.text = _totalVolume.toStringAsFixed(2);

      // Show business case output dialog
      showDialog(
        context: context,
        builder: (BuildContext context) => BusinessCaseOutputPage(
          previousVCM: _previousVCM,
          newVCM: _newVCM,
          vcmImpact: _vcmImpact,
          upfrontCost: _upfrontCost,
          breakeven: _breakeven,
          marginDifference: _marginDifference,
          currency: _selectedCurrency,
          unit: _selectedUnit,
          totalVolume: double.parse(_totalVolumeController.text),
        ),
      );
    } catch (e) {
      // Show error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Calculation Error'),
          content:
              const Text('Please check all input values are valid numbers.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
