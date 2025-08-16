import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smartgallery/core/utils/themes.dart';
import 'package:smartgallery/features/Gallery%20Folders/view%20model/gallery_folder_cubit.dart';
import 'package:smartgallery/features/Gallery%20Folders/view%20model/gallery_folder_states.dart';

class GalleryHeader extends StatefulWidget {
  final int foldersCount;
  final VoidCallback onUpdateInterests;
  final Function(List<String>)?
  onPhotosAdded; // Changed to support multiple photos
  final int userId;

  const GalleryHeader({
    super.key,
    required this.foldersCount,
    required this.onUpdateInterests,
    this.onPhotosAdded,
    required this.userId,
  });

  @override
  State<GalleryHeader> createState() => _GalleryHeaderState();
}

class _GalleryHeaderState extends State<GalleryHeader> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _addPhotos() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final choice = await _showPhotoOptionsDialog();
      if (choice == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      List<XFile> pickedFiles = [];

      switch (choice) {
        case PhotoChoice.singleFromGallery:
          final file = await _picker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 80,
            maxWidth: 1920,
            maxHeight: 1080,
          );
          if (file != null) pickedFiles.add(file);
          break;

        case PhotoChoice.multipleFromGallery:
          pickedFiles = await _picker.pickMultiImage(
            imageQuality: 80,
            maxWidth: 1920,
            maxHeight: 1080,
          );
          break;

        case PhotoChoice.camera:
          final file = await _picker.pickImage(
            source: ImageSource.camera,
            imageQuality: 80,
            maxWidth: 1920,
            maxHeight: 1080,
          );
          if (file != null) pickedFiles.add(file);
          break;
      }

      if (pickedFiles.isNotEmpty) {
        final imagePaths = pickedFiles.map((file) => file.path).toList();

        // Upload images using the cubit
        context.read<GalleryFolderCubit>().uploadImages(
          imagePaths: imagePaths,
          userId: widget.userId.toString(),
        );

        // Notify parent widget about the added photos
        if (widget.onPhotosAdded != null) {
          widget.onPhotosAdded!(imagePaths);
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error adding photos: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<PhotoChoice?> _showPhotoOptionsDialog() async {
    return showDialog<PhotoChoice>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.add_photo_alternate, color: Themes.primary),
              const SizedBox(width: 8),
              Text(
                'Add Photos',
                style: TextStyle(
                  color: Themes.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogOption(
                icon: Icons.photo_library,
                title: 'Single Photo from Gallery',
                onTap:
                    () => Navigator.of(
                      context,
                    ).pop(PhotoChoice.singleFromGallery),
              ),
              const SizedBox(height: 8),
              _buildDialogOption(
                icon: Icons.photo_library_outlined,
                title: 'Multiple Photos from Gallery',
                onTap:
                    () => Navigator.of(
                      context,
                    ).pop(PhotoChoice.multipleFromGallery),
              ),
              const SizedBox(height: 8),
              _buildDialogOption(
                icon: Icons.camera_alt,
                title: 'Take Photo with Camera',
                onTap: () => Navigator.of(context).pop(PhotoChoice.camera),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Themes.accent)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Themes.primary.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Themes.primary, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Themes.customWhite)),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Themes.customWhite)),
        backgroundColor: Themes.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GalleryFolderCubit, GalleryFolderStates>(
      listener: (context, state) {
        if (state is LoadingUploadImagesState) {
          setState(() {
            _isLoading = true;
          });
        } else if (state is SuccessGalleryFolderState) {
          setState(() {
            _isLoading = false;
          });
          _showSuccessSnackBar(state.message);
        } else if (state is FailureGalleryFolderState) {
          setState(() {
            _isLoading = false;
          });
          _showErrorSnackBar('Error: ${state.failure.errMessage}');
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: Themes.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.folder, color: Themes.customWhite, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Gallery',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Themes.primary,
                    ),
                  ),
                  Text(
                    '${widget.foldersCount} folders available',
                    style: TextStyle(
                      fontSize: 14,
                      color: Themes.dark.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: Themes.accentGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: widget.onUpdateInterests,
                    icon: Icon(
                      Icons.favorite,
                      size: 18,
                      color: Themes.customWhite,
                    ),
                    label: Text(
                      'Interests',
                      style: TextStyle(color: Themes.customWhite),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    gradient: Themes.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      _isLoading
                          ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Themes.customWhite,
                                ),
                              ),
                            ),
                          )
                          : ElevatedButton.icon(
                            onPressed: _addPhotos, // Updated method name
                            icon: Icon(
                              Icons.add_photo_alternate,
                              size: 16,
                              color: Themes.customWhite,
                            ),
                            label: Text(
                              'Add Photos', // Updated label
                              style: TextStyle(color: Themes.customWhite),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                          ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum PhotoChoice { singleFromGallery, multipleFromGallery, camera }
