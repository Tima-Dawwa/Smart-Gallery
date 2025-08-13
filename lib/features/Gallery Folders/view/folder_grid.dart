import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:smartgallery/core/utils/themes.dart';

class FolderPhotosPage extends StatefulWidget {
  final Map<String, dynamic> folder;

  const FolderPhotosPage({super.key, required this.folder});

  @override
  State<FolderPhotosPage> createState() => _FolderPhotosPageState();
}

class _FolderPhotosPageState extends State<FolderPhotosPage> {
  final ImagePicker _picker = ImagePicker();
  List<String> _photos = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize with existing photos (placeholder paths)
    _photos = List.generate(
      widget.folder['photoCount'],
      (index) => 'assets/images/photo_${index + 1}.jpg',
    );
  }

  Future<void> _addPhotoFromGallery() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Show options dialog
      final source = await _showImageSourceDialog();
      if (source == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80, // Compress image to 80% quality
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (pickedFile != null) {
        // Add the selected photo to the list
        setState(() {
          _photos.add(pickedFile.path);
          // Update the folder's photo count
          widget.folder['photoCount'] = _photos.length;
        });

        // TODO: Send to backend
        await _sendToBackend(pickedFile);

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Photo added successfully!',
                style: TextStyle(color: Themes.customWhite),
              ),
              backgroundColor: Themes.primary,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.only(left: 16, right: 16),
            ),
          );
        }
      }
    } catch (e) {
      // Handle errors
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
            margin: const EdgeInsets.only(left: 16, right: 16),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
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

  Future<void> _sendToBackend(XFile imageFile) async {
    // TODO: Implement backend API call
    print('Sending photo to backend: ${imageFile.path}');
    print('Photo size: ${await imageFile.length()} bytes');
    print('Folder ID: ${widget.folder['id']}');

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Example of what you might do:
    /*
    try {
      var request = http.MultipartRequest('POST', Uri.parse('your-api-endpoint'));
      request.fields['folderId'] = widget.folder['id'];
      request.files.add(await http.MultipartFile.fromPath('photo', imageFile.path));
      
      var response = await request.send();
      if (response.statusCode == 200) {
        print('Photo uploaded successfully');
      } else {
        throw Exception('Failed to upload photo');
      }
    } catch (e) {
      print('Upload error: $e');
      rethrow;
    }
    */
  }

  void _showPhoto(int index) {
    print('Show photo ${index + 1}: ${_photos[index]}');
    // TODO: Navigate to photo viewer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Themes.secondary,
      appBar: AppBar(
        backgroundColor: Themes.customWhite,
        elevation: 2,
        shadowColor: Themes.customBlack.withOpacity(0.1),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Themes.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.folder['name'],
              style: TextStyle(
                color: Themes.primary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              '${_photos.length} photos',
              style: TextStyle(
                color: Themes.dark.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          _isLoading
              ? Container(
                margin: const EdgeInsets.only(right: 16),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Themes.primary),
                    ),
                  ),
                ),
              )
              : Container(
                margin: const EdgeInsets.only(right: 8),
                child: ElevatedButton.icon(
                  onPressed: _addPhotoFromGallery,
                  icon: Icon(
                    Icons.add_photo_alternate,
                    size: 20,
                    color: Themes.customWhite,
                  ),
                  label: Text(
                    'Add',
                    style: TextStyle(color: Themes.customWhite, fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Themes.primary,
                    foregroundColor: Themes.customWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    elevation: 2,
                  ),
                ),
              ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _photos.isEmpty ? _buildEmptyState() : _buildPhotoGrid(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Themes.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.photo_library_outlined,
              size: 60,
              color: Themes.accent,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No photos yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Themes.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button in the top bar to add your first photo\nto ${widget.folder['name']}',
            style: TextStyle(fontSize: 16, color: Themes.dark.withOpacity(0.6)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: _photos.length,
      itemBuilder: (context, index) {
        return _buildPhotoGridItem(index);
      },
    );
  }

  Widget _buildPhotoGridItem(int index) {
    final photoPath = _photos[index];
    final isAssetImage = photoPath.startsWith('assets/');

    return GestureDetector(
      onTap: () => _showPhoto(index),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child:
              isAssetImage
                  ? Image.asset(
                    photoPath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Themes.accent.withOpacity(0.1),
                        child: Icon(
                          Icons.broken_image,
                          color: Themes.accent,
                          size: 32,
                        ),
                      );
                    },
                  )
                  : Image.file(
                    File(photoPath),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Themes.accent.withOpacity(0.1),
                        child: Icon(
                          Icons.broken_image,
                          color: Themes.accent,
                          size: 32,
                        ),
                      );
                    },
                  ),
        ),
      ),
    );
  }
}
