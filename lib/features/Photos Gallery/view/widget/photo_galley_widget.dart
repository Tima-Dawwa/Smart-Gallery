import 'package:flutter/material.dart';
import 'dart:io';
import 'package:smartgallery/core/utils/themes.dart';

class PhotoPageView extends StatelessWidget {
  final PageController pageController;
  final List<String> photoUrls;
  final Function(int) onPageChanged;
  final VoidCallback onTap;

  const PhotoPageView({
    super.key,
    required this.pageController,
    required this.photoUrls,
    required this.onPageChanged,
    required this.onTap,
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
            child: Center(child: PhotoWidget(imagePath: photoUrls[index])),
          );
        },
      ),
    );
  }
}

class PhotoWidget extends StatelessWidget {
  final String imagePath;

  const PhotoWidget({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const PhotoErrorWidget();
        },
      );
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
}

class PhotoErrorWidget extends StatelessWidget {
  const PhotoErrorWidget({super.key});

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
              'Failed to load image',
              style: TextStyle(color: Themes.customWhite.withOpacity(0.5)),
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
