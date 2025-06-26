import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error playing preview: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      title: const Text(
        'Recording Preview',
        style: TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Would you like to save this recording?',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _togglePreviewPlayback,
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              Text(
                _formatDuration(widget.recordingDuration),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.audioPlayer.stop();
            widget.onDiscard();
            Navigator.of(context).pop();
          },
          child: const Text('Discard', style: TextStyle(color: Colors.red)),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave();
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('Save', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
