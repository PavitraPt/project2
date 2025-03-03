import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../pages/business_case_output_page.dart';

class ProcessAnalysisPage extends StatefulWidget {
  const ProcessAnalysisPage({super.key});

  @override
  State<ProcessAnalysisPage> createState() => _ProcessAnalysisPageState();
}

class _ProcessAnalysisPageState extends State<ProcessAnalysisPage> {
  // Current Process Controllers
  final _cycleTimeController = TextEditingController();
  final _efficiencyController = TextEditingController();
  final _piecePerCycleController = TextEditingController();
  final _machineRateController = TextEditingController();
  final _processCurrentCostController = TextEditingController();

  // New Process Controllers
  final _newCycleTimeController = TextEditingController();
  final _newEfficiencyController = TextEditingController();
  final _newPiecePerCycleController = TextEditingController();
  final _newMachineRateController = TextEditingController();
  final _processNewCostController = TextEditingController();

  // Process Cost Controllers
  final _improvementController = TextEditingController();
  final _volumePerYearController = TextEditingController();
  final _savingController = TextEditingController();

  // Checkboxes for "To be Updated?"
  bool _updateCycleTime = false;
  bool _updateEfficiency = false;
  bool _updatePiecePerCycle = false;
  bool _updateMachineRate = false;

  // เพิ่มตัวแปรสำหรับเก็บผลลัพธ์การคำนวณ
  final double _previousVCM = 0.0;
  final double _newVCM = 0.0;
  final double _vcmImpact = 0.0;
  final double _marginDifference = 0.0;
  final double _upfrontCost = 0.0;
  final double _breakeven = 0.0;
  String _selectedCurrency = 'THB'; // เพิ่มตัวแปรสำหรับสกุลเงิน

  // เพิ่มตัวแปรสำหรับ Upfront Cost และ Working Days
  final _upfrontCostController = TextEditingController(text: '300');
  final _workingDaysController = TextEditingController(text: '240');
  final _sellingPriceController = TextEditingController(text: '100');

  @override
  void dispose() {
    _cycleTimeController.dispose();
    _efficiencyController.dispose();
    _piecePerCycleController.dispose();
    _machineRateController.dispose();
    _processCurrentCostController.dispose();
    _newCycleTimeController.dispose();
    _newEfficiencyController.dispose();
    _newPiecePerCycleController.dispose();
    _newMachineRateController.dispose();
    _processNewCostController.dispose();
    _improvementController.dispose();
    _volumePerYearController.dispose();
    _savingController.dispose();
    _upfrontCostController.dispose();
    _workingDaysController.dispose();
    _sellingPriceController.dispose();
    super.dispose();
  }

  // ฟังก์ชันสำหรับฟอร์แมตตัวเลขพร้อม currency
  String _formatWithCurrency(String value) {
    if (value.isEmpty) return '';
    final number = double.tryParse(value);
    if (number == null) return value;

    switch (_selectedCurrency) {
      case 'USD':
        return '\$${number.toStringAsFixed(2)}';
      case 'EUR':
        return '€${number.toStringAsFixed(2)}';
      case 'THB':
      default:
        return '${number.toStringAsFixed(2)} ฿';
    }
  }

  // ฟังก์ชันคำนวณ Process Cost per Piece
  double _calculateProcessCost(
    double cycleTime,
    double efficiency,
    double piecePerCycle,
    double machineRate,
  ) {
    if (efficiency <= 0 || piecePerCycle <= 0) return 0;

    // Process Cost = (Machine Rate per Min) * (Cycle Time / 60) / (Pieces * (Efficiency / 100))
    return (machineRate * (cycleTime / 60)) /
        (piecePerCycle * (efficiency / 100));
  }

  void _calculateBusinessCase() {
    // คำนวณ Process Cost per Piece (Current)
    double currentCycleTime = double.tryParse(_cycleTimeController.text) ?? 0;
    double currentEfficiency = double.tryParse(_efficiencyController.text) ?? 0;
    double currentPiecePerCycle =
        double.tryParse(_piecePerCycleController.text) ?? 0;
    double currentMachineRate =
        double.tryParse(_machineRateController.text) ?? 0;

    double currentProcessCost = _calculateProcessCost(
      currentCycleTime,
      currentEfficiency,
      currentPiecePerCycle,
      currentMachineRate,
    );

    // คำนวณ Process Cost per Piece (New)
    double newCycleTime = double.tryParse(_newCycleTimeController.text) ?? 0;
    double newEfficiency = double.tryParse(_newEfficiencyController.text) ?? 0;
    double newPiecePerCycle =
        double.tryParse(_newPiecePerCycleController.text) ?? 0;
    double newMachineRate =
        double.tryParse(_newMachineRateController.text) ?? 0;

    double newProcessCost = _calculateProcessCost(
      newCycleTime,
      newEfficiency,
      newPiecePerCycle,
      newMachineRate,
    );

    // คำนวณ Margin Difference (Old Cost - New Cost)
    double marginDifference = currentProcessCost - newProcessCost;

    // คำนวณ Net Saving per Year
    double volumePerYear = double.tryParse(_volumePerYearController.text) ?? 0;
    double saving = marginDifference * volumePerYear;

    // คำนวณ Breakeven (days) - สมมติว่า 1 ปีมี 365 วัน
    double breakeven = 0;
    double upfrontCost = double.tryParse(_upfrontCostController.text) ?? 300;
    double workingDays = double.tryParse(_workingDaysController.text) ?? 240;

    if (marginDifference > 0 && volumePerYear > 0) {
      double savingPerDay = saving / workingDays;
      breakeven = upfrontCost / savingPerDay;
    } else {
      breakeven = double.infinity;
    }

    setState(() {
      _processCurrentCostController.text =
          _formatWithCurrency(currentProcessCost.toStringAsFixed(2));
      _processNewCostController.text =
          _formatWithCurrency(newProcessCost.toStringAsFixed(2));
      _improvementController.text =
          _formatWithCurrency(marginDifference.toStringAsFixed(2));
      _savingController.text = _formatWithCurrency(saving.toStringAsFixed(2));
    });

    // เปิดหน้า Business Case Output
    showDialog(
      context: context,
      builder: (context) => BusinessCaseOutputPage(
        previousVCM: _calculatePreviousVCM(),
        newVCM: _calculateNewVCM(),
        vcmImpact: _calculateVCMImpact(),
        upfrontCost: upfrontCost,
        breakeven: breakeven,
        marginDifference: marginDifference,
        currency: _selectedCurrency,
        unit: 'Piece',
        totalVolume: volumePerYear,
      ),
    );
  }

  bool _validateInputs() {
    return _cycleTimeController.text.isNotEmpty &&
        _efficiencyController.text.isNotEmpty &&
        _piecePerCycleController.text.isNotEmpty &&
        _machineRateController.text.isNotEmpty &&
        _newCycleTimeController.text.isNotEmpty &&
        _newEfficiencyController.text.isNotEmpty &&
        _newPiecePerCycleController.text.isNotEmpty &&
        _newMachineRateController.text.isNotEmpty &&
        _volumePerYearController.text.isNotEmpty;
  }

  void _resetForm() {
    setState(() {
      _cycleTimeController.clear();
      _efficiencyController.clear();
      _piecePerCycleController.clear();
      _machineRateController.clear();
      _processCurrentCostController.clear();
      _newCycleTimeController.clear();
      _newEfficiencyController.clear();
      _newPiecePerCycleController.clear();
      _newMachineRateController.clear();
      _processNewCostController.clear();
      _improvementController.clear();
      _volumePerYearController.clear();
      _savingController.clear();

      _updateCycleTime = false;
      _updateEfficiency = false;
      _updatePiecePerCycle = false;
      _updateMachineRate = false;
    });
  }

  Widget _buildCurrentSection() {
    return Expanded(
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
              'Current',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            _buildProcessField('Cycle time', _cycleTimeController, 'Second'),
            _buildProcessField('Efficiency', _efficiencyController, '%'),
            _buildProcessField(
                'Piece per cycle', _piecePerCycleController, 'Piece'),
            _buildProcessField(
                'Machine rate per\nminute (Cost)', _machineRateController, ''),
            _buildDisabledField(
                'Process cost per piece', _processCurrentCostController),
          ],
        ),
      ),
    );
  }

  Widget _buildNewSection() {
    return Expanded(
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
              'New',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            _buildProcessField(
                'New Cycle time', _newCycleTimeController, 'Second'),
            _buildProcessField('Efficiency', _newEfficiencyController, '%'),
            _buildProcessField(
                'Piece per cycle', _newPiecePerCycleController, 'Piece'),
            _buildProcessField('Machine rate per\nminute (Cost)',
                _newMachineRateController, ''),
            _buildDisabledField(
                'Process cost per piece', _processNewCostController),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'To be\nUpdated?',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF1B365C),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildCheckbox(_updateCycleTime, (value) {
          setState(() {
            _updateCycleTime = value ?? false;
            if (value ?? false) {
              _newCycleTimeController.text = _cycleTimeController.text;
            }
          });
        }),
        const SizedBox(height: 25),
        _buildCheckbox(_updateEfficiency, (value) {
          setState(() {
            _updateEfficiency = value ?? false;
            if (value ?? false) {
              _newEfficiencyController.text = _efficiencyController.text;
            }
          });
        }),
        const SizedBox(height: 25),
        _buildCheckbox(_updatePiecePerCycle, (value) {
          setState(() {
            _updatePiecePerCycle = value ?? false;
            if (value ?? false) {
              _newPiecePerCycleController.text = _piecePerCycleController.text;
            }
          });
        }),
        const SizedBox(height: 25),
        _buildCheckbox(_updateMachineRate, (value) {
          setState(() {
            _updateMachineRate = value ?? false;
            if (value ?? false) {
              _newMachineRateController.text = _machineRateController.text;
            }
          });
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 1100,
        height: 900,
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Process Analysis',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B365C),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildCurrentSection()),
                Container(
                  width: 100,
                  padding: const EdgeInsets.symmetric(vertical: 0),
                  child: _buildCheckboxSection(),
                ),
                Expanded(child: _buildNewSection()),
              ],
            ),
            const SizedBox(height: 16),
            // Currency Dropdown
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Currency',
                  style: TextStyle(color: Color(0xFF1B365C)),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 100,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCurrency,
                      items: ['THB', 'USD', 'EUR'].map((String value) {
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
              ],
            ),
            const SizedBox(height: 16),
            // Process Cost Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1B365C),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Process cost',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            _buildProcessField(
                                'Improvement', _improvementController, ''),
                            _buildProcessField(
                                'Volume/Year', _volumePerYearController, ''),
                            _buildDisabledField('Saving', _savingController),
                          ],
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_validateInputs()) {
                      // ตรวจสอบ validation ก่อน
                      _calculateBusinessCase(); // คำนวณค่าต่างๆ
                    } else {
                      // แสดง error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Please fill all required fields correctly'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B365C),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: const Text(
                    'Generate Business Case',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xFF1B365C)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessField(
      String label, TextEditingController controller, String unit) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            flex: 3,
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
          if (unit.isNotEmpty)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  unit,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDisabledField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            flex: 3,
            child: TextField(
              controller: controller,
              enabled: false,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[400],
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                border: const OutlineInputBorder(borderSide: BorderSide.none),
                disabledBorder:
                    const OutlineInputBorder(borderSide: BorderSide.none),
                // เพิ่ม suffix text สำหรับแสดง currency
                suffixText: _selectedCurrency,
                suffixStyle: TextStyle(color: Colors.grey[600]),
              ),
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckbox(bool value, void Function(bool?) onChanged) {
    return Checkbox(
      value: value,
      onChanged: onChanged,
      fillColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return const Color(0xFF1B365C);
          }
          return Colors.white;
        },
      ),
      checkColor: Colors.white,
      side: const BorderSide(color: Colors.white),
    );
  }

  // ฟังก์ชันคำนวณ VCM (ถ้าไม่มี Selling Price ให้ใช้ Process Cost เทียบกับ Base)
  double _calculatePreviousVCM() {
    double processCurrentCost =
        double.tryParse(_processCurrentCostController.text) ?? 0;
    double sellingPrice = double.tryParse(_sellingPriceController.text) ?? 100;
    if (sellingPrice <= 0) return 0;
    return ((sellingPrice - processCurrentCost) / sellingPrice) * 100;
  }

  double _calculateNewVCM() {
    double processNewCost =
        double.tryParse(_processNewCostController.text) ?? 0;
    double sellingPrice = double.tryParse(_sellingPriceController.text) ?? 100;
    if (sellingPrice <= 0) return 0;
    return ((sellingPrice - processNewCost) / sellingPrice) * 100;
  }

  double _calculateVCMImpact() {
    return _calculateNewVCM() - _calculatePreviousVCM();
  }

  // เพิ่ม validation สำหรับ input
  String? _validateEfficiency(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    double? efficiency = double.tryParse(value);
    if (efficiency == null || efficiency <= 0 || efficiency > 100) {
      return 'Enter value between 1-100';
    }
    return null;
  }
}
