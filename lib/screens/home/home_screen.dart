import 'package:campusbuddy/screens/profile/profile_screen.dart';
import 'package:campusbuddy/services/activity_service.dart';
import 'package:campusbuddy/services/notification_service.dart';
import 'package:campusbuddy/services/qa_service.dart';
import 'package:campusbuddy/models/question_model.dart';
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
      const ProfileScreen(),
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

void _showNotifications(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text(
                'Notifications',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0A1F44),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  NotificationService().markAllAsRead();
                  Navigator.pop(context);
                },
                child: const Text(
                  'Mark all read',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Color(0xFF1A73E8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE8F0FE)),
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: NotificationService().getNotifications(),
            builder: (context, snapshot) {
              final notifications = snapshot.data ?? [];

              if (notifications.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none_rounded,
                        size: 48,
                        color: Color(0xFFE8F0FE),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'No notifications yet',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  final isRead = notification['isRead'] ?? false;

                  return ListTile(
                    tileColor: isRead ? Colors.white : const Color(0xFFE8F0FE),
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A73E8).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.question_answer_rounded,
                        color: Color(0xFF1A73E8),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      notification['title'] ?? '',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0A1F44),
                      ),
                    ),
                    subtitle: Text(
                      notification['body'] ?? '',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    onTap: () {
                      NotificationService().markAsRead(notification['id']);
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    ),
  );
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
                Row(
                  children: [
                    // Notification bell
                    StreamBuilder<int>(
                      stream: NotificationService().getUnreadCount(),
                      builder: (context, snapshot) {
                        final count = snapshot.data ?? 0;
                        return GestureDetector(
                          onTap: () => _showNotifications(context),
                          child: Stack(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F0FE),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.notifications_outlined,
                                  color: Color(0xFF1A73E8),
                                  size: 24,
                                ),
                              ),
                              if (count > 0)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFD32F2F),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        count > 9 ? '9+' : '$count',
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(width: 8),

                    // School icon
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
                    return StreamBuilder<List<QuestionModel>>(
                      stream: QAService().getMyQuestions(),
                      builder: (context, qaSnapshot) {
                        final myQACount = qaSnapshot.data?.length ?? 0;
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
                              'Questions\nAsked',
                              myQACount.toString(),
                              Icons.question_answer_rounded,
                            ),
                          ],
                        );
                      },
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

            StreamBuilder<List<Map<String, dynamic>>>(
              stream: ActivityService().getRecentActivity(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF1A73E8)),
                  );
                }

                final activities = snapshot.data ?? [];

                if (activities.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.inbox_rounded,
                          size: 48,
                          color: Color(0xFFE8F0FE),
                        ),
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
                  );
                }

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: activities.length,
                    separatorBuilder: (_, _) => const Divider(
                      color: Color(0xFFE8F0FE),
                      height: 1,
                      indent: 70,
                    ),
                    itemBuilder: (context, index) {
                      final activity = activities[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _getActivityColor(
                              activity['type'],
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getActivityIcon(activity['type']),
                            color: _getActivityColor(activity['type']),
                            size: 22,
                          ),
                        ),
                        title: Text(
                          activity['title'] ?? '',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0A1F44),
                          ),
                        ),
                        subtitle: Text(
                          activity['subtitle'] ?? '',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
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

IconData _getActivityIcon(String type) {
  switch (type) {
    case 'group_created':
      return Icons.group_add_rounded;
    case 'group_joined':
      return Icons.groups_rounded;
    case 'resource_uploaded':
      return Icons.upload_file_rounded;
    case 'question_asked':
      return Icons.help_outline_rounded;
    case 'answer_posted':
      return Icons.question_answer_rounded;
    default:
      return Icons.circle_notifications_rounded;
  }
}

Color _getActivityColor(String type) {
  switch (type) {
    case 'group_created':
    case 'group_joined':
      return const Color(0xFF1A73E8);
    case 'resource_uploaded':
      return const Color(0xFF2E7D32);
    case 'question_asked':
      return const Color(0xFFFF6D00);
    case 'answer_posted':
      return const Color(0xFF6A1B9A);
    default:
      return const Color(0xFF6B7280);
  }
}
