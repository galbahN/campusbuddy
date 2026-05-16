import 'package:campusbuddy/screens/resource/resource_detail_screen.dart';
import 'package:campusbuddy/screens/resource/upload_resource_screen.dart';
import 'package:flutter/material.dart';
import 'package:campusbuddy/models/resource_model.dart';
import 'package:campusbuddy/services/resource_service.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen>
    with SingleTickerProviderStateMixin {
  final ResourceService _resourceService = ResourceService();
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
          'Resources',
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
            Tab(text: 'All Resources'),
            Tab(text: 'My Uploads'),
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
                hintText: 'Search resources...',
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
              children: [_buildAllResources(), _buildMyResources()],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UploadResourceScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFF1A73E8),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.upload_file_rounded),
        label: const Text(
          'Upload',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildAllResources() {
    return StreamBuilder<List<ResourceModel>>(
      stream: _resourceService.getResources(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF1A73E8)),
          );
        }

        if (snapshot.hasError) {
          return _buildEmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Something went wrong',
            subtitle: 'Please try again later',
          );
        }

        final resources = snapshot.data ?? [];
        final filtered = resources
            .where(
              (r) =>
                  r.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  r.course.toLowerCase().contains(_searchQuery.toLowerCase()),
            )
            .toList();

        if (filtered.isEmpty) {
          return _buildEmptyState(
            icon: Icons.folder_outlined,
            title: 'No resources yet',
            subtitle: 'Be the first to upload a resource!',
          );
        }

        return RefreshIndicator(
          color: const Color(0xFF1A73E8),
          onRefresh: () async => setState(() {}),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              return _buildResourceCard(filtered[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildMyResources() {
    return StreamBuilder<List<ResourceModel>>(
      stream: _resourceService.getMyResources(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF1A73E8)),
          );
        }

        final resources = snapshot.data ?? [];
        final filtered = resources
            .where(
              (r) =>
                  r.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  r.course.toLowerCase().contains(_searchQuery.toLowerCase()),
            )
            .toList();

        if (filtered.isEmpty) {
          return _buildEmptyState(
            icon: Icons.upload_file_outlined,
            title: 'No uploads yet',
            subtitle: 'Share your notes with classmates!',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            return _buildResourceCard(filtered[index], showDelete: true);
          },
        );
      },
    );
  }

  Widget _buildResourceCard(ResourceModel resource, {bool showDelete = false}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResourceDetailScreen(resource: resource),
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
        child: Row(
          children: [
            // File type badge
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _getFileColor(resource.fileType).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  resource.fileTypeLabel,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _getFileColor(resource.fileType),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Resource info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resource.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0A1F44),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    resource.course,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Color(0xFF1A73E8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline_rounded,
                        size: 12,
                        color: Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          resource.uploadedByName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.data_usage_rounded,
                        size: 12,
                        color: Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        resource.readableFileSize,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Delete button
            if (showDelete)
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFD32F2F),
                  size: 20,
                ),
                onPressed: () => _deleteResource(resource),
              ),
          ],
        ),
      ),
    );
  }

  void _deleteResource(ResourceModel resource) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Resource',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Are you sure you want to delete this resource?',
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

    final result = await _resourceService.deleteResource(
      resource.id,
      resource.fileUrl,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Color _getFileColor(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return const Color(0xFFD32F2F);
      case 'doc':
      case 'docx':
        return const Color(0xFF1A73E8);
      case 'ppt':
      case 'pptx':
        return const Color(0xFFFF6D00);
      case 'xls':
      case 'xlsx':
        return const Color(0xFF2E7D32);
      case 'jpg':
      case 'jpeg':
      case 'png':
        return const Color(0xFF6A1B9A);
      default:
        return const Color(0xFF6B7280);
    }
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
