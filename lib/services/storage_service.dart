import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campusbuddy/services/auth_service.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  Future<String?> uploadProfilePhoto(File imageFile) async {
    try {
      final user = _authService.currentUser;
      if (user == null) return null;

      final storageRef = _storage
          .ref()
          .child('profile_photos')
          .child('${user.uid}.jpg');

      final uploadTask = await storageRef.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final photoUrl = await uploadTask.ref.getDownloadURL();

      // Save to Firestore and Firebase Auth
      await _firestore.collection('users').doc(user.uid).update({
        'profileImage': photoUrl,
      });

      await user.updatePhotoURL(photoUrl);

      return photoUrl;
    } catch (e) {
      return null;
    }
  }
}