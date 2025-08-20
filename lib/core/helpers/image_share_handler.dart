import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ImageShareHandler {
  static Future<void> shareImage({
    required BuildContext context,
    required String imagePath,
    String? text,
    String? subject,
  }) async {
    try {
      final bool isAsset = imagePath.startsWith('assets/');

      if (isAsset) {
        await _shareAssetImage(context, imagePath, text, subject);
      } else {
        await _shareFileImage(context, imagePath, text, subject);
      }
    } catch (e) {
      debugPrint('Error sharing image: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static Future<void> _shareAssetImage(
    BuildContext context,
    String assetPath,
    String? text,
    String? subject,
  ) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List();

      final Directory tempDir = await getTemporaryDirectory();
      final String fileName = assetPath.split('/').last;
      final File tempFile = File('${tempDir.path}/$fileName');

      await tempFile.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(tempFile.path)],
        text: text ?? 'Check out this image!',
        subject: subject,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image shared successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error sharing asset image: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing asset image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static Future<void> _shareFileImage(
    BuildContext context,
    String filePath,
    String? text,
    String? subject,
  ) async {
    try {
      final File file = File(filePath);

      if (!await file.exists()) {
        throw Exception('File not found');
      }

      await Share.shareXFiles(
        [XFile(filePath)],
        text: text ?? 'Check out this image!',
        subject: subject,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image shared successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error sharing file image: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing file image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static Future<void> shareAudio({
    required BuildContext context,
    required String audioPath,
    String? text,
    String? subject,
  }) async {
    try {
      debugPrint('Attempting to share audio from: $audioPath');

      final File audioFile = File(audioPath);

      if (!await audioFile.exists()) {
        throw Exception('Audio file not found at path: $audioPath');
      }

      final int fileSize = await audioFile.length();
      if (fileSize == 0) {
        throw Exception('Audio file is empty');
      }

      debugPrint('Audio file validated: $audioPath (Size: $fileSize bytes)');

      await Share.shareXFiles(
        [XFile(audioPath, mimeType: 'audio/m4a')],
        text: text ?? 'Check out this audio recording!',
        subject: subject,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Audio shared successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error sharing audio: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing audio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static Future<void> shareImageWithAudio({
    required BuildContext context,
    required String imagePath,
    required String audioPath,
    String? text,
    String? subject,
  }) async {
    try {
      debugPrint('Attempting to share image and audio');
      debugPrint('Image path: $imagePath');
      debugPrint('Audio path: $audioPath');

      List<XFile> filesToShare = [];

      await _prepareImageForSharing(imagePath, filesToShare);

      await _prepareAudioForSharing(audioPath, filesToShare);

      if (filesToShare.isEmpty) {
        throw Exception('No valid files to share');
      }

      debugPrint('Sharing ${filesToShare.length} files');
      for (int i = 0; i < filesToShare.length; i++) {
        debugPrint(
          'File $i: ${filesToShare[i].path} (${filesToShare[i].mimeType})',
        );
      }

      await Share.shareXFiles(
        filesToShare,
        text: text ?? 'Check out this image with audio recording!',
        subject: subject,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image and audio shared successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error sharing image with audio: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static Future<void> _prepareImageForSharing(
    String imagePath,
    List<XFile> filesToShare,
  ) async {
    final bool isAsset = imagePath.startsWith('assets/');

    if (isAsset) {
      final ByteData data = await rootBundle.load(imagePath);
      final Uint8List bytes = data.buffer.asUint8List();

      final Directory tempDir = await getTemporaryDirectory();
      final String fileName = imagePath.split('/').last;
      final File tempFile = File('${tempDir.path}/share_$fileName');

      await tempFile.writeAsBytes(bytes);
      filesToShare.add(XFile(tempFile.path, mimeType: 'image/jpeg'));
      debugPrint('Prepared asset image: ${tempFile.path}');
    } else {
      final File imageFile = File(imagePath);
      if (await imageFile.exists()) {
        final int imageSize = await imageFile.length();
        if (imageSize > 0) {
          filesToShare.add(XFile(imagePath, mimeType: 'image/jpeg'));
          debugPrint(
            'Prepared file image: $imagePath (Size: $imageSize bytes)',
          );
        } else {
          throw Exception('Image file is empty');
        }
      } else {
        throw Exception('Image file not found: $imagePath');
      }
    }
  }

  static Future<void> _prepareAudioForSharing(
    String audioPath,
    List<XFile> filesToShare,
  ) async {
    final File audioFile = File(audioPath);

    if (!await audioFile.exists()) {
      throw Exception('Audio file not found: $audioPath');
    }

    final int audioFileSize = await audioFile.length();
    if (audioFileSize == 0) {
      throw Exception('Audio file is empty');
    }

    final Directory tempDir = await getTemporaryDirectory();
    final String audioFileName =
        'recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
    final File tempAudioFile = File('${tempDir.path}/$audioFileName');

    await audioFile.copy(tempAudioFile.path);

    filesToShare.add(XFile(tempAudioFile.path, mimeType: 'audio/m4a'));
    debugPrint(
      'Prepared audio file: ${tempAudioFile.path} (Size: $audioFileSize bytes)',
    );
  }

  static Future<bool> _validateAudioFile(String? audioPath) async {
    if (audioPath == null || audioPath.isEmpty) {
      debugPrint('Audio validation: No audio path provided');
      return false;
    }

    try {
      final File audioFile = File(audioPath);

      if (!await audioFile.exists()) {
        debugPrint('Audio validation: File does not exist at $audioPath');
        return false;
      }

      final int fileSize = await audioFile.length();
      final bool isValid =
          fileSize > 1000; 

      debugPrint(
        'Audio validation: Path=$audioPath, Size=$fileSize bytes, Valid=$isValid',
      );
      return isValid;
    } catch (e) {
      debugPrint('Audio validation error: $e');
      return false;
    }
  }

  static void showShareOptionsBottomSheet({
    required BuildContext context,
    required String imagePath,
    String? audioPath,
  }) async {
    debugPrint('=== Share Options Debug ===');
    debugPrint('Image path: $imagePath');
    debugPrint('Audio path: $audioPath');

    final bool hasValidAudio = await _validateAudioFile(audioPath);
    debugPrint('Valid audio available: $hasValidAudio');

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Share Options',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                ListTile(
                  leading: const Icon(Icons.image, color: Colors.white),
                  title: const Text(
                    'Share Image Only',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Share just the image',
                    style: TextStyle(color: Colors.white70),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    shareImage(context: context, imagePath: imagePath);
                  },
                ),

                if (hasValidAudio) ...[
                  ListTile(
                    leading: const Icon(Icons.audiotrack, color: Colors.white),
                    title: const Text(
                      'Share Audio Only',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: const Text(
                      'Share just the audio recording',
                      style: TextStyle(color: Colors.white70),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      shareAudio(context: context, audioPath: audioPath!);
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.share, color: Colors.white),
                    title: const Text(
                      'Share Image & Audio',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: const Text(
                      'Share both image and audio together',
                      style: TextStyle(color: Colors.white70),
                    ),
                    onTap: () {
                      debugPrint('User selected: Share Image & Audio');
                      Navigator.pop(context);
                      shareImageWithAudio(
                        context: context,
                        imagePath: imagePath,
                        audioPath: audioPath!,
                      );
                    },
                  ),
                ] else if (audioPath != null) ...[
                  ListTile(
                    leading: Icon(Icons.audiotrack, color: Colors.grey[600]),
                    title: Text(
                      'Audio Not Available',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    subtitle: Text(
                      'No valid audio recording found',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    enabled: false,
                  ),
                ],

                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  static void showShareDialog(BuildContext context, VoidCallback onShare) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
            'Share Image',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Share this image with others?',
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
                onShare();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Share', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  static Future<void> shareImageWithOptions({
    required BuildContext context,
    required String imagePath,
  }) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Share Options',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.share, color: Colors.white),
                  title: const Text(
                    'Share Image',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Share with other apps',
                    style: TextStyle(color: Colors.white70),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    shareImage(context: context, imagePath: imagePath);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.message, color: Colors.white),
                  title: const Text(
                    'Share with Text',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Add a custom message',
                    style: TextStyle(color: Colors.white70),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showTextInputDialog(context, imagePath);
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  static void _showTextInputDialog(BuildContext context, String imagePath) {
    final TextEditingController textController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
            'Add Message',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: textController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Enter your message...',
              hintStyle: TextStyle(color: Colors.white70),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white70),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
            ),
            maxLines: 3,
            minLines: 1,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                shareImage(
                  context: context,
                  imagePath: imagePath,
                  text:
                      textController.text.trim().isEmpty
                          ? null
                          : textController.text.trim(),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Share', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
