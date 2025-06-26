import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerControls extends StatelessWidget {
  final String recordingPath;
  final bool isPlaying;
  final Duration playbackPosition;
  final Duration playbackDuration;
  final AudioPlayer audioPlayer;
  final VoidCallback? onDelete;

  const AudioPlayerControls({
    Key? key,
    required this.recordingPath,
    required this.isPlaying,
    required this.playbackPosition,
    required this.playbackDuration,
    required this.audioPlayer,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildRecordingInfo(),
              const SizedBox(height: 12),
              _buildDebugInfo(),
              const SizedBox(height: 12),
              _buildProgressSlider(),
              const SizedBox(height: 16),
              _buildControlButtons(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecordingInfo() {
    return Text(
      recordingPath.startsWith('assets/')
          ? 'Test Recording'
          : 'Saved Recording',
      style: const TextStyle(color: Colors.white, fontSize: 16),
    );
  }

  Widget _buildDebugInfo() {
    return Column(
      children: [
        Text(
          'File: ${recordingPath.split('/').last}',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        Text(
          'Duration: ${_formatDuration(playbackDuration)}',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        Text(
          'Position: ${_formatDuration(playbackPosition)}',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildProgressSlider() {
    if (playbackDuration.inMilliseconds <= 0) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Slider(
          value:
              playbackDuration.inMilliseconds > 0
                  ? (playbackPosition.inMilliseconds /
                          playbackDuration.inMilliseconds)
                      .clamp(0.0, 1.0)
                  : 0.0,
          onChanged: (value) => _seekToPosition(value),
          activeColor: Colors.blue,
          inactiveColor: Colors.grey[600],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDuration(playbackPosition),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            Text(
              _formatDuration(playbackDuration),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControlButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: _togglePlayback,
          icon: Icon(
            isPlaying ? Icons.stop : Icons.play_arrow,
            color: Colors.white,
            size: 32,
          ),
        ),
        if (onDelete != null)
          IconButton(
            onPressed: () => _showDeleteConfirmation(context),
            icon: const Icon(Icons.delete, color: Colors.red, size: 32),
          ),
      ],
    );
  }

  void _seekToPosition(double value) async {
    if (playbackDuration.inMilliseconds > 0) {
      final position = Duration(
        milliseconds: (value * playbackDuration.inMilliseconds).round(),
      );
      await audioPlayer.seek(position);
    }
  }

  void _togglePlayback() async {
    try {
      if (isPlaying) {
        await audioPlayer.stop();
      } else {
        await audioPlayer.stop();
        await Future.delayed(const Duration(milliseconds: 200));

        if (recordingPath.startsWith('assets/')) {
          await audioPlayer.setSource(AssetSource('test.mp3'));
        } else {
          await audioPlayer.setSource(DeviceFileSource(recordingPath));
        }

        await audioPlayer.resume();
      }
    } catch (e) {
      debugPrint('Error toggling playback: $e');
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
            'Delete Recording',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to delete this recording? This action cannot be undone.',
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
                onDelete?.call();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
