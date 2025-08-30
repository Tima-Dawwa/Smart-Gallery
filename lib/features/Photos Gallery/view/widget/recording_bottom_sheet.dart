import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'package:record/record.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartgallery/core/utils/themes.dart';
import 'package:smartgallery/features/Photos%20Gallery/view/widget/recording_preview_dialog.dart';
import 'package:smartgallery/features/Photos%20Gallery/view%20model/photo_gallarey_cubit.dart';
import 'package:smartgallery/features/Photos%20Gallery/view%20model/photo_gallarey_state.dart';
import 'recording_bottom_sheet_content.dart';

class RecordingBottomSheet extends StatefulWidget {
  final int photoIndex;
  final String folderName;
  final double heightRatio;
  final int imageId;
  final Function(String)? onRecordingSaved;
  final Function()? onRecordingDeleted;

  const RecordingBottomSheet({
    super.key,
    required this.photoIndex,
    required this.folderName,
    required this.imageId,
    this.heightRatio = 0.6,
    this.onRecordingSaved,
    this.onRecordingDeleted,
  });

  @override
  State<RecordingBottomSheet> createState() => _RecordingBottomSheetState();
}

class _RecordingBottomSheetState extends State<RecordingBottomSheet> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isRecording = false;
  bool _isPlaying = false;
  String? _recordingPath;
  bool _hasExistingRecording = false;
  Duration _recordingDuration = Duration.zero;
  Duration _playbackPosition = Duration.zero;
  Duration _playbackDuration = Duration.zero;
  Timer? _recordingTimer;
  StreamSubscription? _playerSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;

  @override
  void initState() {
    super.initState();
    _initializeAudioPlayer();
    _checkExistingRecording();
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _playerSubscription?.cancel();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _initializeAudioPlayer() {
    _audioPlayer.setPlayerMode(PlayerMode.mediaPlayer);

    _playerSubscription = _audioPlayer.onPlayerStateChanged.listen((
      PlayerState state,
    ) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _positionSubscription = _audioPlayer.onPositionChanged.listen((
      Duration position,
    ) {
      if (mounted) {
        setState(() {
          _playbackPosition = position;
        });
      }
    });

    _durationSubscription = _audioPlayer.onDurationChanged.listen((
      Duration duration,
    ) {
      if (mounted) {
        setState(() {
          _playbackDuration = duration;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _playbackPosition = Duration.zero;
        });
      }
    });
  }

  // In recording_bottom_sheet.dart, replace the _checkExistingRecording method:

  Future<void> _checkExistingRecording() async {
    try {
      final Directory appDocumentsDir =
          await getApplicationDocumentsDirectory();
      // Use imageId instead of photoIndex to make each recording unique
      String savedPath =
          '${appDocumentsDir.path}/saved_recordings/image_${widget.imageId}_recording.m4a';
      File recordingFile = File(savedPath);

      if (await recordingFile.exists()) {
        final fileSize = await recordingFile.length();
        if (fileSize > 0) {
          if (mounted) {
            setState(() {
              _recordingPath = savedPath;
              _hasExistingRecording = true;
            });
            await _setAudioSource(savedPath);
          }
        } else {
          await recordingFile.delete();
        }
      } else {
        if (mounted) {
          setState(() {
            _hasExistingRecording = false;
            _recordingPath = null;
          });
        }
      }
    } catch (e) {
      debugPrint('Error checking existing recording: $e');
      if (mounted) {
        setState(() {
          _hasExistingRecording = false;
          _recordingPath = null;
        });
      }
    }
  }

  // Also update the _saveRecording method:
  Future<void> _saveRecording(String tempPath) async {
    try {
      final Directory appDocumentsDir =
          await getApplicationDocumentsDirectory();
      final String savedDirPath = '${appDocumentsDir.path}/saved_recordings';
      // Use imageId instead of photoIndex
      final String savedPath =
          '$savedDirPath/image_${widget.imageId}_recording.m4a';

      final Directory savedDir = Directory(savedDirPath);
      if (!await savedDir.exists()) {
        await savedDir.create(recursive: true);
      }

      final File sourceFile = File(tempPath);
      await sourceFile.copy(savedPath);
      await sourceFile.delete();

      setState(() {
        _recordingPath = savedPath;
        _hasExistingRecording = true;
      });

      await _setAudioSource(savedPath);

      _uploadAudioToBackend(savedPath);

      if (widget.onRecordingSaved != null) {
        widget.onRecordingSaved!(savedPath);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Recording saved successfully!'),
            backgroundColor: Themes.success,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving recording: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving recording: $e'),
            backgroundColor: Themes.error,
          ),
        );
      }
    }
  }

  Future<void> _setAudioSource(String path) async {
    try {
      await _audioPlayer.stop();
      await Future.delayed(const Duration(milliseconds: 100));
      await _audioPlayer.setSource(DeviceFileSource(path));
    } catch (e) {
      debugPrint('Error setting audio source: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading audio: $e'),
            backgroundColor: Themes.error,
          ),
        );
      }
    }
  }

  Future<void> _startRecording() async {
    try {
      bool hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Microphone permission required'),
              backgroundColor: Themes.warning,
            ),
          );
        }
        return;
      }

      final Directory appDocumentsDir =
          await getApplicationDocumentsDirectory();
      final String filePath =
          '${appDocumentsDir.path}/temp_recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

      if (_isPlaying) {
        await _audioPlayer.stop();
      }

      const config = RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
        numChannels: 1,
      );

      await _audioRecorder.start(config, path: filePath);

      setState(() {
        _isRecording = true;
        _recordingDuration = Duration.zero;
      });

      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted && _isRecording) {
          setState(() {
            _recordingDuration = Duration(seconds: timer.tick);
          });
        }
      });
    } catch (e) {
      debugPrint('Error starting recording: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting recording: $e'),
            backgroundColor: Themes.error,
          ),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      final String? path = await _audioRecorder.stop();
      _recordingTimer?.cancel();

      if (path != null) {
        setState(() {
          _isRecording = false;
        });

        final File recordingFile = File(path);
        if (await recordingFile.exists()) {
          final int fileSize = await recordingFile.length();

          if (fileSize > 1000) {
            _showRecordingPreview(path);
          } else {
            await recordingFile.delete();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Recording too short or empty'),
                  backgroundColor: Themes.warning,
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error stopping recording: $e'),
            backgroundColor: Themes.error,
          ),
        );
      }
    }
  }

  void _showRecordingPreview(String tempPath) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return RecordingPreviewDialog(
          tempPath: tempPath,
          recordingDuration: _recordingDuration,
          audioPlayer: _audioPlayer,
          isPlaying: _isPlaying,
          onSave: () => _saveRecording(tempPath),
          onDiscard: () => _discardRecording(tempPath),
        );
      },
    );
  }

  void _uploadAudioToBackend(String audioPath) {
    debugPrint(
      'Uploading audio to backend - Image ID: ${widget.imageId}, Audio Path: $audioPath',
    );
    final cubit = context.read<PhotoGalleryCubit>();
    cubit.updateAudio(imageId: widget.imageId, audioPath: audioPath);
  }

  Future<void> _discardRecording(String tempPath) async {
    await _audioPlayer.stop();
    try {
      await File(tempPath).delete();
    } catch (e) {
      debugPrint('Error deleting temp file: $e');
    }
  }

  Future<void> _deleteRecording() async {
    if (_recordingPath != null) {
      try {
        await _audioPlayer.stop();

        final File recordingFile = File(_recordingPath!);
        if (await recordingFile.exists()) {
          await recordingFile.delete();
        }

        setState(() {
          _recordingPath = null;
          _hasExistingRecording = false;
          _playbackPosition = Duration.zero;
          _playbackDuration = Duration.zero;
        });

        if (widget.onRecordingDeleted != null) {
          widget.onRecordingDeleted!();
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Recording deleted'),
              backgroundColor: Themes.success,
            ),
          );
        }
      } catch (e) {
        debugPrint('Error deleting recording: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PhotoGalleryCubit, PhotoGalleryStates>(
      listener: (context, state) {
        if (state is SuccessPhotoGalleryState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Audio uploaded: ${state.message}'),
              backgroundColor: Themes.success,
            ),
          );
        } else if (state is FailurePhotoGalleryState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Upload failed: ${state.failure.errMessage}'),
              backgroundColor: Themes.error,
            ),
          );
        }
      },
      child: RecordingBottomSheetContent(
        photoIndex: widget.photoIndex,
        heightRatio: widget.heightRatio,
        hasExistingRecording: _hasExistingRecording,
        recordingPath: _recordingPath,
        isRecording: _isRecording,
        isPlaying: _isPlaying,
        recordingDuration: _recordingDuration,
        playbackPosition: _playbackPosition,
        playbackDuration: _playbackDuration,
        audioPlayer: _audioPlayer,
        onStartRecording: _startRecording,
        onStopRecording: _stopRecording,
        onDeleteRecording: _deleteRecording,
      ),
    );
  }
}
