import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campusbuddy/services/auth_service.dart';

class ActivityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  CollectionReference get _activities =>
      _firestore.collection('activities');

  // Log an activity
  Future<void> logActivity({
    required String type,
    required String title,
    required String subtitle,
  }) async {
    try {
      final user = _authService.currentUser;
      if (user == null) return;

      await _activities.add({
        'userId': user.uid,
        'type': type,
        'title': title,
        'subtitle': subtitle,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Silently fail
    }
  }

  // Get recent activity for current user
  Stream<List<Map<String, dynamic>>> getRecentActivity() {
    final user = _authService.currentUser;
    if (user == null) return const Stream.empty();

    return _activities
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
            .toList());
  }
}