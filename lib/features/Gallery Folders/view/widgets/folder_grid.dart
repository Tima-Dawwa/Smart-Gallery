import 'package:flutter/material.dart';
import 'package:smartgallery/core/utils/themes.dart';
import 'dart:io';

class PhotoGridItem extends StatelessWidget {
  final String photoPath;
  final VoidCallback onTap;

  const PhotoGridItem({
    super.key,
    required this.photoPath,
    required this.onTap,
  });

  bool _isNetworkImage(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  bool _isAssetImage(String path) {
    return path.startsWith('assets/');
  }

  bool _isFileImage(String path) {
    return path.startsWith('/') &&
        !path.startsWith('/static/') &&
        !path.startsWith('/assets/');
  }

  // Helper method to build the image widget with proper error handling
  Widget _buildImage() {
    if (_isNetworkImage(photoPath)) {
      return Image.network(
        photoPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading network image: $error');
          return _buildErrorPlaceholder();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return Center(
            child: CircularProgressIndicator(
              value:
                  loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Themes.primary),
            ),
          );
        },
      );
    } else if (_isAssetImage(photoPath)) {
      return Image.asset(
        photoPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading asset image: $error');
          return _buildErrorPlaceholder();
        },
      );
    } else if (_isFileImage(photoPath)) {
      return Image.file(
        File(photoPath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading file image: $error');
          return _buildErrorPlaceholder();
        },
      );
    } else {
      // For any invalid or unrecognized path, try as asset first, then show error
      return Image.asset(
        photoPath.startsWith('assets/') ? photoPath : 'assets/$photoPath',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading image with path: $photoPath');
          return _buildErrorPlaceholder();
        },
      );
    }
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Themes.accent.withOpacity(0.1),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, color: Themes.accent, size: 32),
            const SizedBox(height: 4),
            Text(
              'No Image',
              style: TextStyle(
                color: Themes.accent,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _buildImage(),
        ),
      ),
    );
  }
}
