import 'package:flutter/material.dart';
import 'package:campusbuddy/models/question_model.dart';
import 'package:campusbuddy/models/answer_model.dart';
import 'package:campusbuddy/services/qa_service.dart';
import 'package:campusbuddy/services/auth_service.dart';

class QuestionDetailScreen extends StatefulWidget {
  final QuestionModel question;

  const QuestionDetailScreen({super.key, required this.question});

  @override
  State<QuestionDetailScreen> createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends State<QuestionDetailScreen> {
  final QAService _qaService = QAService();
  final AuthService _authService = AuthService();
  final _answerController = TextEditingController();
  bool _isPosting = false;

  bool get _isQuestionAuthor =>
      widget.question.askedBy == _authService.currentUser?.uid;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _postAnswer() async {
    if (_answerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please write an answer',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: const Color(0xFFD32F2F),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() => _isPosting = true);

    final result = await _qaService.postAnswer(
      questionId: widget.question.id,
      body: _answerController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isPosting = false);

    if (result['success']) {
      _answerController.clear();
      FocusScope.of(context).unfocus();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result['message'],
          style: const TextStyle(fontFamily: 'Poppins'),
        ),
        backgroundColor: result['success']
            ? const Color(0xFF1A73E8)
            : const Color(0xFFD32F2F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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
          'Question',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0A1F44),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badges row
                        Row(
                          children: [
                            if (widget.question.isSolved)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle_rounded,
                                      size: 12,
                                      color: Color(0xFF2E7D32),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Solved',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2E7D32),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (widget.question.isSolved)
                              const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F0FE),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                widget.question.course.length > 25
                                    ? '${widget.question.course.substring(0, 25)}...'
                                    : widget.question.course,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A73E8),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Title
                        Text(
                          widget.question.title,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0A1F44),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Body
                        Text(
                          widget.question.body,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                            height: 1.6,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Footer
                        Row(
                          children: [
                            // Upvote
                            GestureDetector(
                              onTap: () => _qaService
                                  .upvoteQuestion(widget.question.id),
                              child: Row(
                                children: [
                                  Icon(
                                    widget.question.isUpvotedBy(
                                            _authService.currentUser?.uid ?? '')
                                        ? Icons.thumb_up_rounded
                                        : Icons.thumb_up_outlined,
                                    size: 18,
                                    color: widget.question.isUpvotedBy(
                                            _authService.currentUser?.uid ?? '')
                                        ? const Color(0xFF1A73E8)
                                        : const Color(0xFF6B7280),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${widget.question.upvoteCount}',
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 13,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const Spacer(),

                            // Asked by
                            Text(
                              'Asked by ${widget.question.askedByName}',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Answers section
                  Text(
                    '${widget.question.answerCount} Answer${widget.question.answerCount == 1 ? '' : 's'}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0A1F44),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Answers stream
                  StreamBuilder<List<AnswerModel>>(
                    stream: _qaService.getAnswers(widget.question.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF1A73E8),
                          ),
                        );
                      }

                      final answers = snapshot.data ?? [];

                      if (answers.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Column(
                            children: [
                              Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 40,
                                color: Color(0xFFE8F0FE),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'No answers yet',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              Text(
                                'Be the first to answer!',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: answers.length,
                        itemBuilder: (context, index) {
                          return _buildAnswerCard(answers[index]);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Answer input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _answerController,
                    maxLines: 3,
                    minLines: 1,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: Color(0xFF0A1F44),
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Write your answer...',
                      hintStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Color(0xFFE8F0FE)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Color(0xFFE8F0FE)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF1A73E8),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Send button
                GestureDetector(
                  onTap: _isPosting ? null : _postAnswer,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A73E8),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: _isPosting
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerCard(AnswerModel answer) {
    final currentUid = _authService.currentUser?.uid ?? '';
    final isUpvoted = answer.isUpvotedBy(currentUid);
    final isAuthor = answer.answeredBy == currentUid;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: answer.isAccepted
            ? const Color(0xFFE8F5E9)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: answer.isAccepted
            ? Border.all(color: const Color(0xFF2E7D32), width: 1.5)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Accepted badge
          if (answer.isAccepted)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: const [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: Color(0xFF2E7D32),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Accepted Answer',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
            ),

          // Answer body
          Text(
            answer.body,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Color(0xFF0A1F44),
              height: 1.6,
            ),
          ),

          const SizedBox(height: 12),

          // Footer
          Row(
            children: [
              // Upvote
              GestureDetector(
                onTap: () => _qaService.upvoteAnswer(
                  widget.question.id,
                  answer.id,
                ),
                child: Row(
                  children: [
                    Icon(
                      isUpvoted
                          ? Icons.thumb_up_rounded
                          : Icons.thumb_up_outlined,
                      size: 16,
                      color: isUpvoted
                          ? const Color(0xFF1A73E8)
                          : const Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${answer.upvoteCount}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: isUpvoted
                            ? const Color(0xFF1A73E8)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Accept answer button (only question author)
              if (_isQuestionAuthor && !answer.isAccepted)
                GestureDetector(
                  onTap: () => _acceptAnswer(answer),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: Color(0xFF2E7D32),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Accept',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const Spacer(),

              // Answered by
              Flexible(
                child: Text(
                  answer.answeredByName,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),

              // Delete button
              if (isAuthor) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _deleteAnswer(answer),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: Color(0xFFD32F2F),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _acceptAnswer(AnswerModel answer) async {
    final result = await _qaService.acceptAnswer(
      widget.question.id,
      answer.id,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result['message'],
          style: const TextStyle(fontFamily: 'Poppins'),
        ),
        backgroundColor: result['success']
            ? const Color(0xFF2E7D32)
            : const Color(0xFFD32F2F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _deleteAnswer(AnswerModel answer) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Answer',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Are you sure you want to delete this answer?',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Color(0xFFD32F2F),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final result = await _qaService.deleteAnswer(
      widget.question.id,
      answer.id,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result['message'],
          style: const TextStyle(fontFamily: 'Poppins'),
        ),
        backgroundColor: result['success']
            ? const Color(0xFF1A73E8)
            : const Color(0xFFD32F2F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}