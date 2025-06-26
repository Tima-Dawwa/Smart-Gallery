import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'package:record/record.dart';
import 'package:smartgallery/features/Photos%20Gallery/presentation/view/widget/audio_player_controlles.dart';
import 'package:smartgallery/features/Photos%20Gallery/presentation/view/widget/recording_preview_dialog.dart';

class RecordingBottomSheet extends StatefulWidget {
  final int photoIndex;
  final String folderName;
  final double heightRatio;
  final Function(String)? onRecordingSaved;
  final Function()? onRecordingDeleted;

  const RecordingBottomSheet({
    super.key,
    required this.photoIndex,
    required this.folderName,
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

  Future<void> _checkExistingRecording() async {
    try {
      final Directory appDocumentsDir =
          await getApplicationDocumentsDirectory();
      String savedPath =
          '${appDocumentsDir.path}/saved_recordings/photo_${widget.photoIndex}_recording.m4a';
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
        return;
      }

      if (widget.photoIndex == 0) {
        if (mounted) {
          setState(() {
            _recordingPath = 'assets/test.mp3';
            _hasExistingRecording = true;
          });
          await _setAudioSource('assets/test.mp3', isAsset: true);
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

  Future<void> _setAudioSource(String path, {bool isAsset = false}) async {
    try {
      await _audioPlayer.stop();
      await Future.delayed(const Duration(milliseconds: 100));

      if (isAsset) {
        await _audioPlayer.setSource(AssetSource('test.mp3'));
      } else {
        await _audioPlayer.setSource(DeviceFileSource(path));
      }
    } catch (e) {
      debugPrint('Error setting audio source: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading audio: $e')));
      }
    }
  }

  Future<void> _startRecording() async {
    try {
      bool hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission required')),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error starting recording: $e')));
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
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Recording too short or empty')),
              );
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error stopping recording: $e')));
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

  Future<void> _saveRecording(String tempPath) async {
    try {
      final Directory appDocumentsDir =
          await getApplicationDocumentsDirectory();
      final String savedDirPath = '${appDocumentsDir.path}/saved_recordings';
      final String savedPath =
          '$savedDirPath/photo_${widget.photoIndex}_recording.m4a';

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

      if (widget.onRecordingSaved != null) {
        widget.onRecordingSaved!(savedPath);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recording saved successfully!')),
        );
      }
    } catch (e) {
      debugPrint('Error saving recording: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving recording: $e')));
      }
    }
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
    if (_recordingPath != null && !_recordingPath!.startsWith('assets/')) {
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Recording deleted')));
        }
      } catch (e) {
        debugPrint('Error deleting recording: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * widget.heightRatio,
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHandleBar(),
          _buildTitle(),
          Expanded(
            child:
                _hasExistingRecording
                    ? _buildExistingRecording()
                    : _buildNewRecording(),
          ),
        ],
      ),
    );
  }

  Widget _buildHandleBar() {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[600],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        'Voice Recording - Photo ${widget.photoIndex + 1}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildExistingRecording() {
    return AudioPlayerControls(
      recordingPath: _recordingPath!,
      isPlaying: _isPlaying,
      playbackPosition: _playbackPosition,
      playbackDuration: _playbackDuration,
      audioPlayer: _audioPlayer,
      onDelete: _recordingPath!.startsWith('assets/') ? null : _deleteRecording,
    );
  }

  Widget _buildNewRecording() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'No recording found for this photo',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
        const SizedBox(height: 30),
        if (_isRecording) _buildRecordingDuration(),
        _buildRecordingButton(),
        const SizedBox(height: 20),
        _buildRecordingInstructions(),
      ],
    );
  }

  Widget _buildRecordingDuration() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Text(
        _formatDuration(_recordingDuration),
        style: const TextStyle(
          color: Colors.red,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildRecordingButton() {
    return GestureDetector(
      onTap: _isRecording ? _stopRecording : _startRecording,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: _isRecording ? Colors.red : Colors.red.withOpacity(0.8),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: _isRecording ? 10 : 0,
            ),
          ],
        ),
        child: Icon(
          _isRecording ? Icons.stop : Icons.mic,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }

  Widget _buildRecordingInstructions() {
    return Text(
      _isRecording ? 'Recording... Tap to stop' : 'Tap to start recording',
      style: const TextStyle(color: Colors.white, fontSize: 16),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
