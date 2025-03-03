// import 'package:flutter/material.dart';
// import 'login_page.dart';
// import 'bop_analysis_page.dart';
// import 'pages/material_analysis_page.dart';
// import 'pages/packaging_analysis_page.dart';
// import 'pages/process_analysis_page.dart';
// import 'business_case_output_page.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   // Controllers สำหรับรับข้อมูล
//   final _previousCostController = TextEditingController();
//   final _previousSalesController = TextEditingController();
//   final _nextCostController = TextEditingController();
//   final _nextSalesController = TextEditingController();
//   final _testingCostController = TextEditingController();
//   final _toolingCostController = TextEditingController();
//   final _otherCostController = TextEditingController();

//   // Controllers สำหรับปีที่ 1-6
//   final List<TextEditingController> _yearControllers = List.generate(
//     6,
//     (index) => TextEditingController(),
//   );

//   // ตัวแปรสำหรับเก็บค่าต่างๆ
//   String _selectedCurrency = 'THB';
//   bool _isConstantValue = false;
//   final _totalVolumeController = TextEditingController();

//   // ค่าคงที่
//   static const int daysPerYear = 240;

//   // ตัวแปรสำหรับเก็บผลลัพธ์การคำนวณ
//   double _previousVCM = 0.0;
//   double _newVCM = 0.0;
//   double _vcmImpact = 0.0;
//   double _marginDifference = 0.0;
//   double _upfrontCost = 0.0;
//   double _breakeven = 0.0;

//   // InputDecoration สำหรับ TextField
//   final _inputDecoration = const InputDecoration(
//     filled: true,
//     fillColor: Colors.white,
//     contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//     border: OutlineInputBorder(borderSide: BorderSide.none),
//   );

//   // เพิ่ม list สำหรับเก็บชื่อโปรเจกต์
//   final List<String> _projectNames = ['Project A', 'Project B', 'Project C'];
//   String? _selectedProject;

//   String? _selectedOption;
//   final List<String> _options = ['BOP', 'Material', 'Packaging', 'Process'];

//   @override
//   void dispose() {
//     // Dispose controllers เมื่อไม่ใช้งาน
//     _previousCostController.dispose();
//     _previousSalesController.dispose();
//     _nextCostController.dispose();
//     _nextSalesController.dispose();
//     _testingCostController.dispose();
//     _toolingCostController.dispose();
//     _otherCostController.dispose();
//     _totalVolumeController.dispose();
//     for (var controller in _yearControllers) {
//       controller.dispose();
//     }
//     super.dispose();
//   }

//   void _handleLogout() {
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (context) => const LoginPage()),
//       (route) => false,
//     );
//   }

//   // เพิ่มฟังก์ชันสำหรับเพิ่มโปรเจกต์ใหม่
//   void _addNewProject(String newProject) {
//     if (newProject.isNotEmpty && !_projectNames.contains(newProject)) {
//       setState(() {
//         _projectNames.add(newProject);
//         _selectedProject = newProject;
//       });
//     }
//   }

//   void _showAnalysisPage(BuildContext context, String type) {
//     Widget page;
//     switch (type) {
//       case 'BOP':
//         page = const BOPAnalysisPage();
//         break;
//       case 'Material':
//         page = const MaterialAnalysisPage();
//         break;
//       case 'Packaging':
//         page = const PackagingAnalysisPage();
//         break;
//       case 'Process':
//         page = const ProcessAnalysisPage();
//         break;
//       default:
//         return;
//     }

//     showDialog(
//       context: context,
//       builder: (BuildContext context) => page,
//     );
//   }

//   void _showOptionsDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text(
//             'Please select options',
//             style: TextStyle(fontSize: 16),
//           ),
//           content: SizedBox(
//             width: 300,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 DropdownButtonFormField<String>(
//                   value: _selectedOption,
//                   decoration: const InputDecoration(
//                     labelText: 'Options',
//                     border: OutlineInputBorder(),
//                   ),
//                   items: _options.map((String option) {
//                     return DropdownMenuItem<String>(
//                       value: option,
//                       child: Text(option),
//                     );
//                   }).toList(),
//                   onChanged: (String? newValue) {
//                     setState(() {
//                       _selectedOption = newValue;
//                     });
//                   },
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 if (_selectedOption != null) {
//                   Navigator.pop(context);
//                   _showAnalysisPage(context, _selectedOption!);
//                 }
//               },
//               child: const Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // คำนวณ Business Case
//   void _calculateBusinessCase() {
//     try {
//       // แปลงค่าจาก TextField เป็นตัวเลข
//       double prevCost = double.parse(_previousCostController.text);
//       double prevSale = double.parse(_previousSalesController.text);
//       double nextCost = double.parse(_nextCostController.text);
//       double nextSale = double.parse(_nextSalesController.text);
//       double testCost = double.parse(_testingCostController.text);
//       double toolingCost = double.parse(_toolingCostController.text);
//       double otherCost = double.parse(_otherCostController.text);

//       // คำนวณ VCM percentages
//       _previousVCM = ((prevSale - prevCost) / prevSale) * 100;
//       _newVCM = ((nextSale - nextCost) / nextSale) * 100;

//       // คำนวณ VCM Impact
//       _vcmImpact = ((_newVCM - _previousVCM) / _previousVCM) * 100;

//       // คำนวณ Margin difference per piece
//       _marginDifference = (nextSale - nextCost) - (prevSale - prevCost);

//       // คำนวณ Upfront cost
//       _upfrontCost = testCost + toolingCost + otherCost;

//       // คำนวณ Total Volume
//       double totalVolume = 0;
//       if (_isConstantValue && _yearControllers[0].text.isNotEmpty) {
//         // ถ้าเป็น Constant Value ให้ใช้ค่าปีแรกคูณ 6
//         double yearlyVolume = double.parse(_yearControllers[0].text);
//         totalVolume = yearlyVolume * 6;
//       } else {
//         // ถ้าไม่ใช่ Constant Value ให้รวมค่าทุกปี
//         for (var controller in _yearControllers) {
//           if (controller.text.isNotEmpty) {
//             totalVolume += double.parse(controller.text);
//           }
//         }
//       }
//       _totalVolumeController.text = totalVolume.toStringAsFixed(2);

//       // คำนวณ Breakeven days
//       if (_marginDifference == 0) {
//         _breakeven = double.infinity;
//       } else {
//         double yearlyVolume = double.parse(_yearControllers[0].text);
//         double dailyVolume = yearlyVolume / daysPerYear;
//         _breakeven = _upfrontCost / (_marginDifference * dailyVolume).abs();
//       }

//       // แสดงผลลัพธ์
//       showDialog(
//         context: context,
//         builder: (BuildContext context) => BusinessCaseOutputPage(
//           previousVCM: _previousVCM,
//           newVCM: _newVCM,
//           vcmImpact: _vcmImpact,
//           upfrontCost: _upfrontCost,
//           breakeven: _breakeven,
//           marginDifference: _marginDifference,
//           currency: _selectedCurrency,
//           unit: 'Pcs',
//           totalVolume: double.parse(_totalVolumeController.text),
//         ),
//       );
//     } catch (e) {
//       // แสดง error dialog
//       showDialog(
//         context: context,
//         builder: (BuildContext context) => AlertDialog(
//           title: const Text('Calculation Error'),
//           content:
//               const Text('Please check all input values are valid numbers.'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('OK'),
//             ),
//           ],
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Row(
//         children: [
//           // Left sidebar - History
//           Container(
//             width: 250,
//             color: const Color(0xFFB4D4E7),
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'History',
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF1B365C),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   // History items
//                   ListView.builder(
//                     shrinkWrap: true,
//                     itemCount: 3,
//                     itemBuilder: (context, index) {
//                       return Container(
//                         margin: const EdgeInsets.only(bottom: 8),
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: const Text(
//                           'Reduce foam',
//                           style: TextStyle(color: Color(0xFF1B365C)),
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           // Main content
//           Expanded(
//             child: SingleChildScrollView(
//               child: Container(
//                 padding: const EdgeInsets.all(24),
//                 color: Colors.white,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Header
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Text(
//                           'HOMEPAGE',
//                           style: TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF1B365C),
//                           ),
//                         ),
//                         Row(
//                           children: [
//                             const CircleAvatar(
//                               backgroundColor: Color(0xFF1B365C),
//                               child: Text(
//                                 'P',
//                                 style: TextStyle(color: Colors.white),
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             const Text(
//                               'PAVITRA P.',
//                               style: TextStyle(color: Color(0xFF1B365C)),
//                             ),
//                             const SizedBox(width: 8),
//                             PopupMenuButton(
//                               icon: const Icon(Icons.settings),
//                               itemBuilder: (BuildContext context) => [
//                                 PopupMenuItem(
//                                   child: ListTile(
//                                     leading: const Icon(Icons.logout),
//                                     title: const Text('Logout'),
//                                     onTap: () {
//                                       Navigator.pop(context);
//                                       _handleLogout();
//                                     },
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 24),
//                     // Project name section
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFB4D4E7),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Row(
//                         children: [
//                           const Text(
//                             'Project name',
//                             style: TextStyle(
//                               color: Color(0xFF1B365C),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                           Expanded(
//                             child: Autocomplete<String>(
//                               optionsBuilder:
//                                   (TextEditingValue textEditingValue) {
//                                 if (textEditingValue.text == '') {
//                                   return _projectNames;
//                                 }
//                                 return _projectNames.where((String option) {
//                                   return option.toLowerCase().contains(
//                                         textEditingValue.text.toLowerCase(),
//                                       );
//                                 });
//                               },
//                               onSelected: (String selection) {
//                                 setState(() {
//                                   _selectedProject = selection;
//                                 });
//                               },
//                               fieldViewBuilder: (
//                                 BuildContext context,
//                                 TextEditingController controller,
//                                 FocusNode focusNode,
//                                 VoidCallback onFieldSubmitted,
//                               ) {
//                                 return TextFormField(
//                                   controller: controller,
//                                   focusNode: focusNode,
//                                   decoration: InputDecoration(
//                                     labelText: 'Project name',
//                                     border: InputBorder.none,
//                                     suffixIcon: IconButton(
//                                       icon: const Icon(Icons.add),
//                                       onPressed: () {
//                                         if (controller.text.isNotEmpty) {
//                                           _addNewProject(controller.text);
//                                           controller.clear();
//                                         }
//                                       },
//                                       tooltip: 'Add new project',
//                                     ),
//                                   ),
//                                   onFieldSubmitted: (String value) {
//                                     onFieldSubmitted();
//                                     if (value.isNotEmpty) {
//                                       _addNewProject(value);
//                                       controller.clear();
//                                     }
//                                   },
//                                 );
//                               },
//                               optionsViewBuilder: (
//                                 BuildContext context,
//                                 AutocompleteOnSelected<String> onSelected,
//                                 Iterable<String> options,
//                               ) {
//                                 return Align(
//                                   alignment: Alignment.topLeft,
//                                   child: Material(
//                                     elevation: 4.0,
//                                     child: Container(
//                                       width: 300,
//                                       color: Colors.white,
//                                       child: ListView.builder(
//                                         padding: const EdgeInsets.all(8.0),
//                                         itemCount: options.length,
//                                         shrinkWrap: true,
//                                         itemBuilder:
//                                             (BuildContext context, int index) {
//                                           final String option =
//                                               options.elementAt(index);
//                                           return ListTile(
//                                             title: Text(option),
//                                             onTap: () {
//                                               onSelected(option);
//                                             },
//                                           );
//                                         },
//                                       ),
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                     // Main content area
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Cost & Sales section
//                         Expanded(
//                           child: Container(
//                             padding: const EdgeInsets.all(24),
//                             decoration: BoxDecoration(
//                               color: const Color(0xFF1B365C),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const Text(
//                                   'Cost & Sales',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 16,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 16),
//                                 // Previous Part Price
//                                 _buildPartPriceSection(
//                                   'Previous Part Price',
//                                   _previousCostController,
//                                   _previousSalesController,
//                                   'Previous Cost',
//                                   'Previous Sales',
//                                 ),
//                                 const SizedBox(height: 16),
//                                 // Part Price To be implemented
//                                 _buildPartPriceSection(
//                                   'Part Price To be implemented',
//                                   _nextCostController,
//                                   _nextSalesController,
//                                   'Next Cost',
//                                   'Next Sales',
//                                 ),
//                                 const SizedBox(height: 16),
//                                 // Other costs
//                                 _buildCostField(
//                                     'Testing Cost', _testingCostController),
//                                 _buildCostField(
//                                     'Tooling Cost', _toolingCostController),
//                                 _buildCostField(
//                                     'Other Cost', _otherCostController),
//                                 const SizedBox(height: 8),
//                                 // Currency dropdown
//                                 Row(
//                                   children: [
//                                     const Text(
//                                       'Currency',
//                                       style: TextStyle(color: Colors.white),
//                                     ),
//                                     const SizedBox(width: 8),
//                                     Expanded(
//                                       child: Container(
//                                         padding: const EdgeInsets.symmetric(
//                                             horizontal: 8),
//                                         decoration: BoxDecoration(
//                                           color: Colors.white,
//                                           borderRadius:
//                                               BorderRadius.circular(4),
//                                         ),
//                                         child: DropdownButtonHideUnderline(
//                                           child: DropdownButton<String>(
//                                             value: _selectedCurrency,
//                                             items: ['THB', 'USD', 'EUR']
//                                                 .map((String value) {
//                                               return DropdownMenuItem<String>(
//                                                 value: value,
//                                                 child: Text(value),
//                                               );
//                                             }).toList(),
//                                             onChanged: (String? newValue) {
//                                               setState(() {
//                                                 _selectedCurrency = newValue!;
//                                               });
//                                             },
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         // Volume section
//                         Expanded(
//                           child: Container(
//                             padding: const EdgeInsets.all(16),
//                             decoration: BoxDecoration(
//                               color: const Color(0xFFB4D4E7),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const Text(
//                                   'Volume',
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 16,
//                                     color: Color(0xFF1B365C),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 16),
//                                 Row(
//                                   children: [
//                                     const Text(
//                                       'Year 1\n(At SOP date)',
//                                       style:
//                                           TextStyle(color: Color(0xFF1B365C)),
//                                     ),
//                                     const SizedBox(width: 8),
//                                     Expanded(
//                                       child: TextField(
//                                         controller: _yearControllers[0],
//                                         decoration: _inputDecoration,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 8),
//                                 Row(
//                                   children: [
//                                     const SizedBox(width: 8),
//                                     Checkbox(
//                                       value: _isConstantValue,
//                                       onChanged: (value) {
//                                         setState(() {
//                                           _isConstantValue = value!;
//                                           if (_isConstantValue) {
//                                             String year1Value =
//                                                 _yearControllers[0].text;
//                                             for (int i = 1; i < 6; i++) {
//                                               _yearControllers[i].text =
//                                                   year1Value;
//                                             }
//                                           } else {
//                                             for (int i = 1; i < 6; i++) {
//                                               _yearControllers[i].text = '';
//                                             }
//                                           }
//                                         });
//                                       },
//                                       activeColor: const Color(0xFF1B365C),
//                                     ),
//                                     const Text(
//                                       'Constant value',
//                                       style:
//                                           TextStyle(color: Color(0xFF1B365C)),
//                                     ),
//                                   ],
//                                 ),
//                                 // Year 2-6 fields
//                                 for (int i = 1; i < 6; i++)
//                                   Padding(
//                                     padding: const EdgeInsets.only(top: 8),
//                                     child: Row(
//                                       children: [
//                                         Text(
//                                           'Year ${i + 1}',
//                                           style: const TextStyle(
//                                               color: Color(0xFF1B365C)),
//                                         ),
//                                         const SizedBox(width: 8),
//                                         Expanded(
//                                           child: TextField(
//                                             controller: _yearControllers[i],
//                                             enabled: !_isConstantValue,
//                                             decoration: _inputDecoration,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 const SizedBox(height: 16),
//                                 // Total Volume
//                                 Row(
//                                   children: [
//                                     const Text(
//                                       'Total Volume',
//                                       style:
//                                           TextStyle(color: Color(0xFF1B365C)),
//                                     ),
//                                     const SizedBox(width: 8),
//                                     Expanded(
//                                       child: TextField(
//                                         controller: _totalVolumeController,
//                                         enabled: false,
//                                         decoration: const InputDecoration(
//                                           filled: true,
//                                           fillColor: Colors.white,
//                                           contentPadding: EdgeInsets.symmetric(
//                                               horizontal: 8, vertical: 8),
//                                           border: OutlineInputBorder(
//                                               borderSide: BorderSide.none),
//                                           disabledBorder: OutlineInputBorder(
//                                               borderSide: BorderSide.none),
//                                         ),
//                                         style:
//                                             TextStyle(color: Colors.grey[600]),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 16), // Generate button
//                                 SizedBox(
//                                   width: double.infinity,
//                                   child: ElevatedButton(
//                                     onPressed: _calculateBusinessCase,
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: const Color(0xFF1B365C),
//                                       padding: const EdgeInsets.symmetric(
//                                           vertical: 20),
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(8),
//                                       ),
//                                     ),
//                                     child: const Text(
//                                       'Click Here to Generate',
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//                     // Bottom section
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFF5F5F5),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Row(
//                         children: [
//                           const SizedBox(width: 16),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const SizedBox(height: 16),
//                                 SizedBox(
//                                   width: double.infinity,
//                                   child: ElevatedButton(
//                                     onPressed: _showOptionsDialog,
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: const Color(0xFF1B365C),
//                                       padding: const EdgeInsets.symmetric(
//                                           vertical: 20),
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(8),
//                                       ),
//                                     ),
//                                     child: const Text(
//                                       'Click here for Advance Financial Analysis',
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPartPriceSection(
//     String title,
//     TextEditingController costController,
//     TextEditingController salesController,
//     String costLabel,
//     String salesLabel,
//   ) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: const TextStyle(color: Colors.white),
//         ),
//         const SizedBox(height: 8),
//         Row(
//           children: [
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     costLabel,
//                     style: const TextStyle(color: Colors.white70),
//                   ),
//                   const SizedBox(height: 4),
//                   TextField(
//                     controller: costController,
//                     decoration: const InputDecoration(
//                       filled: true,
//                       fillColor: Colors.white,
//                       contentPadding:
//                           EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//                       border: OutlineInputBorder(borderSide: BorderSide.none),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     salesLabel,
//                     style: const TextStyle(color: Colors.white70),
//                   ),
//                   const SizedBox(height: 4),
//                   TextField(
//                     controller: salesController,
//                     decoration: const InputDecoration(
//                       filled: true,
//                       fillColor: Colors.white,
//                       contentPadding:
//                           EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//                       border: OutlineInputBorder(borderSide: BorderSide.none),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildCostField(String label, TextEditingController controller) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         children: [
//           SizedBox(
//             width: 100,
//             child: Text(
//               label,
//               style: const TextStyle(color: Colors.white),
//             ),
//           ),
//           Expanded(
//             child: TextField(
//               controller: controller,
//               decoration: const InputDecoration(
//                 filled: true,
//                 fillColor: Colors.white,
//                 contentPadding:
//                     EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//                 border: OutlineInputBorder(borderSide: BorderSide.none),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
