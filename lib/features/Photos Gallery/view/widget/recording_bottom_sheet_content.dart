import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:smartgallery/core/utils/themes.dart';
import 'package:smartgallery/features/Photos%20Gallery/view/widget/audio_player_controlles.dart';
import 'package:smartgallery/features/Photos%20Gallery/view/widget/recording_widgets.dart';

class RecordingBottomSheetContent extends StatelessWidget {
  final int photoIndex;
  final double heightRatio;
  final bool hasExistingRecording;
  final String? recordingPath;
  final bool isRecording;
  final bool isPlaying;
  final Duration recordingDuration;
  final Duration playbackPosition;
  final Duration playbackDuration;
  final AudioPlayer audioPlayer;
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;
  final VoidCallback onDeleteRecording;

  const RecordingBottomSheetContent({
    super.key,
    required this.photoIndex,
    required this.heightRatio,
    required this.hasExistingRecording,
    this.recordingPath,
    required this.isRecording,
    required this.isPlaying,
    required this.recordingDuration,
    required this.playbackPosition,
    required this.playbackDuration,
    required this.audioPlayer,
    required this.onStartRecording,
    required this.onStopRecording,
    required this.onDeleteRecording,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * heightRatio,
      decoration: BoxDecoration(
        gradient: Themes.customGradient,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const RecordingHandleBar(),
          RecordingTitle(photoIndex: photoIndex),
          Expanded(
            child:
                hasExistingRecording
                    ? _buildExistingRecording()
                    : _buildNewRecording(),
          ),
        ],
      ),
    );
  }

  Widget _buildExistingRecording() {
    return AudioPlayerControls(
      recordingPath: recordingPath!,
      isPlaying: isPlaying,
      playbackPosition: playbackPosition,
      playbackDuration: playbackDuration,
      audioPlayer: audioPlayer,
      onDelete: recordingPath!.startsWith('assets/') ? null : onDeleteRecording,
    );
  }

  Widget _buildNewRecording() {
    return NewRecordingContent(
      isRecording: isRecording,
      recordingDuration: recordingDuration,
      onStartRecording: onStartRecording,
      onStopRecording: onStopRecording,
    );
  }
}
