import 'package:flutter/material.dart';
import 'package:smartgallery/core/helpers/image_cropper_handler.dart';
import 'package:smartgallery/core/helpers/image_share_handler.dart';
import 'package:smartgallery/core/utils/themes.dart';
import 'package:smartgallery/features/Photos%20Gallery/view/widget/photo_fallery_controll.dart';
import 'package:smartgallery/features/Photos%20Gallery/view/widget/photo_galley_widget.dart';
import 'package:smartgallery/features/Photos%20Gallery/view/widget/recording_bottom_sheet.dart';


class PhotoGalleryView extends StatefulWidget {
  final List<String> photoUrls;
  final int initialIndex;
  final String folderName;
  final bool showRecordingButton;
  final bool showDeleteButton;
  final bool showCropButton;
  final bool showShareButton;
  final Function(int)? onPhotoDeleted;
  final Function(String, int)? onPhotoCropped;

  const PhotoGalleryView({
    super.key,
    required this.photoUrls,
    required this.initialIndex,
    required this.folderName,
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
      if (_photoUrls.isEmpty || _currentIndex >= _photoUrls.length) {
        debugPrint('Invalid photo index or empty photo list');
        _showErrorSnackBar('No valid image to crop');
        return;
      }

      setState(() {
        _isCropping = true;
      });

      final String currentImagePath = _photoUrls[_currentIndex];
      debugPrint('Attempting to crop image: $currentImagePath');

      ImageCropHandler.showCropDialog(context, () async {
        PhotoGalleryDialogs.showLoadingDialog(context);

        try {
          final String? croppedPath = await ImageCropHandler.cropImage(
            context: context,
            imagePath: currentImagePath,
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

  void _shareImage() {
    final String currentImagePath = _photoUrls[_currentIndex];
    ImageShareHandler.shareImageWithOptions(
      context: context,
      imagePath: currentImagePath,
    );
  }

  void _showRecordingBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => RecordingBottomSheet(
            photoIndex: _currentIndex,
            folderName: widget.folderName,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Themes.customBlack,
      body: Stack(
        children: [
          PhotoPageView(
            pageController: _pageController,
            photoUrls: _photoUrls,
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
    );
  }
}
