import 'package:campusbuddy/screens/groups/group_chat_screen.dart';
import 'package:campusbuddy/services/group_service.dart';
import 'package:campusbuddy/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:campusbuddy/models/group_model.dart';
import 'package:campusbuddy/services/auth_service.dart';

class GroupDetailScreen extends StatefulWidget {
  final GroupModel group;

  const GroupDetailScreen({super.key, required this.group});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final GroupService _groupService = GroupService();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  bool get _isMember =>
      widget.group.isMember(_authService.currentUser?.uid ?? '');

  bool get _isCreator =>
      widget.group.createdBy == _authService.currentUser?.uid;

  void _joinOrLeave() async {
    setState(() => _isLoading = true);

    final result = _isMember
        ? await _groupService.leaveGroup(widget.group.id)
        : await _groupService.joinGroup(widget.group.id);

    if (!mounted) return;
    setState(() => _isLoading = false);

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    if (result['success']) Navigator.pop(context);
  }

  void _deleteGroup() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Group',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Are you sure you want to delete this group? This cannot be undone.',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(fontFamily: 'Poppins', color: Color(0xFF6B7280)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(fontFamily: 'Poppins', color: Color(0xFFD32F2F)),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    final result = await _groupService.deleteGroup(widget.group.id);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success']) {
      Navigator.pop(context);
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      floatingActionButton: _isMember
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GroupChatScreen(group: widget.group),
                  ),
                );
              },
              backgroundColor: const Color(0xFF1A73E8),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.chat_rounded),
              label: const Text(
                'Group Chat',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
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
        title: Text(
          widget.group.name,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0A1F44),
          ),
        ),
        actions: [
          if (_isCreator)
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFD32F2F),
              ),
              onPressed: _deleteGroup,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0FE),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.groups_rounded,
                      size: 40,
                      color: Color(0xFF1A73E8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.group.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0A1F44),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0FE),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.group.course,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A73E8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.people_outline_rounded,
                        size: 16,
                        color: Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.group.memberCount}/${widget.group.maxMembers} members',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.person_outline_rounded,
                        size: 16,
                        color: Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'by ${widget.group.createdByName}',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Description
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
                  const Text(
                    'About this group',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0A1F44),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.group.description,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            // Members list
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
                  Row(
                    children: [
                      const Text(
                        'Members',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0A1F44),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F0FE),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${widget.group.memberCount}/${widget.group.maxMembers}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A73E8),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: GroupService().getGroupMembers(
                      widget.group.members,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF1A73E8),
                          ),
                        );
                      }

                      final members = snapshot.data ?? [];

                      if (members.isEmpty) {
                        return const Text(
                          'No members found',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Color(0xFF6B7280),
                          ),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: members.length,
                        separatorBuilder: (_, _) =>
                            const Divider(color: Color(0xFFE8F0FE), height: 1),
                        itemBuilder: (context, index) {
                          final member = members[index];
                          final isCreator =
                              member['uid'] == widget.group.createdBy;
                          final isCurrentUser =
                              member['uid'] == AuthService().currentUser?.uid;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                // Avatar
                                UserAvatar(
                                  photoUrl: member['profileImage'],
                                  name: member['name'],
                                  size: 42,
                                  borderRadius: 12,
                                  fontSize: 16,
                                ),

                                const SizedBox(width: 12),

                                // Name & course
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              isCurrentUser
                                                  ? '${member['name']} (You)'
                                                  : member['name'],
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF0A1F44),
                                              ),
                                            ),
                                          ),
                                          if (isCreator) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF1A73E8),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: const Text(
                                                'Admin',
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      Text(
                                        '${member['course']} • ${member['year']}',
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 12,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Join/Leave button
            if (!_isCreator)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : widget.group.isFull && !_isMember
                      ? null
                      : _joinOrLeave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isMember
                        ? const Color(0xFFFFEBEE)
                        : const Color(0xFF1A73E8),
                    foregroundColor: _isMember
                        ? const Color(0xFFD32F2F)
                        : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: _isMember
                                ? const Color(0xFFD32F2F)
                                : Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          widget.group.isFull && !_isMember
                              ? 'Group is Full'
                              : _isMember
                              ? 'Leave Group'
                              : 'Join Group',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
