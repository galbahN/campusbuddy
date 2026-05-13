import 'package:cloud_firestore/cloud_firestore.dart';

class AnswerModel {
  final String id;
  final String questionId;
  final String body;
  final String answeredBy;
  final String answeredByName;
  final DateTime answeredAt;
  final List<String> upvotes;
  final bool isAccepted;

  AnswerModel({
    required this.id,
    required this.questionId,
    required this.body,
    required this.answeredBy,
    required this.answeredByName,
    required this.answeredAt,
    required this.upvotes,
    required this.isAccepted,
  });

  factory AnswerModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AnswerModel(
      id: doc.id,
      questionId: data['questionId'] ?? '',
      body: data['body'] ?? '',
      answeredBy: data['answeredBy'] ?? '',
      answeredByName: data['answeredByName'] ?? '',
      answeredAt: (data['answeredAt'] as Timestamp).toDate(),
      upvotes: List<String>.from(data['upvotes'] ?? []),
      isAccepted: data['isAccepted'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'questionId': questionId,
      'body': body,
      'answeredBy': answeredBy,
      'answeredByName': answeredByName,
      'answeredAt': FieldValue.serverTimestamp(),
      'upvotes': upvotes,
      'isAccepted': isAccepted,
    };
  }

  int get upvoteCount => upvotes.length;
  bool isUpvotedBy(String uid) => upvotes.contains(uid);
}