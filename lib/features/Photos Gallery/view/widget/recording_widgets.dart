import 'package:flutter/material.dart';
import 'package:smartgallery/core/utils/themes.dart';

class RecordingHandleBar extends StatelessWidget {
  const RecordingHandleBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Themes.customWhite.withOpacity(0.6),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class RecordingTitle extends StatelessWidget {
  final int photoIndex;

  const RecordingTitle({super.key, required this.photoIndex});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        'Voice Recording - Photo ${photoIndex + 1}',
        style: TextStyle(
          color: Themes.customWhite,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class NewRecordingContent extends StatelessWidget {
  final bool isRecording;
  final Duration recordingDuration;
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;

  const NewRecordingContent({
    super.key,
    required this.isRecording,
    required this.recordingDuration,
    required this.onStartRecording,
    required this.onStopRecording,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'No recording found for this photo',
          style: TextStyle(
            color: Themes.customWhite.withOpacity(0.8),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 30),
        if (isRecording) RecordingDurationDisplay(duration: recordingDuration),
        RecordingButton(
          isRecording: isRecording,
          onStartRecording: onStartRecording,
          onStopRecording: onStopRecording,
        ),
        const SizedBox(height: 20),
        RecordingInstructions(isRecording: isRecording),
      ],
    );
  }
}

class RecordingDurationDisplay extends StatelessWidget {
  final Duration duration;

  const RecordingDurationDisplay({super.key, required this.duration});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Themes.customWhite.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _formatDuration(duration),
        style: TextStyle(
          color: Themes.accent,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}

class RecordingButton extends StatelessWidget {
  final bool isRecording;
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;

  const RecordingButton({
    super.key,
    required this.isRecording,
    required this.onStartRecording,
    required this.onStopRecording,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isRecording ? onStopRecording : onStartRecording,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          gradient:
              isRecording
                  ? RadialGradient(
                    colors: [Themes.error, Themes.error.withOpacity(0.7)],
                    center: Alignment.center,
                  )
                  : RadialGradient(
                    colors: [Themes.accent, Themes.darkPurple],
                    center: Alignment.center,
                  ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color:
                  isRecording
                      ? Themes.error.withOpacity(0.4)
                      : Themes.accent.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: isRecording ? 10 : 5,
            ),
          ],
        ),
        child: Icon(
          isRecording ? Icons.stop : Icons.mic,
          color: Themes.customWhite,
          size: 40,
        ),
      ),
    );
  }
}

class RecordingInstructions extends StatelessWidget {
  final bool isRecording;

  const RecordingInstructions({super.key, required this.isRecording});

  @override
  Widget build(BuildContext context) {
    return Text(
      isRecording ? 'Recording... Tap to stop' : 'Tap to start recording',
      style: TextStyle(color: Themes.customWhite, fontSize: 16),
    );
  }
}
