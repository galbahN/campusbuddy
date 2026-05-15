import 'package:campusbuddy/services/activity_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campusbuddy/models/group_model.dart';
import 'package:campusbuddy/services/auth_service.dart';

class GroupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // Collection reference
  CollectionReference get _groups => _firestore.collection('groups');

  // Create a new group
  Future<Map<String, dynamic>> createGroup({
    required String name,
    required String description,
    required String course,
    int maxMembers = 20,
  }) async {
    try {
      final user = _authService.currentUser;
      if (user == null) return {'success': false, 'message': 'Not logged in'};

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userName = userDoc.data()?['name'] ?? 'Unknown';

      await _groups.add({
        'name': name,
        'description': description,
        'course': course,
        'createdBy': user.uid,
        'createdByName': userName,
        'members': [user.uid],
        'createdAt': FieldValue.serverTimestamp(),
        'maxMembers': maxMembers,
      });

      // Log the activity
      await ActivityService().logActivity(
        type: 'group_created',
        title: 'Created a study group',
        subtitle: name,
      );

      return {'success': true, 'message': 'Group created successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to create group'};
    }
  }

  // Get all groups
  Stream<List<GroupModel>> getGroups() {
    return _groups.orderBy('createdAt', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) => GroupModel.fromFirestore(doc)).toList();
    });
  }

  // Get my groups
  Stream<List<GroupModel>> getMyGroups() {
    final user = _authService.currentUser;
    if (user == null) return const Stream.empty();

    return _groups
        .where('members', arrayContains: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => GroupModel.fromFirestore(doc))
              .toList();
        });
  }

  // Get groups by course
  Stream<List<GroupModel>> getGroupsByCourse(String course) {
    return _groups
        .where('course', isEqualTo: course)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => GroupModel.fromFirestore(doc))
              .toList();
        });
  }

  // Join a group
  Future<Map<String, dynamic>> joinGroup(String groupId) async {
    try {
      final user = _authService.currentUser;
      if (user == null) return {'success': false, 'message': 'Not logged in'};

      final groupDoc = await _groups.doc(groupId).get();
      final group = GroupModel.fromFirestore(groupDoc);

      if (group.isFull) {
        return {'success': false, 'message': 'This group is full'};
      }

      if (group.isMember(user.uid)) {
        return {'success': false, 'message': 'You are already in this group'};
      }

      await _groups.doc(groupId).update({
        'members': FieldValue.arrayUnion([user.uid]),
      });

      // Log the activity
      await ActivityService().logActivity(
        type: 'group_joined',
        title: 'Joined a study group',
        subtitle: group.name,
      );

      return {'success': true, 'message': 'Joined group successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to join group'};
    }
  }

  // Leave a group
  Future<Map<String, dynamic>> leaveGroup(String groupId) async {
    try {
      final user = _authService.currentUser;
      if (user == null) return {'success': false, 'message': 'Not logged in'};

      await _groups.doc(groupId).update({
        'members': FieldValue.arrayRemove([user.uid]),
      });

      return {'success': true, 'message': 'Left group successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to leave group'};
    }
  }

  // Delete a group (only creator can delete)
  Future<Map<String, dynamic>> deleteGroup(String groupId) async {
    try {
      final user = _authService.currentUser;
      if (user == null) return {'success': false, 'message': 'Not logged in'};

      final groupDoc = await _groups.doc(groupId).get();
      final group = GroupModel.fromFirestore(groupDoc);

      if (group.createdBy != user.uid) {
        return {
          'success': false,
          'message': 'Only the creator can delete this group',
        };
      }

      await _groups.doc(groupId).delete();

      return {'success': true, 'message': 'Group deleted successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to delete group'};
    }
  }

  // Get members details for a group
  Future<List<Map<String, dynamic>>> getGroupMembers(
    List<String> memberIds,
  ) async {
    try {
      List<Map<String, dynamic>> members = [];
      for (String uid in memberIds) {
        final doc = await _firestore.collection('users').doc(uid).get();
        if (doc.exists) {
          members.add({
            'uid': uid,
            'name': doc.data()?['name'] ?? 'Unknown',
            'course': doc.data()?['course'] ?? '',
            'year': doc.data()?['year'] ?? '',
          });
        }
      }
      return members;
    } catch (e) {
      return [];
    }
  }
}
