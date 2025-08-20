import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:smartgallery/core/utils/themes.dart';
import 'package:smartgallery/features/Gallery%20Folders/model/media.dart';

class PhotoPageView extends StatelessWidget {
  final PageController pageController;
  final List<String> photoUrls;
  final List<Media>? mediaList;
  final Function(int) onPageChanged;
  final VoidCallback onTap;

  const PhotoPageView({
    super.key,
    required this.pageController,
    required this.photoUrls,
    required this.onPageChanged,
    required this.onTap,
    this.mediaList,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: PageView.builder(
        controller: pageController,
        onPageChanged: onPageChanged,
        itemCount: photoUrls.length,
        itemBuilder: (context, index) {
          return InteractiveViewer(
            child: Center(
              child: PhotoWidget(
                imagePath: photoUrls[index],
                media:
                    mediaList != null && index < mediaList!.length
                        ? mediaList![index]
                        : null,
                index: index,
              ),
            ),
          );
        },
      ),
    );
  }
}

class PhotoWidget extends StatelessWidget {
  final String imagePath;
  final Media? media;
  final int? index;

  const PhotoWidget({
    super.key,
    required this.imagePath,
    this.media,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    if (media != null && media!.hasImage && media!.imageBase64 != null) {
      return _buildBase64Image();
    }

    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const PhotoErrorWidget();
        },
      );
    } else if (imagePath.startsWith('static/')) {
      return Image.network(
        "https://5fb3f5e0e40e.ngrok-free.app$imagePath",
        headers: {"ngrok-skip-browser-warning": "true"},
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const PhotoErrorWidget();
        },
      );
    } else if (imagePath.startsWith('base64_image_') ||
        imagePath.startsWith('no_image_')) {
      return const PhotoErrorWidget(message: 'No image data available');
    } else {
      return Image.file(
        File(imagePath),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const PhotoErrorWidget();
        },
      );
    }
  }

  Widget _buildBase64Image() {
    try {
      String base64String = media!.imageBase64!;
      if (base64String.contains(',')) {
        base64String = base64String.split(',').last;
      }

      Uint8List imageBytes = base64Decode(base64String);

      return Image.memory(
        imageBytes,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error loading base64 image at index $index: $error');
          return const PhotoErrorWidget();
        },
      );
    } catch (e) {
      debugPrint('Error decoding base64 image at index $index: $e');
      return const PhotoErrorWidget();
    }
  }
}

class PhotoErrorWidget extends StatelessWidget {
  final String? message;

  const PhotoErrorWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Themes.dark,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            color: Themes.customWhite.withOpacity(0.5),
            size: 64,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              message ?? 'Failed to load image',
              style: TextStyle(color: Themes.customWhite.withOpacity(0.5)),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class CroppingOverlay extends StatelessWidget {
  const CroppingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Themes.customBlack.withOpacity(0.8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: Themes.primaryGradient,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Themes.customWhite),
              const SizedBox(height: 16),
              Text(
                'Preparing image for cropping...',
                style: TextStyle(color: Themes.customWhite, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PhotoGalleryDialogs {
  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Themes.dark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Themes.third),
                const SizedBox(width: 20),
                Text(
                  'Cropping image...',
                  style: TextStyle(color: Themes.customWhite),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class PhotoGallerySnackBars {
  static SnackBar errorSnackBar(String message) {
    return SnackBar(
      content: Text(message),
      backgroundColor: Themes.error,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  static SnackBar successSnackBar(String message) {
    return SnackBar(
      content: Text(message),
      backgroundColor: Themes.success,
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
