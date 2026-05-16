import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:campusbuddy/services/auth_service.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initialize() async {
    // Request permission
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(initSettings);

    // Create notification channel
    const channel = AndroidNotificationChannel(
      'campusbuddy_channel',
      'CampusBuddy Notifications',
      description: 'Notifications for CampusBuddy',
      importance: Importance.high,
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(channel);
    }

    // Save FCM token
    await _saveToken();

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      _showLocalNotification(message);
    });
  }

  Future<void> _saveToken() async {
    final user = _authService.currentUser;
    if (user == null) return;

    final token = await _fcm.getToken();
    if (token != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'fcmToken': token,
      });
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'campusbuddy_channel',
      'CampusBuddy Notifications',
      channelDescription: 'Notifications for CampusBuddy',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      0,
      message.notification?.title ?? 'CampusBuddy',
      message.notification?.body ?? '',
      details,
    );
  }

  // Send notification when question is answered
  Future<void> notifyQuestionAnswered({
    required String questionAuthorId,
    required String questionTitle,
    required String answeredByName,
  }) async {
    try {
      // Save notification to Firestore
      await _firestore.collection('notifications').add({
        'userId': questionAuthorId,
        'title': 'New Answer! 💡',
        'body': '$answeredByName answered your question: "$questionTitle"',
        'type': 'answer',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Silently fail
    }
  }

  // Get unread notifications count
  Stream<int> getUnreadCount() {
    final user = _authService.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Get all notifications
  Stream<List<Map<String, dynamic>>> getNotifications() {
    final user = _authService.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }

  // Mark all as read
  Future<void> markAllAsRead() async {
    final user = _authService.currentUser;
    if (user == null) return;

    final batch = _firestore.batch();
    final notifications = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in notifications.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  // Delete single notification
  Future<void> deleteNotification(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).delete();
  }

  // Delete all notifications
  Future<void> deleteAllNotifications() async {
    final user = _authService.currentUser;
    if (user == null) return;

    final batch = _firestore.batch();
    final notifications = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .get();

    for (var doc in notifications.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
