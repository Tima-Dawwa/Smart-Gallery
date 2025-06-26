import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';

class ImageCropHandler {
  static Future<String?> cropImage({
    required BuildContext context,
    required String imagePath,
    String? title,
  }) async {
    try {
      debugPrint('Starting crop for image: $imagePath');

      // Check if it's an asset or file path
      final bool isAsset = imagePath.startsWith('assets/');
      String sourcePathForCropping;

      if (isAsset) {
        debugPrint('Processing asset image');
        sourcePathForCropping = await _copyAssetToTempFile(imagePath);
        if (sourcePathForCropping.isEmpty) {
          debugPrint('Failed to copy asset to temp file');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to prepare asset image for cropping'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return null;
        }
        debugPrint('Asset copied to: $sourcePathForCropping');
      } else {
        sourcePathForCropping = imagePath;
        final File file = File(imagePath);
        if (!await file.exists()) {
          debugPrint('File does not exist: $imagePath');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Image file not found'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return null;
        }
      }

      debugPrint('Launching image cropper with path: $sourcePathForCropping');

      // Use a more conservative configuration that's less likely to crash
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: sourcePathForCropping,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 85,
        maxWidth: 2048, // Add max dimensions to prevent memory issues
        maxHeight: 2048,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: title ?? 'Crop Image',
            toolbarColor: const Color(0xFF212121),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            backgroundColor: const Color(0xFF212121),
            activeControlsWidgetColor: const Color(0xFF2196F3),
            cropGridColor: Colors.white70,
            cropFrameColor: const Color(0xFF2196F3),
            statusBarColor: const Color(0xFF212121),
            dimmedLayerColor: Colors.black54,
            hideBottomControls: false,
            showCropGrid: true,
            // Simplified aspect ratio presets to avoid issues
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
          IOSUiSettings(
            title: title ?? 'Crop Image',
            doneButtonTitle: 'Done',
            cancelButtonTitle: 'Cancel',
            minimumAspectRatio: 0.2,
            aspectRatioLockEnabled: false,
            resetAspectRatioEnabled: true,
            rotateButtonsHidden: false,
            rotateClockwiseButtonHidden: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
        ],
      );

      debugPrint('Image cropper completed: ${croppedFile?.path}');

      // Clean up temporary file if we created one for an asset
      if (isAsset && sourcePathForCropping.isNotEmpty) {
        try {
          await File(sourcePathForCropping).delete();
          debugPrint('Temporary file deleted: $sourcePathForCropping');
        } catch (e) {
          debugPrint('Error deleting temporary file: $e');
        }
      }

      if (croppedFile != null) {
        debugPrint('Cropping successful, saving to permanent location');
        final String permanentPath = await _saveCroppedImage(
          croppedFile.path,
          isAsset,
        );

        debugPrint('Cropped image saved to: $permanentPath');

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isAsset
                    ? 'Asset image cropped and saved successfully!'
                    : 'Image cropped successfully!',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
        return permanentPath;
      } else {
        debugPrint('Cropping was cancelled or failed');
        return null;
      }
    } catch (e, stackTrace) {
      debugPrint('Error cropping image: $e');
      debugPrint('Stack trace: $stackTrace');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cropping failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return null;
    }
  }

  /// Copy asset to temporary file for cropping with better error handling
  static Future<String> _copyAssetToTempFile(String assetPath) async {
    try {
      debugPrint('Copying asset to temp file: $assetPath');

      // Load asset as bytes
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List();

      debugPrint('Asset loaded, size: ${bytes.length} bytes');

      if (bytes.isEmpty) {
        debugPrint('Asset bytes are empty');
        return '';
      }

      // Get temporary directory
      final Directory tempDir = await getTemporaryDirectory();

      // Ensure temp directory exists
      if (!await tempDir.exists()) {
        await tempDir.create(recursive: true);
      }

      final String fileName = assetPath.split('/').last;
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

      // Ensure proper file extension
      String finalFileName = fileName;
      if (!fileName.toLowerCase().endsWith('.jpg') &&
          !fileName.toLowerCase().endsWith('.jpeg') &&
          !fileName.toLowerCase().endsWith('.png')) {
        finalFileName = '$fileName.jpg';
      }

      final File tempFile = File(
        '${tempDir.path}/temp_crop_${timestamp}_$finalFileName',
      );

      debugPrint('Writing to temp file: ${tempFile.path}');

      // Write bytes to temporary file
      await tempFile.writeAsBytes(bytes, flush: true);

      // Verify file was created and has content
      if (await tempFile.exists()) {
        final int fileSize = await tempFile.length();
        debugPrint('Temp file created successfully, size: $fileSize bytes');

        if (fileSize > 0) {
          return tempFile.path;
        } else {
          debugPrint('Temp file is empty');
          return '';
        }
      } else {
        debugPrint('Temp file creation failed');
        return '';
      }
    } catch (e, stackTrace) {
      debugPrint('Error copying asset to temp file: $e');
      debugPrint('Stack trace: $stackTrace');
      return '';
    }
  }

  /// Save cropped image to permanent app directory
  static Future<String> _saveCroppedImage(
    String croppedPath,
    bool wasAsset,
  ) async {
    try {
      debugPrint('Saving cropped image from: $croppedPath');

      final Directory appDocumentsDir =
          await getApplicationDocumentsDirectory();
      final String croppedDirPath = '${appDocumentsDir.path}/cropped_images';

      // Create directory if it doesn't exist
      final Directory croppedDir = Directory(croppedDirPath);
      if (!await croppedDir.exists()) {
        await croppedDir.create(recursive: true);
        debugPrint('Created cropped images directory');
      }

      // Generate unique filename
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String extension = croppedPath.split('.').last.toLowerCase();

      // Ensure extension is valid
      final String validExtension =
          ['jpg', 'jpeg', 'png'].contains(extension) ? extension : 'jpg';

      final String fileName =
          wasAsset
              ? 'cropped_asset_${timestamp}.$validExtension'
              : 'cropped_${timestamp}.$validExtension';

      final String permanentPath = '$croppedDirPath/$fileName';

      debugPrint('Saving to permanent path: $permanentPath');

      // Copy cropped file to permanent location
      final File croppedFile = File(croppedPath);
      if (await croppedFile.exists()) {
        await croppedFile.copy(permanentPath);
        debugPrint('File copied successfully');

        // Verify the copied file
        final File savedFile = File(permanentPath);
        if (await savedFile.exists()) {
          final int fileSize = await savedFile.length();
          debugPrint('Saved file verified, size: $fileSize bytes');
        }

        // Clean up the temporary cropped file
        try {
          await croppedFile.delete();
          debugPrint('Temporary cropped file deleted');
        } catch (e) {
          debugPrint('Error deleting temporary cropped file: $e');
        }

        return permanentPath;
      } else {
        debugPrint('Cropped file does not exist at: $croppedPath');
        return croppedPath;
      }
    } catch (e, stackTrace) {
      debugPrint('Error saving cropped image: $e');
      debugPrint('Stack trace: $stackTrace');
      return croppedPath;
    }
  }

  static void showCropDialog(BuildContext context, VoidCallback onCrop) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Crop Image',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Do you want to crop this image? For asset images, a cropped copy will be created.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onCrop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Crop',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Get all cropped images from the app directory
  static Future<List<String>> getCroppedImages() async {
    try {
      final Directory appDocumentsDir =
          await getApplicationDocumentsDirectory();
      final String croppedDirPath = '${appDocumentsDir.path}/cropped_images';
      final Directory croppedDir = Directory(croppedDirPath);

      if (!await croppedDir.exists()) {
        return [];
      }

      final List<FileSystemEntity> files = await croppedDir.list().toList();
      final List<String> imagePaths =
          files
              .where((file) => file is File)
              .map((file) => file.path)
              .where((path) => _isImageFile(path))
              .toList();

      // Sort by creation time (newest first)
      imagePaths.sort((a, b) {
        try {
          final File fileA = File(a);
          final File fileB = File(b);
          return fileB.lastModifiedSync().compareTo(fileA.lastModifiedSync());
        } catch (e) {
          debugPrint('Error sorting files: $e');
          return 0;
        }
      });

      return imagePaths;
    } catch (e) {
      debugPrint('Error getting cropped images: $e');
      return [];
    }
  }

  /// Check if file is an image based on extension
  static bool _isImageFile(String path) {
    final String extension = path.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
  }

  /// Delete a cropped image
  static Future<bool> deleteCroppedImage(String imagePath) async {
    try {
      final File file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting cropped image: $e');
      return false;
    }
  }

  /// Clear all cropped images
  static Future<bool> clearAllCroppedImages() async {
    try {
      final Directory appDocumentsDir =
          await getApplicationDocumentsDirectory();
      final String croppedDirPath = '${appDocumentsDir.path}/cropped_images';
      final Directory croppedDir = Directory(croppedDirPath);

      if (await croppedDir.exists()) {
        await croppedDir.delete(recursive: true);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error clearing cropped images: $e');
      return false;
    }
  }
}
