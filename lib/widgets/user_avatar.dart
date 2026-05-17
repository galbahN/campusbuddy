import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String? photoUrl;
  final String name;
  final double size;
  final double borderRadius;
  final double fontSize;

  const UserAvatar({
    super.key,
    this.photoUrl,
    required this.name,
    this.size = 40,
    this.borderRadius = 12,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF1A73E8),
        borderRadius: BorderRadius.circular(borderRadius),
        image: hasPhoto
            ? DecorationImage(
                image: NetworkImage(photoUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: hasPhoto
          ? null
          : Center(
              child: Text(
                name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'U',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
    );
  }
}