import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:smartgallery/core/utils/themes.dart';

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
            gradient: Themes.customGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Themes.darkPurple.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildRecordingInfo(),
              const SizedBox(height: 12),
              _buildDebugInfo(),
              const SizedBox(height: 12),
              _buildProgressSlider(context),
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
      style: TextStyle(
        color: Themes.customWhite,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildDebugInfo() {
    return Column(
      children: [
        Text(
          'File: ${recordingPath.split('/').last}',
          style: TextStyle(
            color: Themes.customWhite.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
        Text(
          'Duration: ${_formatDuration(playbackDuration)}',
          style: TextStyle(
            color: Themes.customWhite.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
        Text(
          'Position: ${_formatDuration(playbackPosition)}',
          style: TextStyle(
            color: Themes.customWhite.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSlider(BuildContext context) {
    if (playbackDuration.inMilliseconds <= 0) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Themes.third,
            inactiveTrackColor: Themes.customWhite.withOpacity(0.3),
            thumbColor: Themes.third,
            overlayColor: Themes.third.withOpacity(0.2),
          ),
          child: Slider(
            value:
                playbackDuration.inMilliseconds > 0
                    ? (playbackPosition.inMilliseconds /
                            playbackDuration.inMilliseconds)
                        .clamp(0.0, 1.0)
                    : 0.0,
            onChanged: (value) => _seekToPosition(value),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDuration(playbackPosition),
              style: TextStyle(
                color: Themes.customWhite.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            Text(
              _formatDuration(playbackDuration),
              style: TextStyle(
                color: Themes.customWhite.withOpacity(0.7),
                fontSize: 12,
              ),
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
        Container(
          decoration: BoxDecoration(
            color: Themes.customWhite.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: IconButton(
            onPressed: _togglePlayback,
            icon: Icon(
              isPlaying ? Icons.stop : Icons.play_arrow,
              color: Themes.customWhite,
              size: 32,
            ),
          ),
        ),
        if (onDelete != null)
          Container(
            decoration: BoxDecoration(
              color: Themes.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: IconButton(
              onPressed: () => _showDeleteConfirmation(context),
              icon: Icon(Icons.delete, color: Themes.error, size: 32),
            ),
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
          backgroundColor: Themes.dark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'Delete Recording',
            style: TextStyle(color: Themes.customWhite),
          ),
          content: Text(
            'Are you sure you want to delete this recording? This action cannot be undone.',
            style: TextStyle(color: Themes.customWhite.withOpacity(0.8)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Themes.customWhite.withOpacity(0.6)),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Themes.error, Themes.error.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onDelete?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                child: Text(
                  'Delete',
                  style: TextStyle(color: Themes.customWhite),
                ),
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
