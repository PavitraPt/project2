import 'package:flutter/material.dart';
import 'login_page.dart';
import 'bop_analysis_page.dart';
import 'material_analysis_page.dart';
import 'packaging_analysis_page.dart';
import 'process_analysis_page.dart';
import 'business_case_output_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // Controllers สำหรับรับข้อมูล
  final _previousCostController = TextEditingController();
  final _previousSalesController = TextEditingController();
  final _nextCostController = TextEditingController();
  final _nextSalesController = TextEditingController();
  final _testingCostController = TextEditingController();
  final _toolingCostController = TextEditingController();
  final _otherCostController = TextEditingController();

  // Controllers สำหรับปีที่ 1-6
  final List<TextEditingController> _yearControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  // ตัวแปรสำหรับเก็บค่าต่างๆ
  String _selectedCurrency = 'THB';
  bool _isConstantValue = false;
  final _totalVolumeController = TextEditingController();

  // ค่าคงที่
  static const int daysPerYear = 240;

  // ตัวแปรสำหรับเก็บผลลัพธ์การคำนวณ
  double _previousVCM = 0.0;
  double _newVCM = 0.0;
  double _vcmImpact = 0.0;
  double _marginDifference = 0.0;
  double _upfrontCost = 0.0;
  double _breakeven = 0.0;

  // InputDecoration สำหรับ TextField
  final _inputDecoration = const InputDecoration(
    filled: true,
    fillColor: Colors.white,
    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    border: OutlineInputBorder(borderSide: BorderSide.none),
  );

  // เพิ่ม list สำหรับเก็บชื่อโปรเจกต์
  final List<String> _projectNames = ['Project A', 'Project B', 'Project C'];
  String? _selectedProject;

  String? _selectedOption;
  final List<String> _options = ['BOP', 'Material', 'Packaging', 'Process'];

  @override
  void dispose() {
    // Dispose controllers เมื่อไม่ใช้งาน
    _previousCostController.dispose();
    _previousSalesController.dispose();
    _nextCostController.dispose();
    _nextSalesController.dispose();
    _testingCostController.dispose();
    _toolingCostController.dispose();
    _otherCostController.dispose();
    _totalVolumeController.dispose();
    for (var controller in _yearControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleLogout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  // เพิ่มฟังก์ชันสำหรับเพิ่มโปรเจกต์ใหม่
  void _addNewProject(String newProject) {
    if (newProject.isNotEmpty && !_projectNames.contains(newProject)) {
      setState(() {
        _projectNames.add(newProject);
        _selectedProject = newProject;
      });
    }
  }

  void _showAnalysisPage(BuildContext context, String type) {
    Widget page;
    switch (type) {
      case 'BOP':
        page = const BOPAnalysisPage();
        break;
      case 'Material':
        page = const MaterialAnalysisPage();
        break;
      case 'Packaging':
        page = const PackagingAnalysisPage();
        break;
      case 'Process':
        page = const ProcessAnalysisPage();
        break;
      default:
        return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) => page,
    );
  }

  void _showOptionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Please select options',
            style: TextStyle(fontSize: 16),
          ),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedOption,
                  decoration: const InputDecoration(
                    labelText: 'Options',
                    border: OutlineInputBorder(),
                  ),
                  items: _options.map((String option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedOption = newValue;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_selectedOption != null) {
                  Navigator.pop(context);
                  _showAnalysisPage(context, _selectedOption!);
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // คำนวณ Business Case
  void _calculateBusinessCase() {
    try {
      // แปลงค่าจาก TextField เป็นตัวเลข
      double prevCost = double.parse(_previousCostController.text);
      double prevSale = double.parse(_previousSalesController.text);
      double nextCost = double.parse(_nextCostController.text);
      double nextSale = double.parse(_nextSalesController.text);
      double testCost = double.parse(_testingCostController.text);
      double toolingCost = double.parse(_toolingCostController.text);
      double otherCost = double.parse(_otherCostController.text);

      // คำนวณ VCM percentages
      _previousVCM = ((prevSale - prevCost) / prevSale) * 100;
      _newVCM = ((nextSale - nextCost) / nextSale) * 100;

      // คำนวณ VCM Impact
      _vcmImpact = ((_newVCM - _previousVCM) / _previousVCM) * 100;

      // คำนวณ Margin difference per piece
      _marginDifference = (nextSale - nextCost) - (prevSale - prevCost);

      // คำนวณ Upfront cost
      _upfrontCost = testCost + toolingCost + otherCost;

      // คำนวณ Total Volume
      double totalVolume = 0;
      if (_isConstantValue && _yearControllers[0].text.isNotEmpty) {
        // ถ้าเป็น Constant Value ให้ใช้ค่าปีแรกคูณ 6
        double yearlyVolume = double.parse(_yearControllers[0].text);
        totalVolume = yearlyVolume * 6;
      } else {
        // ถ้าไม่ใช่ Constant Value ให้รวมค่าทุกปี
        for (var controller in _yearControllers) {
          if (controller.text.isNotEmpty) {
            totalVolume += double.parse(controller.text);
          }
        }
      }
      _totalVolumeController.text = totalVolume.toStringAsFixed(2);

      // คำนวณ Breakeven days
      if (_marginDifference == 0) {
        _breakeven = double.infinity;
      } else {
        double yearlyVolume = double.parse(_yearControllers[0].text);
        double dailyVolume = yearlyVolume / daysPerYear;
        _breakeven = _upfrontCost / (_marginDifference * dailyVolume).abs();
      }

      // แสดงผลลัพธ์
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
          unit: 'Pcs',
          totalVolume: double.parse(_totalVolumeController.text),
        ),
      );
    } catch (e) {
      // แสดง error dialog
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cost & Sales section
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
                        _buildPartPriceSection(
                          'Previous Part',
                          _previousCostController,
                          _previousSalesController,
                          'Cost/pc',
                          'Sales/pc',
                        ),
                        const SizedBox(height: 16),
                        _buildPartPriceSection(
                          'Next Part',
                          _nextCostController,
                          _nextSalesController,
                          'Cost/pc',
                          'Sales/pc',
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Additional Cost',
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        _buildCostField('Testing', _testingCostController),
                        _buildCostField('Tooling', _toolingCostController),
                        _buildCostField('Others', _otherCostController),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Volume section
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB4D4E7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Volume',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1B365C),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Text(
                              'Year 1\n(At SOP date)',
                              style: TextStyle(color: Color(0xFF1B365C)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _yearControllers[0],
                                decoration: _inputDecoration,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const SizedBox(width: 8),
                            Checkbox(
                              value: _isConstantValue,
                              onChanged: (value) {
                                setState(() {
                                  _isConstantValue = value!;
                                  if (_isConstantValue) {
                                    String year1Value =
                                        _yearControllers[0].text;
                                    for (int i = 1; i < 6; i++) {
                                      _yearControllers[i].text = year1Value;
                                    }
                                  } else {
                                    for (int i = 1; i < 6; i++) {
                                      _yearControllers[i].text = '';
                                    }
                                  }
                                });
                              },
                              activeColor: const Color(0xFF1B365C),
                            ),
                            const Text(
                              'Constant value',
                              style: TextStyle(color: Color(0xFF1B365C)),
                            ),
                          ],
                        ),
                        // Year 2-6 fields
                        for (int i = 1; i < 6; i++)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                Text(
                                  'Year ${i + 1}',
                                  style:
                                      const TextStyle(color: Color(0xFF1B365C)),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _yearControllers[i],
                                    enabled: !_isConstantValue,
                                    decoration: _inputDecoration,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 16),
                        // Total Volume
                        Row(
                          children: [
                            const Text(
                              'Total Volume',
                              style: TextStyle(color: Color(0xFF1B365C)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _totalVolumeController,
                                enabled: false,
                                decoration: const InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 8),
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide.none),
                                  disabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none),
                                ),
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16), // Generate button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _calculateBusinessCase,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1B365C),
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Click Here to Generate',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Analysis Button Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _showOptionsDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1B365C),
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Click here for Advance Financial Analysis',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
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
                    decoration: _inputDecoration,
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
                    decoration: _inputDecoration,
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
              decoration: _inputDecoration,
            ),
          ),
        ],
      ),
    );
  }
}
