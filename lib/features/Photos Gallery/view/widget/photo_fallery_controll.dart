import 'package:flutter/material.dart';
import 'package:smartgallery/core/utils/themes.dart';

class PhotoGalleryTopControls extends StatelessWidget {
  final int currentIndex;
  final int totalPhotos;
  final String folderName;
  final bool showShareButton;
  final bool showCropButton;
  final bool isCropping;
  final VoidCallback onBackPressed;
  final VoidCallback onSharePressed;
  final VoidCallback onCropPressed;

  const PhotoGalleryTopControls({
    super.key,
    required this.currentIndex,
    required this.totalPhotos,
    required this.folderName,
    required this.showShareButton,
    required this.showCropButton,
    required this.isCropping,
    required this.onBackPressed,
    required this.onSharePressed,
    required this.onCropPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Themes.customBlack.withOpacity(0.8), Colors.transparent],
          ),
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _BackButton(onPressed: onBackPressed),
              _PhotoCounter(
                currentIndex: currentIndex,
                totalPhotos: totalPhotos,
              ),
              _ActionButtons(
                showShareButton: showShareButton,
                showCropButton: showCropButton,
                isCropping: isCropping,
                onSharePressed: onSharePressed,
                onCropPressed: onCropPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PhotoGalleryBottomControls extends StatelessWidget {
  final bool showDeleteButton;
  final bool showRecordingButton;
  final VoidCallback onDeletePressed;
  final VoidCallback onRecordingPressed;

  const PhotoGalleryBottomControls({
    super.key,
    required this.showDeleteButton,
    required this.showRecordingButton,
    required this.onDeletePressed,
    required this.onRecordingPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Themes.customBlack.withOpacity(0.8), Colors.transparent],
          ),
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (showDeleteButton) _DeleteButton(onPressed: onDeletePressed),
              if (showRecordingButton)
                _RecordingButton(onPressed: onRecordingPressed),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _BackButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Themes.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(Icons.arrow_back, color: Themes.customWhite),
      ),
    );
  }
}

class _PhotoCounter extends StatelessWidget {
  final int currentIndex;
  final int totalPhotos;

  const _PhotoCounter({required this.currentIndex, required this.totalPhotos});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: Themes.customGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${currentIndex + 1} / $totalPhotos',
        style: TextStyle(
          color: Themes.customWhite,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final bool showShareButton;
  final bool showCropButton;
  final bool isCropping;
  final VoidCallback onSharePressed;
  final VoidCallback onCropPressed;

  const _ActionButtons({
    required this.showShareButton,
    required this.showCropButton,
    required this.isCropping,
    required this.onSharePressed,
    required this.onCropPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showShareButton) _ShareButton(onPressed: onSharePressed),
        if (showCropButton)
          _CropButton(isCropping: isCropping, onPressed: onCropPressed),
      ],
    );
  }
}

class _ShareButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _ShareButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Themes.third.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(Icons.share, color: Themes.customWhite),
      ),
    );
  }
}

class _CropButton extends StatelessWidget {
  final bool isCropping;
  final VoidCallback onPressed;

  const _CropButton({required this.isCropping, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color:
            isCropping
                ? Themes.customWhite.withOpacity(0.1)
                : Themes.accent.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        onPressed: isCropping ? null : onPressed,
        icon: Icon(
          Icons.crop,
          color:
              isCropping
                  ? Themes.customWhite.withOpacity(0.3)
                  : Themes.customWhite,
        ),
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _DeleteButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Themes.error.withOpacity(0.2),
        borderRadius: BorderRadius.circular(25),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(Icons.delete, color: Themes.error, size: 28),
      ),
    );
  }
}

class _RecordingButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _RecordingButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: Themes.accentGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Themes.accent.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(Icons.mic, color: Themes.customWhite, size: 28),
      ),
    );
  }
}
