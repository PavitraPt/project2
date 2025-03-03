import 'package:flutter/material.dart';
import 'packaging_analysis_output_page.dart';

class PackagingData {
  final double materialCost;
  final double freightCost;
  final double handlingCost;
  final double returnableCost;
  final double cycles;

  PackagingData({
    required this.materialCost,
    required this.freightCost,
    required this.handlingCost,
    required this.returnableCost,
    required this.cycles,
  });

  // คำนวณต้นทุนต่อแพ็คเกจ
  double get costPerPackage => materialCost + freightCost + handlingCost;

  // คำนวณต้นทุนต่อรอบการใช้งาน returnable
  double get costPerCycle => returnableCost / cycles;
}

class PackagingAnalysisPage extends StatefulWidget {
  const PackagingAnalysisPage({super.key});

  @override
  State<PackagingAnalysisPage> createState() => _PackagingAnalysisPageState();
}

class _PackagingAnalysisPageState extends State<PackagingAnalysisPage> {
  // Old Packaging Controllers
  final _oldMaterialCostController = TextEditingController();
  final _oldFreightCostController = TextEditingController();
  final _oldHandlingCostController = TextEditingController();
  final _oldReturnableCostController = TextEditingController();
  final _oldCyclesController = TextEditingController();

  // New Packaging Controllers
  final _newMaterialCostController = TextEditingController();
  final _newFreightCostController = TextEditingController();
  final _newHandlingCostController = TextEditingController();
  final _newReturnableCostController = TextEditingController();
  final _newCyclesController = TextEditingController();

  // Volume Controllers
  final _piecePerPackageController = TextEditingController();
  final List<TextEditingController> _yearControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  // Additional Cost Controllers
  final _testingCostController = TextEditingController();
  final _toolingCostController = TextEditingController();
  final _otherCostController = TextEditingController();

  // เพิ่ม currency options และ selected currency
  final List<String> _currencies = ['THB', 'USD', 'EUR'];
  String _selectedCurrency = 'THB';

  bool _isConstantVolume = false;
  final _totalVolumeController = TextEditingController();


  @override
  void dispose() {
    // Dispose all controllers
    _oldMaterialCostController.dispose();
    _oldFreightCostController.dispose();
    _oldHandlingCostController.dispose();
    _oldReturnableCostController.dispose();
    _oldCyclesController.dispose();

    _newMaterialCostController.dispose();
    _newFreightCostController.dispose();
    _newHandlingCostController.dispose();
    _newReturnableCostController.dispose();
    _newCyclesController.dispose();

    _piecePerPackageController.dispose();
    _testingCostController.dispose();
    _toolingCostController.dispose();
    _otherCostController.dispose();
    _totalVolumeController.dispose();

    for (var controller in _yearControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // เพิ่ม widget สำหรับ currency selector
  Widget _buildCurrencySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1B365C),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Currency:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCurrency,
                items: _currencies.map((String currency) {
                  return DropdownMenuItem<String>(
                    value: currency,
                    child: Text(currency),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedCurrency = newValue;
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _calculateAnalysis() {
    try {
      // Parse input values
      double oldMaterialCost = double.parse(_oldMaterialCostController.text);
      double oldFreightCost = double.parse(_oldFreightCostController.text);
      double oldHandlingCost = double.parse(_oldHandlingCostController.text);
      double oldReturnableCost =
          double.parse(_oldReturnableCostController.text);
      double oldCycles = double.parse(_oldCyclesController.text);

      double newMaterialCost = double.parse(_newMaterialCostController.text);
      double newFreightCost = double.parse(_newFreightCostController.text);
      double newHandlingCost = double.parse(_newHandlingCostController.text);
      double newReturnableCost =
          double.parse(_newReturnableCostController.text);
      double newCycles = double.parse(_newCyclesController.text);

      double piecePerPackage = double.parse(_piecePerPackageController.text);

      // Calculate yearly volumes
      List<double> yearlyVolumes = [];
      if (_isConstantVolume && _yearControllers[0].text.isNotEmpty) {
        double year1Volume = double.parse(_yearControllers[0].text);
        yearlyVolumes = List.filled(6, year1Volume);
      } else {
        for (var controller in _yearControllers) {
          yearlyVolumes.add(double.parse(controller.text));
        }
      }

      // Calculate additional costs
      double additionalCosts = double.parse(_testingCostController.text) +
          double.parse(_toolingCostController.text) +
          double.parse(_otherCostController.text);

      // Calculate total volume
      double totalVolume = yearlyVolumes.reduce((a, b) => a + b);
      _totalVolumeController.text = totalVolume.toString();

      // Show analysis results
      showDialog(
        context: context,
        builder: (BuildContext context) => PackagingAnalysisOutputPage(
          oldPackagingData: PackagingData(
            materialCost: oldMaterialCost,
            freightCost: oldFreightCost,
            handlingCost: oldHandlingCost,
            returnableCost: oldReturnableCost,
            cycles: oldCycles,
          ),
          newPackagingData: PackagingData(
            materialCost: newMaterialCost,
            freightCost: newFreightCost,
            handlingCost: newHandlingCost,
            returnableCost: newReturnableCost,
            cycles: newCycles,
          ),
          piecePerPackage: piecePerPackage,
          yearlyVolumes: yearlyVolumes,
          additionalCosts: additionalCosts,
          currency: _selectedCurrency,
        ),
      );
    } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 1200,
        height: 700,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with currency selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Packaging Analysis',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1B365C),
                  ),
                ),
                _buildCurrencySelector(),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Column(
                children: [
                  // Main content area
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left side (Old, New Packaging และ Additional Costs)
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  // Old Packaging Section
                                  Expanded(
                                    child: _buildPackagingSection(
                                      'Old Packaging',
                                      _oldMaterialCostController,
                                      _oldFreightCostController,
                                      _oldHandlingCostController,
                                      _oldReturnableCostController,
                                      _oldCyclesController,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // New Packaging Section
                                  Expanded(
                                    child: _buildPackagingSection(
                                      'New Packaging',
                                      _newMaterialCostController,
                                      _newFreightCostController,
                                      _newHandlingCostController,
                                      _newReturnableCostController,
                                      _newCyclesController,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Additional Costs Section
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1B365C),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _buildCompactCostField(
                                        'Testing',
                                        _testingCostController,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildCompactCostField(
                                        'Tooling',
                                        _toolingCostController,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildCompactCostField(
                                        'Other',
                                        _otherCostController,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Right side (Volume Section)
                        Expanded(child: _buildVolumeSection()),
                      ],
                    ),
                  ),
                  // Buttons at bottom right
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: _calculateAnalysis,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            minimumSize: const Size(140, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Generate Analysis',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            minimumSize: const Size(100, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackagingSection(
    String title,
    TextEditingController materialController,
    TextEditingController freightController,
    TextEditingController handlingController,
    TextEditingController returnableController,
    TextEditingController cyclesController,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1B365C),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IntrinsicHeight(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            _buildCompactCostField(
              'Material Cost/Package',
              materialController,
            ),
            const SizedBox(height: 8),
            _buildCompactCostField(
              'Freight Cost/Package',
              freightController,
            ),
            const SizedBox(height: 8),
            _buildCompactCostField(
              'Handling Cost/Package',
              handlingController,
            ),
            const SizedBox(height: 8),
            _buildCompactCostField(
              'Returnable Cost',
              returnableController,
            ),
            const SizedBox(height: 8),
            _buildCompactCostField(
              'Number of Cycles',
              cyclesController,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVolumeSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1B365C),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IntrinsicHeight(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Volume',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            _buildCompactVolumeField(
              'Piece/Package',
              _piecePerPackageController,
            ),
            Row(
              children: [
                Checkbox(
                  value: _isConstantVolume,
                  onChanged: (value) {
                    setState(() {
                      _isConstantVolume = value!;
                      if (_isConstantVolume &&
                          _yearControllers[0].text.isNotEmpty) {
                        String year1Value = _yearControllers[0].text;
                        for (int i = 1; i < 6; i++) {
                          _yearControllers[i].text = year1Value;
                        }
                      }
                    });
                  },
                  fillColor: MaterialStateProperty.all(Colors.white),
                  checkColor: const Color(0xFF1B365C),
                ),
                const Text(
                  'Constant Volume',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            _buildCompactVolumeField(
              'Year 1',
              _yearControllers[0],
            ),
            for (int i = 1; i < 6; i++)
              _buildCompactVolumeField(
                'Year ${i + 1}',
                _yearControllers[i],
                enabled: !_isConstantVolume,
              ),
            _buildCompactVolumeField(
              'Total Volume',
              _totalVolumeController,
              enabled: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactCostField(
      String label, TextEditingController controller) {
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

  Widget _buildCompactVolumeField(
    String label,
    TextEditingController controller, {
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: SizedBox(
              height: 32,
              child: TextField(
                controller: controller,
                enabled: enabled,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: enabled ? Colors.white : Colors.grey[300],
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  border: const OutlineInputBorder(borderSide: BorderSide.none),
                  isDense: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
