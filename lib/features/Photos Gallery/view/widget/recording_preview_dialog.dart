import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:smartgallery/core/utils/themes.dart';

class RecordingPreviewDialog extends StatefulWidget {
  final String tempPath;
  final Duration recordingDuration;
  final AudioPlayer audioPlayer;
  final bool isPlaying;
  final VoidCallback onSave;
  final VoidCallback onDiscard;

  const RecordingPreviewDialog({
    super.key,
    required this.tempPath,
    required this.recordingDuration,
    required this.audioPlayer,
    required this.isPlaying,
    required this.onSave,
    required this.onDiscard,
  });

  @override
  State<RecordingPreviewDialog> createState() => _RecordingPreviewDialogState();
}

class _RecordingPreviewDialogState extends State<RecordingPreviewDialog> {
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _isPlaying = widget.isPlaying;
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<void> _togglePreviewPlayback() async {
    try {
      if (_isPlaying) {
        await widget.audioPlayer.pause();
      } else {
        await widget.audioPlayer.stop();
        await Future.delayed(const Duration(milliseconds: 100));
        await widget.audioPlayer.setSource(DeviceFileSource(widget.tempPath));
        await widget.audioPlayer.resume();
      }
      setState(() {
        _isPlaying = !_isPlaying;
      });
    } catch (e) {
      debugPrint('Error playing preview: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error playing preview: $e'),
            backgroundColor: Themes.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Themes.dark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Themes.lightPurple.withOpacity(0.3), width: 1),
      ),
      title: Text(
        'Recording Preview',
        style: TextStyle(
          color: Themes.customWhite,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Themes.lightPurple.withOpacity(0.1),
              Themes.lightBlue.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Would you like to save this recording?',
              style: TextStyle(
                color: Themes.customWhite.withOpacity(0.8),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Themes.customWhite.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Themes.accent.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [Themes.accent, Themes.darkPurple],
                        center: Alignment.center,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Themes.accent.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: _togglePreviewPlayback,
                      icon: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Themes.customWhite,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _formatDuration(widget.recordingDuration),
                    style: TextStyle(
                      color: Themes.customWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Themes.error.withOpacity(0.3), width: 1),
          ),
          child: TextButton(
            onPressed: () {
              widget.audioPlayer.stop();
              widget.onDiscard();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Themes.error,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text(
              'Discard',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Themes.success, Themes.success.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Themes.success.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              widget.onSave();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Themes.customWhite,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text(
              'Save',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
