import 'package:flutter/material.dart';
import 'dart:io';
import 'package:smartgallery/core/helpers/image_cropper_handler.dart';
import 'package:smartgallery/core/helpers/image_share_handler.dart';
import 'package:smartgallery/features/Photos%20Gallery/presentation/view/photo_gallery.dart';
import 'package:smartgallery/features/Photos%20Gallery/presentation/view/widget/recording_bottom_sheet.dart';

class PhotoGalleryView extends StatefulWidget {
  final List<String> photoUrls;
  final int initialIndex;
  final String folderName;
  final bool showRecordingButton;
  final bool showDeleteButton;
  final bool showCropButton;
  final bool showShareButton;
  final Function(int)? onPhotoDeleted;
  final Function(String, int)? onPhotoCropped; // Updated to include index

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
  late List<String> _photoUrls; // Make it mutable

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _photoUrls = List<String>.from(widget.photoUrls); // Create mutable copy
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleControls() {
    if (!_isCropping) {
      // Don't toggle controls while cropping
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

      // Show the crop dialog first
      ImageCropHandler.showCropDialog(context, () async {
        // Show loading dialog
        _showLoadingDialog();

        try {
          final String? croppedPath = await ImageCropHandler.cropImage(
            context: context,
            imagePath: currentImagePath,
            title: 'Crop ${widget.folderName} Photo',
          );

          // Hide loading dialog
          if (mounted) {
            Navigator.of(context).pop();
          }

          if (croppedPath != null) {
            debugPrint('Crop successful: $croppedPath');

            // Update the local photo URLs list
            setState(() {
              _photoUrls[_currentIndex] = croppedPath;
            });

            // Notify parent with the cropped path and index
            if (widget.onPhotoCropped != null) {
              widget.onPhotoCropped!(croppedPath, _currentIndex);
            }

            _showSuccessSnackBar('Image cropped successfully!');
          } else {
            debugPrint('Crop was cancelled or failed');
          }
        } catch (e) {
          debugPrint('Error during cropping: $e');

          // Hide loading dialog if still showing
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
        return const AlertDialog(
          backgroundColor: Color(0xFF1E1E1E),
          content: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.blue),
                SizedBox(width: 20),
                Text(
                  'Cropping image...',
                  style: TextStyle(color: Colors.white),
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
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
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
      backgroundColor: Colors.black,
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
      color: Colors.black54,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Preparing image for cropping...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
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
    // Check if it's an asset or a file path
    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget();
        },
      );
    } else {
      // It's a file path (cropped image or other file)
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
      color: Colors.grey[800],
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image, color: Colors.white54, size: 64),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Failed to load image',
              style: TextStyle(color: Colors.white54),
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
            colors: [Colors.black.withOpacity(0.7), Colors.transparent],
          ),
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _navigateBack,
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              Text(
                '${_currentIndex + 1} / ${_photoUrls.length}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              Row(
                children: [
                  if (widget.showShareButton)
                    IconButton(
                      onPressed: _shareImage,
                      icon: const Icon(Icons.share, color: Colors.white),
                    ),
                  if (widget.showCropButton)
                    IconButton(
                      onPressed: _isCropping ? null : _cropImage,
                      icon: Icon(
                        Icons.crop,
                        color: _isCropping ? Colors.grey : Colors.white,
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
            colors: [Colors.black.withOpacity(0.8), Colors.transparent],
          ),
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (widget.showDeleteButton)
                IconButton(
                  onPressed: _deletePhoto,
                  icon: const Icon(Icons.delete, color: Colors.white, size: 28),
                ),
              if (widget.showRecordingButton)
                GestureDetector(
                  onTap: _showRecordingBottomSheet,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.mic, color: Colors.white, size: 28),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
