import 'package:flutter/material.dart';
import 'package:smartgallery/core/utils/constants.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:smartgallery/core/utils/themes.dart';
import 'package:smartgallery/features/Gallery%20Folders/model/media.dart';
import 'package:smartgallery/features/Photos%20Gallery/view/photo_gallery_view.dart';

class PhotoGrid extends StatefulWidget {
  final List<String> photoUrls;
  final String folderName;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double borderRadius;
  final int folderid;
  final List<Media> mediaList;
  final Function(List<String>)? onPhotoUrlsUpdated;

  const PhotoGrid({
    super.key,
    required this.photoUrls,
    required this.folderName,
    required this.folderid,
    this.crossAxisCount = 3,
    this.crossAxisSpacing = 4,
    this.mainAxisSpacing = 4,
    this.borderRadius = 8,
    this.onPhotoUrlsUpdated,
    required this.mediaList,
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

    if (widget.onPhotoUrlsUpdated != null) {
      widget.onPhotoUrlsUpdated!(_photoUrls);
    }

    debugPrint('Photo cropped and grid updated at index $index: $croppedPath');
  }

  void _handlePhotoDeleted(int index) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.folderName,
          style: TextStyle(
            color: Themes.customWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Themes.customBlack,
        foregroundColor: Themes.customWhite,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: Themes.primaryGradient),
        ),
        iconTheme: IconThemeData(color: Themes.customWhite),
      ),
      backgroundColor: Themes.customBlack,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Themes.customBlack, Themes.dark.withOpacity(0.8)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: widget.crossAxisCount,
              crossAxisSpacing: widget.crossAxisSpacing,
              mainAxisSpacing: widget.mainAxisSpacing,
            ),
            itemCount: widget.mediaList.length,
            itemBuilder: (context, index) {
              return _buildPhotoTile(context, index);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoTile(BuildContext context, int index) {
    return GestureDetector(
      onTap: () => _navigateToGalleryView(context, index),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: Themes.primaryGradient.scale(0.3),
          boxShadow: [
            BoxShadow(
              color: Themes.primary.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Stack(
            children: [
              _buildImageWidget(index),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Themes.customBlack.withOpacity(0.2),
                    ],
                  ),
                ),
              ),
              if (widget.mediaList[index].hasAudio)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Themes.accent.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.mic, color: Themes.customWhite, size: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageWidget(int index) {
    final Media media = widget.mediaList[index];

    if (media.hasImage && media.imageBase64 != null) {
      try {
        String base64String = media.imageBase64!;
        if (base64String.contains(',')) {
          base64String = base64String.split(',').last;
        }

        Uint8List imageBytes = base64Decode(base64String);

        return Image.memory(
          imageBytes,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Error loading base64 image: $error');
            return _buildErrorWidget();
          },
        );
      } catch (e) {
        debugPrint('Error decoding base64 image: $e');
        return _buildErrorWidget();
      }
    }

    if (index < _photoUrls.length) {
      final String imagePath = _photoUrls[index];

      if (imagePath.startsWith('static/')) {
        return Image.network(
          "$ngrok$imagePath",
          headers: {"ngrok-skip-browser-warning": "true"},
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorWidget();
          },
        );
      } else {
        return Image.file(
          File(imagePath),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorWidget();
          },
        );
      }
    }

    return _buildErrorWidget();
  }

  Widget _buildErrorWidget() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(gradient: Themes.primaryGradient.scale(0.3)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            color: Themes.customWhite.withOpacity(0.5),
            size: 32,
          ),
          const SizedBox(height: 4),
          Text(
            'No Image',
            style: TextStyle(
              color: Themes.customWhite.withOpacity(0.5),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToGalleryView(BuildContext context, int index) {
    List<String> photoUrlsForGallery = _createPhotoUrlsFromMedia();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => PhotoGalleryView(
              photoUrls: photoUrlsForGallery,
              initialIndex: index,
              folderName: widget.folderName,
              onPhotoCropped: _handlePhotoCropped,
              onPhotoDeleted: _handlePhotoDeleted,
              listmedia: widget.mediaList,
            ),
      ),
    );
  }

  List<String> _createPhotoUrlsFromMedia() {
    List<String> urls = [];

    for (int i = 0; i < widget.mediaList.length; i++) {
      final Media media = widget.mediaList[i];

      if (media.hasImage) {
        urls.add('base64_image_$i');
      } else if (i < _photoUrls.length) {
        urls.add(_photoUrls[i]);
      } else {
        urls.add('no_image_$i');
      }
    }

    return urls;
  }
}
