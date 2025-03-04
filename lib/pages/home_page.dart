import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../components/history_sidebar.dart';
import 'login_page.dart';
import 'bop_analysis_page.dart';
import 'material_analysis_page.dart';
import 'packaging_analysis_page.dart';
import 'process_analysis_page.dart';
import 'main_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _selectedOption;
  final List<String> _options = ['BOP', 'Material', 'Packaging', 'Process'];

  // ใช้ตัวแปรนี้แทนสำหรับเก็บ ID ของ project ที่เลือก
  String? _selectedProjectId;
  final TextEditingController _projectNameController = TextEditingController();

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

  // ฟังก์ชันสำหรับ logout
  Future<void> _handleLogout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        // กลับไปหน้า login และล้าง stack
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to logout')),
      );
    }
  }

  // ฟังก์ชันสำหรับดึงข้อมูลผู้ใช้
  Future<String> _getUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      return doc.data()?['name'] ?? 'User';
    }
    return 'User';
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
  void _addNewProject(String projectName) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userRef =
            FirebaseFirestore.instance.collection('users').doc(user.uid);

        // เพิ่ม print เพื่อดู debug
        print('Creating project: $projectName for user: ${user.uid}');

        await FirebaseFirestore.instance.collection('projects').add({
          'name': projectName,
          'createdAt': FieldValue.serverTimestamp(),
          'createdBy': userRef,
        });

        // แสดง success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Project "$projectName" created successfully')),
          );
        }
      } else {
        throw Exception('User not logged in');
      }
    } catch (e) {
      // แสดง error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create project: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Error creating project: $e');
    }
  }

  // ดึงข้อมูล Projects ของ User
  Stream<QuerySnapshot> getUserProjects() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      return FirebaseFirestore.instance
          .collection('projects')
          .where('createdBy', isEqualTo: userRef)
          .orderBy('createdAt', descending: true)
          .snapshots();
    }
    throw Exception('User not logged in');
  }

  // แสดง Dialog สำหรับสร้าง Project ใหม่
  void _showCreateProjectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Project'),
        content: TextField(
          controller: _projectNameController,
          decoration: const InputDecoration(
            labelText: 'Project Name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_projectNameController.text.isNotEmpty) {
                _addNewProject(_projectNameController.text);
                _projectNameController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
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
                          child: StreamBuilder<QuerySnapshot>(
                            stream: getUserProjects(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}',
                                    style:
                                        const TextStyle(color: Colors.white));
                              }

                              // ถ้าไม่มีข้อมูล หรือ ข้อมูลว่างเปล่า
                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return const Text(
                                  'No projects yet',
                                  style: TextStyle(color: Colors.white70),
                                );
                              }

                              return DropdownButton<String>(
                                value: _selectedProjectId,
                                hint: const Text('Select Project',
                                    style: TextStyle(color: Colors.white)),
                                dropdownColor: const Color(0xFF1B365C),
                                style: const TextStyle(color: Colors.white),
                                underline: Container(
                                  height: 1,
                                  color: Colors.white,
                                ),
                                isExpanded: true,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedProjectId = newValue;
                                  });
                                },
                                items: snapshot.data!.docs.map((doc) {
                                  return DropdownMenuItem<String>(
                                    value: doc.id,
                                    child: Text(doc['name']),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.white),
                          onPressed: () => _showCreateProjectDialog(),
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
                    FutureBuilder<String>(
                      future: _getUserName(),
                      builder: (context, snapshot) {
                        return Text(
                          snapshot.data ?? 'Loading...',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(
                        Icons.logout,
                        color: Colors.white,
                      ),
                      onPressed: () => _handleLogout(context),
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
