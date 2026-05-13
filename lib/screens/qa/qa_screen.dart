import 'package:flutter/material.dart';
import 'package:campusbuddy/models/question_model.dart';
import 'package:campusbuddy/services/qa_service.dart';
import 'package:campusbuddy/services/auth_service.dart';
import 'package:campusbuddy/screens/qa/ask_question_screen.dart';
import 'package:campusbuddy/screens/qa/question_detail_screen.dart';

class QAScreen extends StatefulWidget {
  const QAScreen({super.key});

  @override
  State<QAScreen> createState() => _QAScreenState();
}

class _QAScreenState extends State<QAScreen>
    with SingleTickerProviderStateMixin {
  final QAService _qaService = QAService();
  final AuthService _authService = AuthService();
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Q&A',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0A1F44),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF1A73E8),
          unselectedLabelColor: const Color(0xFF6B7280),
          indicatorColor: const Color(0xFF1A73E8),
          labelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: 'All Questions'),
            Tab(text: 'My Questions'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: Color(0xFF0A1F44),
              ),
              decoration: InputDecoration(
                hintText: 'Search questions...',
                hintStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Color(0xFF6B7280),
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF1A73E8),
                ),
                filled: true,
                fillColor: const Color(0xFFF8FAFF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE8F0FE)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE8F0FE)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF1A73E8),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllQuestions(),
                _buildMyQuestions(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AskQuestionScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFF1A73E8),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Ask Question',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildAllQuestions() {
    return StreamBuilder<List<QuestionModel>>(
      stream: _qaService.getQuestions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF1A73E8)),
          );
        }

        if (snapshot.hasError) {
          return _buildEmptyState(
            icon: Icons.question_answer_outlined,
            title: 'No questions yet',
            subtitle: 'Be the first to ask a question!',
          );
        }

        final questions = snapshot.data ?? [];
        final filtered = questions
            .where((q) =>
                q.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                q.course.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

        if (filtered.isEmpty) {
          return _buildEmptyState(
            icon: Icons.question_answer_outlined,
            title: 'No questions yet',
            subtitle: 'Be the first to ask a question!',
          );
        }

        return RefreshIndicator(
          color: const Color(0xFF1A73E8),
          onRefresh: () async => setState(() {}),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              return _buildQuestionCard(filtered[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildMyQuestions() {
    return StreamBuilder<List<QuestionModel>>(
      stream: _qaService.getMyQuestions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF1A73E8)),
          );
        }

        final questions = snapshot.data ?? [];
        final filtered = questions
            .where((q) =>
                q.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                q.course.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

        if (filtered.isEmpty) {
          return _buildEmptyState(
            icon: Icons.help_outline_rounded,
            title: 'No questions asked yet',
            subtitle: 'Ask your first question!',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            return _buildQuestionCard(
              filtered[index],
              showDelete: true,
            );
          },
        );
      },
    );
  }

  Widget _buildQuestionCard(QuestionModel question, {bool showDelete = false}) {
    final currentUid = _authService.currentUser?.uid ?? '';
    final isUpvoted = question.isUpvotedBy(currentUid);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuestionDetailScreen(question: question),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Solved badge
                if (question.isSolved)
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

                if (question.isSolved) const SizedBox(width: 8),

                // Course badge
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
                    question.course.length > 20
                        ? '${question.course.substring(0, 20)}...'
                        : question.course,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A73E8),
                    ),
                  ),
                ),

                const Spacer(),

                // Delete button
                if (showDelete)
                  GestureDetector(
                    onTap: () => _deleteQuestion(question),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Color(0xFFD32F2F),
                      size: 20,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            // Title
            Text(
              question.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0A1F44),
              ),
            ),

            const SizedBox(height: 6),

            // Body preview
            Text(
              question.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
            ),

            const SizedBox(height: 12),

            // Footer
            Row(
              children: [
                // Upvote button
                GestureDetector(
                  onTap: () => _qaService.upvoteQuestion(question.id),
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
                        '${question.upvoteCount}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: isUpvoted
                              ? const Color(0xFF1A73E8)
                              : const Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Answer count
                const Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 16,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(width: 4),
                Text(
                  '${question.answerCount} answers',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),

                const Spacer(),

                // Asked by
                Flexible(
                  child: Text(
                    question.askedByName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _deleteQuestion(QuestionModel question) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Question',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Are you sure? All answers will also be deleted.',
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

    final result = await _qaService.deleteQuestion(question.id);

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

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0FE),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(icon, size: 40, color: const Color(0xFF1A73E8)),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0A1F44),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}