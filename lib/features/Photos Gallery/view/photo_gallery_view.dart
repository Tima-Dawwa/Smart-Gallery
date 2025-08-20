import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smartgallery/core/helpers/image_cropper_handler.dart';
import 'package:smartgallery/core/helpers/image_share_handler.dart';
import 'package:smartgallery/core/utils/themes.dart';
import 'package:smartgallery/features/Gallery%20Folders/model/media.dart';
import 'package:smartgallery/features/Photos%20Gallery/view/widget/photo_fallery_controll.dart';
import 'package:smartgallery/features/Photos%20Gallery/view/widget/photo_galley_widget.dart';
import 'package:smartgallery/features/Photos%20Gallery/view/widget/recording_bottom_sheet.dart';
import 'package:smartgallery/features/Photos%20Gallery/view%20model/photo_gallarey_cubit.dart';
import 'package:smartgallery/features/Photos%20Gallery/view%20model/photo_gallarey_state.dart';

class PhotoGalleryView extends StatefulWidget {
  final List<String> photoUrls;
  final int initialIndex;
  final String folderName;
  final bool showRecordingButton;
  final bool showDeleteButton;
  final bool showCropButton;
  final bool showShareButton;
  final List<Media> listmedia;
  final Function(int)? onPhotoDeleted;
  final Function(String, int)? onPhotoCropped;

  const PhotoGalleryView({
    super.key,
    required this.photoUrls,
    required this.initialIndex,
    required this.folderName,
    required this.listmedia,
    this.showRecordingButton = true,
    this.showDeleteButton = true,
    this.showCropButton = true,
    this.showShareButton = true,
    this.onPhotoDeleted,
    this.onPhotoCropped,
  });

  @override
  State<PhotoGalleryView> createState() => _PhotoGalleryViewState();
}

class _PhotoGalleryViewState extends State<PhotoGalleryView> {
  late PageController _pageController;
  int _currentIndex = 0;
  bool _showControls = true;
  bool _isCropping = false;
  late List<String> _photoUrls;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _photoUrls = List<String>.from(widget.photoUrls);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleControls() {
    if (!_isCropping) {
      setState(() {
        _showControls = !_showControls;
      });
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _navigateBack() {
    Navigator.pop(context);
  }

  void _deletePhoto() {
    if (widget.onPhotoDeleted != null) {
      widget.onPhotoDeleted!(_currentIndex);
    }
  }

  void _cropImage() async {
    if (_isCropping) {
      debugPrint('Crop operation already in progress');
      return;
    }

    try {
      Media? currentMedia;
      if (_currentIndex < widget.listmedia.length) {
        currentMedia = widget.listmedia[_currentIndex];
      }

      String? imagePath;

      if (currentMedia != null &&
          currentMedia.hasImage &&
          currentMedia.imageBase64 != null) {
        imagePath = await _saveBase64ToTempFile(currentMedia.imageBase64!);
      } else if (_photoUrls.isNotEmpty && _currentIndex < _photoUrls.length) {
        imagePath = _photoUrls[_currentIndex];
      }

      if (imagePath == null) {
        _showErrorSnackBar('No valid image to crop');
        return;
      }

      setState(() {
        _isCropping = true;
      });

      debugPrint('Attempting to crop image: $imagePath');

      ImageCropHandler.showCropDialog(context, () async {
        PhotoGalleryDialogs.showLoadingDialog(context);

        try {
          final String? croppedPath = await ImageCropHandler.cropImage(
            context: context,
            imagePath: imagePath!,
            title: 'Crop ${widget.folderName} Photo',
          );

          if (mounted) {
            Navigator.of(context).pop();
          }

          if (croppedPath != null) {
            debugPrint('Crop successful: $croppedPath');

            setState(() {
              _photoUrls[_currentIndex] = croppedPath;
            });

            if (widget.onPhotoCropped != null) {
              widget.onPhotoCropped!(croppedPath, _currentIndex);
            }

            // Upload cropped image to backend
            await _uploadCroppedImageToBackend(croppedPath);

            _showSuccessSnackBar('Image cropped successfully!');
          } else {
            debugPrint('Crop was cancelled or failed');
          }
        } catch (e) {
          debugPrint('Error during cropping: $e');

          if (mounted) {
            Navigator.of(context).pop();
            _showErrorSnackBar('Failed to crop image: ${e.toString()}');
          }
        } finally {
          setState(() {
            _isCropping = false;
          });
        }
      });
    } catch (e) {
      debugPrint('Error in _cropImage method: $e');
      setState(() {
        _isCropping = false;
      });
      _showErrorSnackBar('Unexpected error occurred');
    }
  }

  Future<void> _uploadCroppedImageToBackend(String croppedImagePath) async {
    try {
      Media? currentMedia;
      if (_currentIndex < widget.listmedia.length) {
        currentMedia = widget.listmedia[_currentIndex];
      }

      if (currentMedia != null) {
        final int imageId = currentMedia.idMedia;

        debugPrint(
          'Uploading cropped image to backend - Image ID: $imageId, Path: $croppedImagePath',
        );

        // Show loading indicator for upload
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Themes.customWhite,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text('Uploading cropped image...'),
                ],
              ),
              backgroundColor: Themes.primary,
              duration: const Duration(seconds: 3),
            ),
          );
        }

        final cubit = context.read<PhotoGalleryCubit>();
        cubit.updateImage(imageId: imageId, imagePath: croppedImagePath);
      } else {
        debugPrint('No media found at current index for upload');
        _showErrorSnackBar('Cannot upload: No media information found');
      }
    } catch (e) {
      debugPrint('Error uploading cropped image: $e');
      _showErrorSnackBar('Failed to upload cropped image: ${e.toString()}');
    }
  }

  Future<String?> _saveBase64ToTempFile(String base64String) async {
    try {
      String cleanBase64 = base64String;
      if (base64String.contains(',')) {
        cleanBase64 = base64String.split(',').last;
      }

      final bytes = base64Decode(cleanBase64);
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/temp_crop_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await tempFile.writeAsBytes(bytes);

      return tempFile.path;
    } catch (e) {
      debugPrint('Error saving base64 to temp file: $e');
      return null;
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(PhotoGallerySnackBars.errorSnackBar(message));
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(PhotoGallerySnackBars.successSnackBar(message));
    }
  }

  void _shareImage() async {
    try {
      Media? currentMedia;
      if (_currentIndex < widget.listmedia.length) {
        currentMedia = widget.listmedia[_currentIndex];
      }

      String? imagePath;

      if (currentMedia != null &&
          currentMedia.hasImage &&
          currentMedia.imageBase64 != null) {
        imagePath = await _saveBase64ToTempFile(currentMedia.imageBase64!);
      } else if (_currentIndex < _photoUrls.length) {
        imagePath = _photoUrls[_currentIndex];
      }

      if (imagePath != null) {
        ImageShareHandler.shareImageWithOptions(
          context: context,
          imagePath: imagePath,
        );
      } else {
        _showErrorSnackBar('No image available to share');
      }
    } catch (e) {
      debugPrint('Error sharing image: $e');
      _showErrorSnackBar('Failed to share image');
    }
  }

  void _showRecordingBottomSheet() {
    int imageId = 0;
    if (_currentIndex < widget.listmedia.length) {
      imageId = widget.listmedia[_currentIndex].idMedia;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => RecordingBottomSheet(
            photoIndex: _currentIndex,
            folderName: widget.folderName,
            imageId: imageId,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Themes.customBlack,
      body: BlocListener<PhotoGalleryCubit, PhotoGalleryStates>(
        listener: (context, state) {
          if (state is SuccessPhotoGalleryState) {
            // Hide any loading snackbars
            ScaffoldMessenger.of(context).hideCurrentSnackBar();

            _showSuccessSnackBar(
              'Image updated successfully: ${state.message}',
            );
          } else if (state is FailurePhotoGalleryState) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();

            _showErrorSnackBar(
              'Failed to update image: ${state.failure.errMessage}',
            );
          }
        },
        child: Stack(
          children: [
            PhotoPageView(
              pageController: _pageController,
              photoUrls: _photoUrls,
              mediaList: widget.listmedia,
              onPageChanged: _onPageChanged,
              onTap: _toggleControls,
            ),
            if (_showControls && !_isCropping)
              PhotoGalleryTopControls(
                currentIndex: _currentIndex,
                totalPhotos: _photoUrls.length,
                folderName: widget.folderName,
                showShareButton: widget.showShareButton,
                showCropButton: widget.showCropButton,
                isCropping: _isCropping,
                onBackPressed: _navigateBack,
                onSharePressed: _shareImage,
                onCropPressed: _cropImage,
              ),
            if (_showControls && !_isCropping)
              PhotoGalleryBottomControls(
                showDeleteButton: widget.showDeleteButton,
                showRecordingButton: widget.showRecordingButton,
                onDeletePressed: _deletePhoto,
                onRecordingPressed: _showRecordingBottomSheet,
              ),
            if (_isCropping) const CroppingOverlay(),
          ],
        ),
      ),
    );
  }
}
