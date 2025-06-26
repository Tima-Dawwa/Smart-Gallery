import 'package:flutter/material.dart';
import 'dart:io';
import 'package:smartgallery/features/Photos%20Gallery/presentation/view/photo_gallery.dart';
import 'package:smartgallery/features/Photos%20Gallery/presentation/view/widget/photo_gallery_view.dart';

class PhotoGrid extends StatefulWidget {
  final List<String> photoUrls;
  final String folderName;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double borderRadius;
  final Function(List<String>)? onPhotoUrlsUpdated; // Callback to notify parent

  const PhotoGrid({
    super.key,
    required this.photoUrls,
    required this.folderName,
    this.crossAxisCount = 3,
    this.crossAxisSpacing = 4,
    this.mainAxisSpacing = 4,
    this.borderRadius = 8,
    this.onPhotoUrlsUpdated,
  });

  @override
  State<PhotoGrid> createState() => _PhotoGridState();
}

class _PhotoGridState extends State<PhotoGrid> {
  late List<String> _photoUrls;

  @override
  void initState() {
    super.initState();
    _photoUrls = List<String>.from(widget.photoUrls);
  }

  void _handlePhotoCropped(String croppedPath, int index) {
    setState(() {
      _photoUrls[index] = croppedPath;
    });

    // Notify parent about the updated URLs if callback is provided
    if (widget.onPhotoUrlsUpdated != null) {
      widget.onPhotoUrlsUpdated!(_photoUrls);
    }

    debugPrint('Photo cropped and grid updated at index $index: $croppedPath');
  }

  void _handlePhotoDeleted(int index) {
    setState(() {
      _photoUrls.removeAt(index);
    });

    // Notify parent about the updated URLs if callback is provided
    if (widget.onPhotoUrlsUpdated != null) {
      widget.onPhotoUrlsUpdated!(_photoUrls);
    }

    debugPrint('Photo deleted from grid at index $index');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folderName),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.crossAxisCount,
            crossAxisSpacing: widget.crossAxisSpacing,
            mainAxisSpacing: widget.mainAxisSpacing,
          ),
          itemCount: _photoUrls.length,
          itemBuilder: (context, index) {
            return _buildPhotoTile(context, index);
          },
        ),
      ),
    );
  }

  Widget _buildPhotoTile(BuildContext context, int index) {
    return GestureDetector(
      onTap: () => _navigateToGalleryView(context, index),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: _buildImageWidget(_photoUrls[index]),
      ),
    );
  }

  Widget _buildImageWidget(String imagePath) {
    // Check if it's an asset or a file path
    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[800],
            child: const Icon(Icons.broken_image, color: Colors.white54),
          );
        },
      );
    } else {
      // It's a file path (cropped image or other file)
      return Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[800],
            child: const Icon(Icons.broken_image, color: Colors.white54),
          );
        },
      );
    }
  }

  void _navigateToGalleryView(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => PhotoGalleryView(
              photoUrls: _photoUrls,
              initialIndex: index,
              folderName: widget.folderName,
              onPhotoCropped: _handlePhotoCropped,
              onPhotoDeleted: _handlePhotoDeleted,
            ),
      ),
    );
  }
}
