import 'dart:io';
import 'package:campusbuddy/services/activity_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:campusbuddy/models/resource_model.dart';
import 'package:campusbuddy/services/auth_service.dart';

class ResourceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final AuthService _authService = AuthService();

  CollectionReference get _resources => _firestore.collection('resources');

  // Upload resource
  Future<Map<String, dynamic>> uploadResource({
    required String title,
    required String description,
    required String course,
    required File file,
    required String fileName,
    required String fileType,
  }) async {
    try {
      final user = _authService.currentUser;
      if (user == null) return {'success': false, 'message': 'Not logged in'};

      // Get user name
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userName =
          userDoc.data()?['name'] ??
          user.displayName ??
          user.email?.split('@').first ??
          'Unknown';

      // Upload file to Firebase Storage
      final storageRef = _storage
          .ref()
          .child('resources')
          .child(user.uid)
          .child('${DateTime.now().millisecondsSinceEpoch}_$fileName');

      final uploadTask = await storageRef.putFile(file);
      final fileUrl = await uploadTask.ref.getDownloadURL();
      final fileSize = await file.length();

      // Save metadata to Firestore
      await _resources.add({
        'title': title,
        'description': description,
        'course': course,
        'fileUrl': fileUrl,
        'fileName': fileName,
        'fileType': fileType,
        'fileSize': fileSize,
        'uploadedBy': user.uid,
        'uploadedByName': userName,
        'uploadedAt': FieldValue.serverTimestamp(),
      });

      //Log activity
      await ActivityService().logActivity(
        type: 'resource_uploaded',
        title: 'Uploaded a resource',
        subtitle: title,
      );

      return {'success': true, 'message': 'Resource uploaded successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to upload resource: $e'};
    }
  }

  // Get all resources
  Stream<List<ResourceModel>> getResources() {
    return _resources.orderBy('uploadedAt', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs
          .map((doc) => ResourceModel.fromFirestore(doc))
          .toList();
    });
  }

  // Get resources by course
  Stream<List<ResourceModel>> getResourcesByCourse(String course) {
    return _resources
        .where('course', isEqualTo: course)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ResourceModel.fromFirestore(doc))
              .toList();
        });
  }

  // Get my uploaded resources
  Stream<List<ResourceModel>> getMyResources() {
    final user = _authService.currentUser;
    if (user == null) return const Stream.empty();

    return _resources
        .where('uploadedBy', isEqualTo: user.uid)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ResourceModel.fromFirestore(doc))
              .toList();
        });
  }

  // Delete resource
  Future<Map<String, dynamic>> deleteResource(
    String resourceId,
    String fileUrl,
  ) async {
    try {
      final user = _authService.currentUser;
      if (user == null) return {'success': false, 'message': 'Not logged in'};

      // Delete from Storage
      await _storage.refFromURL(fileUrl).delete();

      // Delete from Firestore
      await _resources.doc(resourceId).delete();

      return {'success': true, 'message': 'Resource deleted successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to delete resource'};
    }
  }
}
