import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionModel {
  final String id;
  final String title;
  final String body;
  final String course;
  final String askedBy;
  final String askedByName;
  final DateTime askedAt;
  final List<String> upvotes;
  final int answerCount;
  final bool isSolved;
  final String? acceptedAnswerId;

  QuestionModel({
    required this.id,
    required this.title,
    required this.body,
    required this.course,
    required this.askedBy,
    required this.askedByName,
    required this.askedAt,
    required this.upvotes,
    required this.answerCount,
    required this.isSolved,
    this.acceptedAnswerId,
  });

  factory QuestionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return QuestionModel(
      id: doc.id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      course: data['course'] ?? '',
      askedBy: data['askedBy'] ?? '',
      askedByName: data['askedByName'] ?? '',
      askedAt: (data['askedAt'] as Timestamp).toDate(),
      upvotes: List<String>.from(data['upvotes'] ?? []),
      answerCount: data['answerCount'] ?? 0,
      isSolved: data['isSolved'] ?? false,
      acceptedAnswerId: data['acceptedAnswerId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'body': body,
      'course': course,
      'askedBy': askedBy,
      'askedByName': askedByName,
      'askedAt': FieldValue.serverTimestamp(),
      'upvotes': upvotes,
      'answerCount': answerCount,
      'isSolved': isSolved,
      'acceptedAnswerId': acceptedAnswerId,
    };
  }

  int get upvoteCount => upvotes.length;
  bool isUpvotedBy(String uid) => upvotes.contains(uid);
}