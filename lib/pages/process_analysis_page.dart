import 'package:flutter/material.dart';
import '../pages/business_case_output_page.dart';
import '../pages/process_analysis_output_page.dart';

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

  String _selectedCurrency = 'THB'; // เพิ่มตัวแปรสำหรับสกุลเงิน

  // เพิ่มตัวแปรสำหรับ Upfront Cost และ Working Days
  final _upfrontCostController = TextEditingController();
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

    // คำนวณ Saving per year
    double volumePerYear = double.parse(_volumePerYearController.text);
    double saving = marginDifference * volumePerYear;

    // คำนวณ Breakeven โดยใช้ค่า Upfront Cost จาก input และ Working Days = 240
    const workingDays = 240.0;
    double savingPerDay = saving / workingDays;
    double breakeven = double.parse(_upfrontCostController.text) / savingPerDay;

    setState(() {
      _processCurrentCostController.text =
          _formatWithCurrency(currentProcessCost.toStringAsFixed(2));
      _processNewCostController.text =
          _formatWithCurrency(newProcessCost.toStringAsFixed(2));
      _improvementController.text =
          _formatWithCurrency(marginDifference.toStringAsFixed(2));
      _savingController.text = _formatWithCurrency(saving.toStringAsFixed(2));
    });

    // Show ProcessAnalysisOutputPage dialog
    showDialog(
      context: context,
      builder: (context) => ProcessAnalysisOutputPage(
        upfrontCost: double.parse(_upfrontCostController.text),
        breakeven: breakeven,
        marginDifference: marginDifference,
        currency: _selectedCurrency,
        totalVolume: volumePerYear,
        workingDays: workingDays, // ส่งค่าคงที่ 240 ไปยังหน้า Output
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

  Widget _buildCurrentSection() {
    return Container(
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
    );
  }

  Widget _buildNewSection() {
    return Container(
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
          _buildProcessField(
              'Machine rate per\nminute (Cost)', _newMachineRateController, ''),
          _buildDisabledField(
              'Process cost per piece', _processNewCostController),
        ],
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
        padding: const EdgeInsets.all(32),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
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
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 800) {
                    return Row(
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
                    );
                  } else {
                    return Column(
                      children: [
                        _buildCurrentSection(),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [_buildCheckboxSection()],
                        ),
                        const SizedBox(height: 16),
                        _buildNewSection(),
                      ],
                    );
                  }
                },
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
              _buildProcessCostSection(),
              const SizedBox(height: 24),
              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_validateInputs()) {
                        _calculateBusinessCase();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Please fill all required fields correctly'),
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
      fillColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
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

  Widget _buildProcessCostSection() {
    return Container(
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProcessField('Upfront Cost', _upfrontCostController, ''),
              _buildDisabledField('Improvement', _improvementController),
              _buildProcessField('Volume/Year', _volumePerYearController, ''),
              _buildDisabledField('Saving', _savingController),
            ],
          ),
        ],
      ),
    );
  }
}
