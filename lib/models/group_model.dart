import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  final String id;
  final String name;
  final String description;
  final String course;
  final String createdBy;
  final String createdByName;
  final List<String> members;
  final DateTime createdAt;
  final int maxMembers;

  GroupModel({
    required this.id,
    required this.name,
    required this.description,
    required this.course,
    required this.createdBy,
    required this.createdByName,
    required this.members,
    required this.createdAt,
    this.maxMembers = 20,
  });

  // Convert Firestore document to GroupModel
  factory GroupModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return GroupModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      course: data['course'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdByName: data['createdByName'] ?? '',
      members: List<String>.from(data['members'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      maxMembers: data['maxMembers'] ?? 20,
    );
  }

  // Convert GroupModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'course': course,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'members': members,
      'createdAt': FieldValue.serverTimestamp(),
      'maxMembers': maxMembers,
    };
  }

  // Check if a user is a member
  bool isMember(String uid) => members.contains(uid);

  // Get member count
  int get memberCount => members.length;

  // Check if group is full
  bool get isFull => members.length >= maxMembers;
}