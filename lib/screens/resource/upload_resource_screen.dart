import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:campusbuddy/services/resource_service.dart';

class UploadResourceScreen extends StatefulWidget {
  const UploadResourceScreen({super.key});

  @override
  State<UploadResourceScreen> createState() => _UploadResourceScreenState();
}

class _UploadResourceScreenState extends State<UploadResourceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ResourceService _resourceService = ResourceService();
  bool _isLoading = false;
  String? _selectedCourse;
  PlatformFile? _selectedFile;

  final List<String> _courses = [
    'BSc. Information Technology',
    'BSc. Computer Science',
    'BSc. Mathematics',
    'BSc. Statistics',
    'BSc. Physics',
    'BSc. Chemistry',
    'BSc. Biology',
    'BA. Economics',
    'BA. Accounting',
    'BA. Business Administration',
    'Other',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'jpg', 'png'],
    );

    if (result != null) {
      setState(() => _selectedFile = result.files.first);
    }
  }

  void _uploadResource() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCourse == null) {
        _showSnackBar('Please select a course');
        return;
      }
      if (_selectedFile == null) {
        _showSnackBar('Please select a file to upload');
        return;
      }

      setState(() => _isLoading = true);

      final file = File(_selectedFile!.path!);
      final fileType = _selectedFile!.extension ?? 'file';

      final result = await _resourceService.uploadResource(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        course: _selectedCourse!,
        file: file,
        fileName: _selectedFile!.name,
        fileType: fileType,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result['success']) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Resource uploaded successfully! 🎉',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
            backgroundColor: const Color(0xFF1A73E8),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      } else {
        _showSnackBar(result['message']);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Poppins')),
        backgroundColor: const Color(0xFFD32F2F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
          'Upload Resource',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0A1F44),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0FE),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.upload_file_rounded,
                      size: 44,
                      color: Color(0xFF1A73E8),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Title
                const Text(
                  'Resource Title',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0A1F44),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    color: Color(0xFF0A1F44),
                  ),
                  decoration: _inputDecoration(
                    'e.g. Data Structures Notes - Week 3',
                    Icons.title_rounded,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Course
                const Text(
                  'Course',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0A1F44),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCourse,
                  decoration: _inputDecoration(
                    'Select course',
                    Icons.book_outlined,
                  ),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    color: Color(0xFF0A1F44),
                    fontSize: 14,
                  ),
                  hint: const Text(
                    'Select course',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  items: _courses.map((course) {
                    return DropdownMenuItem(value: course, child: Text(course));
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedCourse = value),
                ),

                const SizedBox(height: 20),

                // Description
                const Text(
                  'Description',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0A1F44),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    color: Color(0xFF0A1F44),
                  ),
                  decoration: _inputDecoration(
                    'Brief description of this resource...',
                    Icons.description_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // File picker
                const Text(
                  'File',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0A1F44),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickFile,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _selectedFile != null
                            ? const Color(0xFF1A73E8)
                            : const Color(0xFFE8F0FE),
                        width: _selectedFile != null ? 2 : 1,
                      ),
                    ),
                    child: _selectedFile == null
                        ? const Column(
                            children: [
                              Icon(
                                Icons.cloud_upload_outlined,
                                size: 40,
                                color: Color(0xFF1A73E8),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tap to select a file',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A73E8),
                                ),
                              ),
                              Text(
                                'PDF, DOC, PPT, JPG, PNG',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F0FE),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.insert_drive_file_rounded,
                                  color: Color(0xFF1A73E8),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedFile!.name,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF0A1F44),
                                      ),
                                    ),
                                    Text(
                                      '${(_selectedFile!.size / 1024).toStringAsFixed(1)} KB',
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: Color(0xFF6B7280),
                                ),
                                onPressed: () =>
                                    setState(() => _selectedFile = null),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 40),

                // Upload button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _uploadResource,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A73E8),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Upload Resource',
                            style: TextStyle(
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
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontFamily: 'Poppins',
        color: Color(0xFF6B7280),
        fontSize: 14,
      ),
      prefixIcon: Icon(icon, color: const Color(0xFF1A73E8)),
      filled: true,
      fillColor: const Color(0xFFF8FAFF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE8F0FE)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE8F0FE)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF1A73E8), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD32F2F)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 2),
      ),
    );
  }
}
