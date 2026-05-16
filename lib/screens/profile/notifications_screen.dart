import 'package:flutter/material.dart';
import 'package:campusbuddy/services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Clear All Notifications',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Are you sure you want to delete all notifications?',
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
              'Clear All',
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
    await _notificationService.deleteAllNotifications();

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: const Text(
          'All notifications cleared',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        backgroundColor: const Color(0xFF1A73E8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Color(0xFF0A1F44),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0A1F44),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF0A1F44)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) async {
              if (value == 'mark_all_read') {
                await _notificationService.markAllAsRead();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'All notifications marked as read',
                      style: TextStyle(fontFamily: 'Poppins'),
                    ),
                    backgroundColor: const Color(0xFF1A73E8),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              } else if (value == 'clear_all') {
                _clearAll();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_all_read',
                child: Row(
                  children: [
                    Icon(
                      Icons.done_all_rounded,
                      color: Color(0xFF1A73E8),
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Mark all as read',
                      style: TextStyle(fontFamily: 'Poppins'),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_sweep_rounded,
                      color: Color(0xFFD32F2F),
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Clear all',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Color(0xFFD32F2F),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF1A73E8),
          unselectedLabelColor: const Color(0xFF6B7280),
          indicatorColor: const Color(0xFF1A73E8),
          labelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Unread'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationsList(showAll: true),
          _buildNotificationsList(showAll: false),
        ],
      ),
    );
  }

  Widget _buildNotificationsList({required bool showAll}) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _notificationService.getNotifications(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF1A73E8)),
          );
        }

        final allNotifications = snapshot.data ?? [];
        final notifications = showAll
            ? allNotifications
            : allNotifications.where((n) => !(n['isRead'] ?? false)).toList();

        if (notifications.isEmpty) {
          return Center(
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
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    size: 40,
                    color: Color(0xFF1A73E8),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  showAll ? 'No notifications yet' : 'No unread notifications',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0A1F44),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  showAll
                      ? 'You\'ll see notifications here when\nsomeone answers your question'
                      : 'You\'re all caught up! 🎉',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            final isRead = notification['isRead'] ?? false;

            return Dismissible(
              key: Key(notification['id']),
              direction: DismissDirection.endToStart,
              background: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFD32F2F),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(Icons.delete_rounded, color: Colors.white),
              ),
              onDismissed: (_) async {
                await _notificationService.deleteNotification(
                  notification['id'],
                );
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Notification deleted',
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
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isRead ? Colors.white : const Color(0xFFE8F0FE),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A73E8).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.question_answer_rounded,
                      color: Color(0xFF1A73E8),
                      size: 22,
                    ),
                  ),
                  title: Text(
                    notification['title'] ?? '',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                      color: const Color(0xFF0A1F44),
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        notification['body'] ?? '',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  trailing: !isRead
                      ? Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFF1A73E8),
                            shape: BoxShape.circle,
                          ),
                        )
                      : null,
                  onTap: () async {
                    if (!isRead) {
                      await _notificationService.markAsRead(notification['id']);
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
