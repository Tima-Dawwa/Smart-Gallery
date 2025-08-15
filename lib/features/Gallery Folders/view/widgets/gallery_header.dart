import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smartgallery/core/utils/themes.dart';
import 'package:smartgallery/features/Gallery%20Folders/view%20model/gallery_folder_cubit.dart';
import 'package:smartgallery/features/Gallery%20Folders/view%20model/gallery_folder_states.dart';

class GalleryHeader extends StatefulWidget {
  final int foldersCount;
  final VoidCallback onUpdateInterests;
  final Function(String)? onPhotoAdded;
  final int userId;

  const GalleryHeader({
    super.key,
    required this.foldersCount,
    required this.onUpdateInterests,
    this.onPhotoAdded,
    required this.userId,
  });

  @override
  State<GalleryHeader> createState() => _GalleryHeaderState();
}

class _GalleryHeaderState extends State<GalleryHeader> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _addPhoto() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final source = await _showImageSourceDialog();
      if (source == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (pickedFile != null) {
        // Use the cubit to upload images
        context.read<GalleryFolderCubit>().uploadImages(
          imagePaths: [pickedFile.path],
          userId: widget.userId.toString(),
        );

        if (widget.onPhotoAdded != null) {
          widget.onPhotoAdded!(pickedFile.path);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error adding photo: ${e.toString()}',
              style: TextStyle(color: Themes.customWhite),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showDialog<ImageSource>(
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
                'Add Photo',
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
              ListTile(
                leading: Icon(Icons.photo_library, color: Themes.primary),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: Themes.primary),
                title: const Text('Take Photo'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: TextStyle(color: Themes.customWhite),
              ),
              backgroundColor: Themes.primary,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            ),
          );
        } else if (state is FailureGalleryFolderState) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error: ${state.failure.errMessage}',
                style: TextStyle(color: Themes.customWhite),
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
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
                    'My Folders',
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
                            onPressed: _addPhoto,
                            icon: Icon(
                              Icons.add_photo_alternate,
                              size: 16,
                              color: Themes.customWhite,
                            ),
                            label: Text(
                              'Add Photo',
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
