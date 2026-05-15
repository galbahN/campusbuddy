import 'package:campusbuddy/models/question_model.dart';
import 'package:campusbuddy/services/activity_service.dart';
import 'package:campusbuddy/services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campusbuddy/models/answer_model.dart';
import 'package:campusbuddy/services/auth_service.dart';

class QAService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  CollectionReference get _questions => _firestore.collection('questions');

  // ==================== QUESTIONS ====================

  // Ask a question
  Future<Map<String, dynamic>> askQuestion({
    required String title,
    required String body,
    required String course,
  }) async {
    try {
      final user = _authService.currentUser;
      if (user == null) return {'success': false, 'message': 'Not logged in'};

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userName =
          userDoc.data()?['name'] ??
          user.displayName ??
          user.email?.split('@').first ??
          'Unknown';

      await _questions.add({
        'title': title,
        'body': body,
        'course': course,
        'askedBy': user.uid,
        'askedByName': userName,
        'askedAt': FieldValue.serverTimestamp(),
        'upvotes': [],
        'answerCount': 0,
        'isSolved': false,
        'acceptedAnswerId': null,
      });

      // Log activity
      await ActivityService().logActivity(
        type: 'question_asked',
        title: 'Asked a question',
        subtitle: title,
      );

      return {'success': true, 'message': 'Question posted successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to post question'};
    }
  }

  // Get all questions
  Stream<List<QuestionModel>> getQuestions() {
    return _questions.orderBy('askedAt', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs
          .map((doc) => QuestionModel.fromFirestore(doc))
          .toList();
    });
  }

  // Get questions by course
  Stream<List<QuestionModel>> getQuestionsByCourse(String course) {
    return _questions
        .where('course', isEqualTo: course)
        .orderBy('askedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => QuestionModel.fromFirestore(doc))
              .toList();
        });
  }

  // Get my questions
  Stream<List<QuestionModel>> getMyQuestions() {
    final user = _authService.currentUser;
    if (user == null) return const Stream.empty();

    return _questions
        .where('askedBy', isEqualTo: user.uid)
        .orderBy('askedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => QuestionModel.fromFirestore(doc))
              .toList();
        });
  }

  // Upvote a question
  Future<Map<String, dynamic>> upvoteQuestion(String questionId) async {
    try {
      final user = _authService.currentUser;
      if (user == null) return {'success': false, 'message': 'Not logged in'};

      final questionDoc = await _questions.doc(questionId).get();
      final question = QuestionModel.fromFirestore(questionDoc);

      if (question.isUpvotedBy(user.uid)) {
        // Remove upvote
        await _questions.doc(questionId).update({
          'upvotes': FieldValue.arrayRemove([user.uid]),
        });
        return {'success': true, 'message': 'Upvote removed'};
      } else {
        // Add upvote
        await _questions.doc(questionId).update({
          'upvotes': FieldValue.arrayUnion([user.uid]),
        });
        return {'success': true, 'message': 'Question upvoted'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Failed to upvote'};
    }
  }

  // Delete question
  Future<Map<String, dynamic>> deleteQuestion(String questionId) async {
    try {
      final user = _authService.currentUser;
      if (user == null) return {'success': false, 'message': 'Not logged in'};

      final questionDoc = await _questions.doc(questionId).get();
      final question = QuestionModel.fromFirestore(questionDoc);

      if (question.askedBy != user.uid) {
        return {
          'success': false,
          'message': 'Only the author can delete this question',
        };
      }

      // Delete all answers first
      final answers = await _questions
          .doc(questionId)
          .collection('answers')
          .get();
      for (var answer in answers.docs) {
        await answer.reference.delete();
      }

      await _questions.doc(questionId).delete();

      return {'success': true, 'message': 'Question deleted successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to delete question'};
    }
  }

  // ==================== ANSWERS ====================
  // Post an answer
  Future<Map<String, dynamic>> postAnswer({
    required String questionId,
    required String body,
  }) async {
    try {
      final user = _authService.currentUser;
      if (user == null) return {'success': false, 'message': 'Not logged in'};

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userName =
          userDoc.data()?['name'] ??
          user.displayName ??
          user.email?.split('@').first ??
          'Unknown';

      // Add answer as subcollection
      await _questions.doc(questionId).collection('answers').add({
        'questionId': questionId,
        'body': body,
        'answeredBy': user.uid,
        'answeredByName': userName,
        'answeredAt': FieldValue.serverTimestamp(),
        'upvotes': [],
        'isAccepted': false,
      });

      // Increment answer count
      await _questions.doc(questionId).update({
        'answerCount': FieldValue.increment(1),
      });

      // Send notification to question author
      final questionDoc = await _questions.doc(questionId).get();
      final questionData = questionDoc.data() as Map<String, dynamic>;
      final questionAuthorId = questionData['askedBy'];
      final questionTitle = questionData['title'];

      // Only notify if answerer is not the question author
      if (questionAuthorId != user.uid) {
        await NotificationService().notifyQuestionAnswered(
          questionAuthorId: questionAuthorId,
          questionTitle: questionTitle,
          answeredByName: userName,
        );
      }

      //Log activity
      await ActivityService().logActivity(
        type: 'answer_posted',
        title: 'Answered a question',
        subtitle: body.length > 50 ? '${body.substring(0, 50)}...' : body,
      );

      return {'success': true, 'message': 'Answer posted successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to post answer'};
    }
  }

  // Get answers for a question
  Stream<List<AnswerModel>> getAnswers(String questionId) {
    return _questions
        .doc(questionId)
        .collection('answers')
        .orderBy('answeredAt', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => AnswerModel.fromFirestore(doc))
              .toList();
        });
  }

  // Upvote an answer
  Future<Map<String, dynamic>> upvoteAnswer(
    String questionId,
    String answerId,
  ) async {
    try {
      final user = _authService.currentUser;
      if (user == null) return {'success': false, 'message': 'Not logged in'};

      final answerRef = _questions
          .doc(questionId)
          .collection('answers')
          .doc(answerId);

      final answerDoc = await answerRef.get();
      final answer = AnswerModel.fromFirestore(answerDoc);

      if (answer.isUpvotedBy(user.uid)) {
        await answerRef.update({
          'upvotes': FieldValue.arrayRemove([user.uid]),
        });
        return {'success': true, 'message': 'Upvote removed'};
      } else {
        await answerRef.update({
          'upvotes': FieldValue.arrayUnion([user.uid]),
        });
        return {'success': true, 'message': 'Answer upvoted'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Failed to upvote answer'};
    }
  }

  // Accept an answer
  Future<Map<String, dynamic>> acceptAnswer(
    String questionId,
    String answerId,
  ) async {
    try {
      final user = _authService.currentUser;
      if (user == null) return {'success': false, 'message': 'Not logged in'};

      final questionDoc = await _questions.doc(questionId).get();
      final question = QuestionModel.fromFirestore(questionDoc);

      if (question.askedBy != user.uid) {
        return {
          'success': false,
          'message': 'Only the question author can accept an answer',
        };
      }

      // Mark answer as accepted
      await _questions
          .doc(questionId)
          .collection('answers')
          .doc(answerId)
          .update({'isAccepted': true});

      // Mark question as solved
      await _questions.doc(questionId).update({
        'isSolved': true,
        'acceptedAnswerId': answerId,
      });

      return {'success': true, 'message': 'Answer accepted!'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to accept answer'};
    }
  }

  // Delete answer
  Future<Map<String, dynamic>> deleteAnswer(
    String questionId,
    String answerId,
  ) async {
    try {
      final user = _authService.currentUser;
      if (user == null) return {'success': false, 'message': 'Not logged in'};

      final answerRef = _questions
          .doc(questionId)
          .collection('answers')
          .doc(answerId);

      final answerDoc = await answerRef.get();
      final answer = AnswerModel.fromFirestore(answerDoc);

      if (answer.answeredBy != user.uid) {
        return {
          'success': false,
          'message': 'Only the author can delete this answer',
        };
      }

      await answerRef.delete();

      // Decrement answer count
      await _questions.doc(questionId).update({
        'answerCount': FieldValue.increment(-1),
      });

      return {'success': true, 'message': 'Answer deleted successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to delete answer'};
    }
  }
}
