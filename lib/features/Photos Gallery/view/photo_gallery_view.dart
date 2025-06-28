import 'package:flutter/material.dart';
import 'dart:io';
import 'package:smartgallery/core/helpers/image_cropper_handler.dart';
import 'package:smartgallery/core/helpers/image_share_handler.dart';
import 'package:smartgallery/core/utils/themes.dart';
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
        _showLoadingDialog();

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

  void _showLoadingDialog() {
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

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Themes.error,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Themes.success,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
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
          _buildPhotoPageView(),
          if (_showControls && !_isCropping) _buildTopControls(),
          if (_showControls && !_isCropping) _buildBottomControls(),
          if (_isCropping) _buildCroppingOverlay(),
        ],
      ),
    );
  }

  Widget _buildCroppingOverlay() {
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

  Widget _buildPhotoPageView() {
    return GestureDetector(
      onTap: _toggleControls,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemCount: _photoUrls.length,
        itemBuilder: (context, index) {
          return InteractiveViewer(
            child: Center(child: _buildImageWidget(_photoUrls[index])),
          );
        },
      ),
    );
  }

  Widget _buildImageWidget(String imagePath) {
    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget();
        },
      );
    } else {
      return Image.file(
        File(imagePath),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget();
        },
      );
    }
  }

  Widget _buildErrorWidget() {
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

  Widget _buildTopControls() {
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
              Container(
                decoration: BoxDecoration(
                  color: Themes.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  onPressed: _navigateBack,
                  icon: Icon(Icons.arrow_back, color: Themes.customWhite),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: Themes.customGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentIndex + 1} / ${_photoUrls.length}',
                  style: TextStyle(
                    color: Themes.customWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Row(
                children: [
                  if (widget.showShareButton)
                    Container(
                      decoration: BoxDecoration(
                        color: Themes.third.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        onPressed: _shareImage,
                        icon: Icon(Icons.share, color: Themes.customWhite),
                      ),
                    ),
                  if (widget.showCropButton)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        color:
                            _isCropping
                                ? Themes.customWhite.withOpacity(0.1)
                                : Themes.accent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        onPressed: _isCropping ? null : _cropImage,
                        icon: Icon(
                          Icons.crop,
                          color:
                              _isCropping
                                  ? Themes.customWhite.withOpacity(0.3)
                                  : Themes.customWhite,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
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
              if (widget.showDeleteButton)
                Container(
                  decoration: BoxDecoration(
                    color: Themes.error.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: IconButton(
                    onPressed: _deletePhoto,
                    icon: Icon(Icons.delete, color: Themes.error, size: 28),
                  ),
                ),
              if (widget.showRecordingButton)
                GestureDetector(
                  onTap: _showRecordingBottomSheet,
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
                ),
            ],
          ),
        ),
      ),
    );
  }
}
