import 'package:campusbuddy/models/group_model.dart';
import 'package:campusbuddy/models/resource_model.dart';
import 'package:campusbuddy/screens/groups/group_screen.dart';
import 'package:campusbuddy/screens/qa/qa_screen.dart';
import 'package:campusbuddy/screens/resource_screen.dart';
import 'package:campusbuddy/services/auth_service.dart';
import 'package:campusbuddy/services/group_service.dart';
import 'package:campusbuddy/services/resource_service.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void navigateTo(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _HomePage(onNavigate: navigateTo),
      const GroupsScreen(),
      const ResourcesScreen(),
      const QAScreen(),
      const _PlaceholderPage(
        icon: Icons.person_rounded,
        title: 'Profile',
        subtitle: 'Coming soon — manage your profile',
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF1A73E8),
          unselectedItemColor: const Color(0xFF6B7280),
          selectedLabelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
          ),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.groups_outlined),
              activeIcon: Icon(Icons.groups_rounded),
              label: 'Groups',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder_outlined),
              activeIcon: Icon(Icons.folder_rounded),
              label: 'Resources',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.question_answer_outlined),
              activeIcon: Icon(Icons.question_answer_rounded),
              label: 'Q&A',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// Home Tab
class _HomePage extends StatelessWidget {
  final Function(int) onNavigate;

  const _HomePage({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${user?.displayName?.split(' ').first ?? 'Student'} 👋',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0A1F44),
                      ),
                    ),
                    const Text(
                      'Welcome to CampusBuddy',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A73E8),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Stats row
            StreamBuilder<List<GroupModel>>(
              stream: GroupService().getMyGroups(),
              builder: (context, groupSnapshot) {
                final myGroupsCount = groupSnapshot.data?.length ?? 0;
                return StreamBuilder<List<ResourceModel>>(
                  stream: ResourceService().getMyResources(),
                  builder: (context, resourceSnapshot) {
                    final myResourcesCount = resourceSnapshot.data?.length ?? 0;
                    return Row(
                      children: [
                        _buildStatCard(
                          'Study\nGroups',
                          myGroupsCount.toString(),
                          Icons.groups_rounded,
                        ),
                        const SizedBox(width: 12),
                        _buildStatCard(
                          'Resources\nShared',
                          myResourcesCount.toString(),
                          Icons.folder_rounded,
                        ),
                        const SizedBox(width: 12),
                        _buildStatCard(
                          'Q&A\nAnswered',
                          '0',
                          Icons.question_answer_rounded,
                        ),
                      ],
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 28),

            // Quick actions
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0A1F44),
              ),
            ),

            const SizedBox(height: 16),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                _buildActionCard(
                  'Find Study Group',
                  Icons.groups_rounded,
                  const Color(0xFF1A73E8),
                  onTap: () => onNavigate(1),
                ),
                _buildActionCard(
                  'Share Resource',
                  Icons.upload_file_rounded,
                  const Color(0xFF0D47A1),
                  onTap: () => onNavigate(2),
                ),
                _buildActionCard(
                  'Ask a Question',
                  Icons.help_outline_rounded,
                  const Color(0xFF1A73E8),
                  onTap: () => onNavigate(3),
                ),
                _buildActionCard(
                  'Browse Notes',
                  Icons.menu_book_rounded,
                  const Color(0xFF0D47A1),
                  onTap: () => onNavigate(2),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Recent activity
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0A1F44),
              ),
            ),

            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(Icons.inbox_rounded, size: 48, color: Color(0xFFE8F0FE)),
                  SizedBox(height: 12),
                  Text(
                    'No activity yet',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  Text(
                    'Start by joining a study group!',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Color(0xFF6B7280),
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

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF1A73E8), size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0A1F44),
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0A1F44),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder page
class _PlaceholderPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _PlaceholderPage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FE),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, size: 40, color: const Color(0xFF1A73E8)),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0A1F44),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
