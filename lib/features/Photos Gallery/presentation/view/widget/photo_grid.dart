import 'package:flutter/material.dart';
import 'package:smartgallery/features/Photos%20Gallery/presentation/view/photo_gallery.dart';
import 'package:smartgallery/features/Photos%20Gallery/presentation/view/widget/photo_gallery_view.dart';


class PhotoGrid extends StatelessWidget {
  final List<String> photoUrls;
  final String folderName;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double borderRadius;

  const PhotoGrid({
    super.key,
    required this.photoUrls,
    required this.folderName,
    this.crossAxisCount = 3,
    this.crossAxisSpacing = 4,
    this.mainAxisSpacing = 4,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(folderName),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing,
          ),
          itemCount: photoUrls.length,
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
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(
          photoUrls[index],
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[800],
              child: const Icon(Icons.broken_image, color: Colors.white54),
            );
          },
        ),
      ),
    );
  }

  void _navigateToGalleryView(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => PhotoGalleryView(
              photoUrls: photoUrls,
              initialIndex: index,
              folderName: folderName,
            ),
      ),
    );
  }
}
