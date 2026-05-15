import 'package:flutter/material.dart';
import 'package:campusbuddy/services/auth_service.dart';
import 'package:campusbuddy/services/group_service.dart';
import 'package:campusbuddy/services/resource_service.dart';
import 'package:campusbuddy/services/qa_service.dart';
import 'package:campusbuddy/models/group_model.dart';
import 'package:campusbuddy/models/resource_model.dart';
import 'package:campusbuddy/models/question_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campusbuddy/screens/auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _authService.currentUser;
    if (user == null) return;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    setState(() {
      _userData = doc.data();
      _isLoading = false;
    });
  }

  void _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Logout',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(fontFamily: 'Poppins', color: Color(0xFF6B7280)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Logout',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Color(0xFFD32F2F),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _authService.logout();

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  void _editProfile() async {
    final nameController = TextEditingController(
      text: _userData?['name'] ?? '',
    );
    String? selectedCourse = _userData?['course'];
    String? selectedYear = _userData?['year'];

    final courses = [
      'BSc. Information Technology',
      'BSc. Computer Science',
      'BSc. Mathematics',
      'BSc. Statistics',
      'BSc. Physics',
      'BSc. Chemistry',
      'BSc. Biology',
      'BA. Economics',
      'BA. Accounting',
      'BA. Business Administration',
      'Other',
    ];

    final years = ['Level 100', 'Level 200', 'Level 300', 'Level 400'];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Profile',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0A1F44),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Color(0xFF0A1F44),
                ),
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    color: Color(0xFF6B7280),
                  ),
                  prefixIcon: const Icon(
                    Icons.person_outline_rounded,
                    color: Color(0xFF1A73E8),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE8F0FE)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE8F0FE)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFF1A73E8),
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedCourse,
                decoration: InputDecoration(
                  labelText: 'Course',
                  labelStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    color: Color(0xFF6B7280),
                  ),
                  prefixIcon: const Icon(
                    Icons.book_outlined,
                    color: Color(0xFF1A73E8),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE8F0FE)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE8F0FE)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFF1A73E8),
                      width: 2,
                    ),
                  ),
                ),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Color(0xFF0A1F44),
                  fontSize: 14,
                ),
                items: courses.map((course) {
                  return DropdownMenuItem(value: course, child: Text(course));
                }).toList(),
                onChanged: (value) =>
                    setModalState(() => selectedCourse = value),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedYear,
                decoration: InputDecoration(
                  labelText: 'Academic Year',
                  labelStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    color: Color(0xFF6B7280),
                  ),
                  prefixIcon: const Icon(
                    Icons.calendar_today_outlined,
                    color: Color(0xFF1A73E8),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE8F0FE)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE8F0FE)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFF1A73E8),
                      width: 2,
                    ),
                  ),
                ),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Color(0xFF0A1F44),
                  fontSize: 14,
                ),
                items: years.map((year) {
                  return DropdownMenuItem(value: year, child: Text(year));
                }).toList(),
                onChanged: (value) => setModalState(() => selectedYear = value),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    final user = _authService.currentUser;
                    if (user == null) return;

                    await _firestore.collection('users').doc(user.uid).update({
                      'name': nameController.text.trim(),
                      'course': selectedCourse,
                      'year': selectedYear,
                    });

                    await user.updateDisplayName(nameController.text.trim());

                    if (!context.mounted) return;
                    Navigator.pop(context);
                    _loadUserData();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Profile updated successfully! ✅',
                          style: TextStyle(fontFamily: 'Poppins'),
                        ),
                        backgroundColor: const Color(0xFF1A73E8),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A73E8),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0A1F44),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF1A73E8)),
            onPressed: _editProfile,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1A73E8)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Profile header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        // Avatar
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A73E8),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Center(
                            child: Text(
                              (_userData?['name'] ?? 'S')
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Name
                        Text(
                          _userData?['name'] ?? 'Student',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0A1F44),
                          ),
                        ),

                        const SizedBox(height: 4),

                        // Email
                        Text(
                          user?.email ?? '',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Course & Year badges
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F0FE),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _userData?['course'] ?? 'No course set',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A73E8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F0FE),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _userData?['year'] ?? 'No year set',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A73E8),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // University
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.school_outlined,
                              size: 14,
                              color: Color(0xFF6B7280),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _userData?['university'] ??
                                  'University of Cape Coast',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Stats card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'My Stats',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0A1F44),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            // Groups
                            Expanded(
                              child: StreamBuilder<List<GroupModel>>(
                                stream: GroupService().getMyGroups(),
                                builder: (context, snapshot) {
                                  return _buildStatItem(
                                    Icons.groups_rounded,
                                    '${snapshot.data?.length ?? 0}',
                                    'Groups',
                                    const Color(0xFF1A73E8),
                                  );
                                },
                              ),
                            ),
                            // Resources
                            Expanded(
                              child: StreamBuilder<List<ResourceModel>>(
                                stream: ResourceService().getMyResources(),
                                builder: (context, snapshot) {
                                  return _buildStatItem(
                                    Icons.folder_rounded,
                                    '${snapshot.data?.length ?? 0}',
                                    'Resources',
                                    const Color(0xFF2E7D32),
                                  );
                                },
                              ),
                            ),
                            // Questions
                            Expanded(
                              child: StreamBuilder<List<QuestionModel>>(
                                stream: QAService().getMyQuestions(),
                                builder: (context, snapshot) {
                                  return _buildStatItem(
                                    Icons.help_outline_rounded,
                                    '${snapshot.data?.length ?? 0}',
                                    'Questions',
                                    const Color(0xFFFF6D00),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Settings card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildSettingsItem(
                          Icons.edit_outlined,
                          'Edit Profile',
                          'Update your name, course & year',
                          onTap: _editProfile,
                        ),
                        const Divider(
                          color: Color(0xFFE8F0FE),
                          height: 1,
                          indent: 56,
                        ),
                        _buildSettingsItem(
                          Icons.notifications_outlined,
                          'Notifications',
                          'Manage your notifications',
                          onTap: () {},
                        ),
                        const Divider(
                          color: Color(0xFFE8F0FE),
                          height: 1,
                          indent: 56,
                        ),
                        _buildSettingsItem(
                          Icons.info_outline_rounded,
                          'About CampusBuddy',
                          'Version 1.0.0',
                          onTap: () {},
                        ),
                        const Divider(
                          color: Color(0xFFE8F0FE),
                          height: 1,
                          indent: 56,
                        ),
                        _buildSettingsItem(
                          Icons.logout_rounded,
                          'Logout',
                          'Sign out of your account',
                          onTap: _logout,
                          isDestructive: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // App version
                  const Text(
                    'CampusBuddy v1.0.0\nMade with ❤️ at UCC',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0A1F44),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(
    IconData icon,
    String title,
    String subtitle, {
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isDestructive
              ? const Color(0xFFFFEBEE)
              : const Color(0xFFE8F0FE),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isDestructive
              ? const Color(0xFFD32F2F)
              : const Color(0xFF1A73E8),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDestructive
              ? const Color(0xFFD32F2F)
              : const Color(0xFF0A1F44),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          color: Color(0xFF6B7280),
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: Color(0xFF6B7280),
      ),
    );
  }
}
