import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../components/history_sidebar.dart';
import 'login_page.dart';
import 'bop_analysis_page.dart';
import 'material_analysis_page.dart';
import 'packaging_analysis_page.dart';
import 'process_analysis_page.dart';
import 'main_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _selectedOption;
  final List<String> _options = ['BOP', 'Material', 'Packaging', 'Process'];

  // เพิ่ม list สำหรับเก็บชื่อโปรเจกต์
  final List<String> _projectNames = ['Project A', 'Project B', 'Project C'];
  String? _selectedProject;

  // Mock history data
  final List<Map<String, dynamic>> _historyItems = [
    {
      'date': DateTime.now(),
      'type': 'Packaging',
      'netSaving': 1500.00,
      'oldCost': 5000.00,
      'newCost': 3500.00,
      'description': 'Reduce foam packaging'
    },
  ];

  void _handleLogout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
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
            'Select Analysis Type',
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
                    labelText: 'Analysis Type',
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

  // เพิ่มฟังก์ชันสำหรับเพิ่มโปรเจกต์ใหม่
  void _addNewProject(String newProject) {
    if (newProject.isNotEmpty && !_projectNames.contains(newProject)) {
      setState(() {
        _projectNames.add(newProject);
        _selectedProject = newProject;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Navbar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF1B365C),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Project name section
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Text(
                          'Project name',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Autocomplete<String>(
                            optionsBuilder:
                                (TextEditingValue textEditingValue) {
                              if (textEditingValue.text == '') {
                                return _projectNames;
                              }
                              return _projectNames.where((String option) {
                                return option.toLowerCase().contains(
                                      textEditingValue.text.toLowerCase(),
                                    );
                              });
                            },
                            onSelected: (String selection) {
                              setState(() {
                                _selectedProject = selection;
                              });
                            },
                            fieldViewBuilder: (
                              context,
                              controller,
                              focusNode,
                              onFieldSubmitted,
                            ) {
                              return TextFormField(
                                controller: controller,
                                focusNode: focusNode,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Enter project name',
                                  hintStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.7)),
                                  border: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.add,
                                        color: Colors.white),
                                    onPressed: () {
                                      if (controller.text.isNotEmpty) {
                                        _addNewProject(controller.text);
                                        controller.clear();
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // User profile section
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Text(
                        'P',
                        style: TextStyle(
                          color: Color(0xFF1B365C),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'PAVITRA P.',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(
                        Icons.logout,
                        color: Colors.white,
                      ),
                      onPressed: _handleLogout,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Main content area with history sidebar
          Expanded(
            child: Row(
              children: [
                // History sidebar - ย้ายมาด้านซ้าย
                Container(
                  width: 300,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    border: Border(
                      right: BorderSide(
                        // เปลี่ยนจาก left เป็น right
                        color: Color(0xFFE0E0E0),
                        width: 1,
                      ),
                    ),
                  ),
                  child: HistorySidebar(
                    historyItems: _historyItems,
                    onItemSelected: (item) {
                      print('Selected: ${item['description']}');
                    },
                    currency: 'THB',
                  ),
                ),
                // Main content
                const Expanded(
                  flex: 4,
                  child: MainPage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
