import 'dart:io';
import 'package:campusbuddy/widgets/user_avatar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campusbuddy/models/group_model.dart';
import 'package:campusbuddy/services/auth_service.dart';

class GroupChatScreen extends StatefulWidget {
  final GroupModel group;

  const GroupChatScreen({super.key, required this.group});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  bool _isSending = false;
  bool _isUploading = false;
  double _uploadProgress = 0;

  CollectionReference get _messages => _firestore
      .collection('groups')
      .doc(widget.group.id)
      .collection('messages');

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final user = _authService.currentUser;
    if (user == null) return;

    setState(() => _isSending = true);
    _messageController.clear();

    try {
      final userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      final userName = userDoc.data()?['name'] ??
          user.displayName ??
          user.email?.split('@').first ??
          'Unknown';

      await _messages.add({
        'text': text,
        'sentBy': user.uid,
        'sentByName': userName,
        'senderPhotoUrl': user.photoURL ?? '',
        'sentAt': FieldValue.serverTimestamp(),
        'isFile': false,
      });

      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Failed to send message',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
            backgroundColor: const Color(0xFFD32F2F),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }

    setState(() => _isSending = false);
  }

  Future<void> _shareFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'jpg', 'png'],
    );

    if (result == null) return;

    final file = result.files.first;
    final user = _authService.currentUser;
    if (user == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0;
    });

    try {
      final userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      final userName = userDoc.data()?['name'] ??
          user.displayName ??
          user.email?.split('@').first ??
          'Unknown';

      final storageRef = _storage
          .ref()
          .child('group_files')
          .child(widget.group.id)
          .child('${DateTime.now().millisecondsSinceEpoch}_${file.name}');

      final uploadTask = storageRef.putFile(File(file.path!));

      uploadTask.snapshotEvents.listen((event) {
        setState(() {
          _uploadProgress = event.bytesTransferred / event.totalBytes;
        });
      });

      final snapshot = await uploadTask;
      final fileUrl = await snapshot.ref.getDownloadURL();

      await _messages.add({
        'text': file.name,
        'sentBy': user.uid,
        'sentByName': userName,
        'senderPhotoUrl': user.photoURL ?? '',
        'sentAt': FieldValue.serverTimestamp(),
        'isFile': true,
        'fileUrl': fileUrl,
        'fileType': file.extension ?? 'file',
        'fileName': file.name,
        'fileSize': file.size,
      });

      setState(() => _isUploading = false);
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to share file: $e',
              style: const TextStyle(fontFamily: 'Poppins'),
            ),
            backgroundColor: const Color(0xFFD32F2F),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = _authService.currentUser?.uid ?? '';

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.group.name,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0A1F44),
              ),
            ),
            Text(
              '${widget.group.memberCount} members',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0FE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.groups_rounded,
              color: Color(0xFF1A73E8),
              size: 22,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _messages
                  .orderBy('sentAt', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF1A73E8),
                    ),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
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
                          child: const Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 40,
                            color: Color(0xFF1A73E8),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No messages yet',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0A1F44),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Start the conversation! 💬',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data =
                        docs[index].data() as Map<String, dynamic>;
                    final isMe = data['sentBy'] == currentUid;
                    final isFirstFromSender = index == 0 ||
                        (docs[index - 1].data()
                                as Map<String, dynamic>)['sentBy'] !=
                            data['sentBy'];

                    return _buildMessageBubble(
                      data: data,
                      isMe: isMe,
                      showName: isFirstFromSender && !isMe,
                    );
                  },
                );
              },
            ),
          ),

          // Message input
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
                // Attachment button
                GestureDetector(
                  onTap: _isUploading ? null : _shareFile,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0FE),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: _isUploading
                        ? Padding(
                            padding: const EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                              value: _uploadProgress > 0
                                  ? _uploadProgress
                                  : null,
                              color: const Color(0xFF1A73E8),
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.attach_file_rounded,
                            color: Color(0xFF1A73E8),
                            size: 22,
                          ),
                  ),
                ),

                const SizedBox(width: 8),

                // Text field
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    maxLines: 4,
                    minLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: Color(0xFF0A1F44),
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide:
                            const BorderSide(color: Color(0xFFE8F0FE)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide:
                            const BorderSide(color: Color(0xFFE8F0FE)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(
                          color: Color(0xFF1A73E8),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),

                const SizedBox(width: 8),

                // Send button
                GestureDetector(
                  onTap: _isSending ? null : _sendMessage,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A73E8),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: _isSending
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

  Widget _buildMessageBubble({
    required Map<String, dynamic> data,
    required bool isMe,
    required bool showName,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Sender name
          if (showName)
            Padding(
              padding: const EdgeInsets.only(left: 48, bottom: 4),
              child: Text(
                data['sentByName'] ?? '',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A73E8),
                ),
              ),
            ),

          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Avatar for other users
              if (!isMe)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: UserAvatar(
                    photoUrl: data['senderPhotoUrl'],
                    name: data['sentByName'] ?? 'U',
                    size: 32,
                    borderRadius: 10,
                    fontSize: 13,
                  ),
                ),

              // Message bubble
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isMe
                        ? const Color(0xFF1A73E8)
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isMe ? 18 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: data['isFile'] == true
                      ? _buildFileBubble(data: data, isMe: isMe)
                      : Text(
                          data['text'] ?? '',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: isMe
                                ? Colors.white
                                : const Color(0xFF0A1F44),
                            height: 1.4,
                          ),
                        ),
                ),
              ),

              if (isMe) const SizedBox(width: 8),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFileBubble({
    required Map<String, dynamic> data,
    required bool isMe,
  }) {
    final fileType = (data['fileType'] ?? 'file').toLowerCase();
    final fileName = data['fileName'] ?? 'File';
    final fileSize = data['fileSize'] ?? 0;

    // Show image preview for image files
    if (['jpg', 'jpeg', 'png'].contains(fileType)) {
      return GestureDetector(
        onTap: () async {
          final uri = Uri.parse(data['fileUrl'] ?? '');
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            data['fileUrl'] ?? '',
            width: 200,
            height: 200,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return SizedBox(
                width: 200,
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                    color: isMe ? Colors.white : const Color(0xFF1A73E8),
                    strokeWidth: 2,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.broken_image_rounded,
              color: Color(0xFF6B7280),
              size: 48,
            ),
          ),
        ),
      );
    }

    // Document file card
    Color fileColor;
    IconData fileIcon;

    switch (fileType) {
      case 'pdf':
        fileColor = const Color(0xFFD32F2F);
        fileIcon = Icons.picture_as_pdf_rounded;
        break;
      case 'doc':
      case 'docx':
        fileColor = const Color(0xFF1A73E8);
        fileIcon = Icons.description_rounded;
        break;
      case 'ppt':
      case 'pptx':
        fileColor = const Color(0xFFFF6D00);
        fileIcon = Icons.slideshow_rounded;
        break;
      default:
        fileColor = const Color(0xFF6B7280);
        fileIcon = Icons.insert_drive_file_rounded;
    }

    final readableSize = fileSize < 1024 * 1024
        ? '${(fileSize / 1024).toStringAsFixed(1)} KB'
        : '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';

    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(data['fileUrl'] ?? '');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isMe
                  ? Colors.white.withValues(alpha: 0.2)
                  : fileColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              fileIcon,
              color: isMe ? Colors.white : fileColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color:
                        isMe ? Colors.white : const Color(0xFF0A1F44),
                  ),
                ),
                Text(
                  '$readableSize • Tap to open',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: isMe
                        ? Colors.white.withValues(alpha: 0.7)
                        : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}