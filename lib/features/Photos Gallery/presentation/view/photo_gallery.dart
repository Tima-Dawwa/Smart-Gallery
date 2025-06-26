// import 'package:flutter/material.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:path_provider/path_provider.dart';
// import 'dart:io';
// import 'dart:async';
// import 'package:record/record.dart';

// // Main PhotoGrid Widget
// class PhotoGrid extends StatelessWidget {
//   final List<String> photoUrls;
//   final String folderName;

//   const PhotoGrid({Key? key, required this.photoUrls, required this.folderName})
//     : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(folderName),
//         backgroundColor: Colors.black,
//         foregroundColor: Colors.white,
//       ),
//       backgroundColor: Colors.black,
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: GridView.builder(
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 3,
//             crossAxisSpacing: 4,
//             mainAxisSpacing: 4,
//           ),
//           itemCount: photoUrls.length,
//           itemBuilder: (context, index) {
//             return GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder:
//                         (context) => PhotoGalleryView(
//                           photoUrls: photoUrls,
//                           initialIndex: index,
//                           folderName: folderName,
//                         ),
//                   ),
//                 );
//               },
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(8),
//                 child: Image.asset(photoUrls[index], fit: BoxFit.cover),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// // Gallery View with Samsung-like interface
// class PhotoGalleryView extends StatefulWidget {
//   final List<String> photoUrls;
//   final int initialIndex;
//   final String folderName;

//   const PhotoGalleryView({
//     Key? key,
//     required this.photoUrls,
//     required this.initialIndex,
//     required this.folderName,
//   }) : super(key: key);

//   @override
//   State<PhotoGalleryView> createState() => _PhotoGalleryViewState();
// }

// class _PhotoGalleryViewState extends State<PhotoGalleryView> {
//   late PageController _pageController;
//   int _currentIndex = 0;
//   bool _showControls = true;

//   @override
//   void initState() {
//     super.initState();
//     _currentIndex = widget.initialIndex;
//     _pageController = PageController(initialPage: widget.initialIndex);
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   void _toggleControls() {
//     setState(() {
//       _showControls = !_showControls;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           // Photo PageView
//           GestureDetector(
//             onTap: _toggleControls,
//             child: PageView.builder(
//               controller: _pageController,
//               onPageChanged: (index) {
//                 setState(() {
//                   _currentIndex = index;
//                 });
//               },
//               itemCount: widget.photoUrls.length,
//               itemBuilder: (context, index) {
//                 return InteractiveViewer(
//                   child: Center(
//                     child: Image.asset(
//                       widget.photoUrls[index],
//                       fit: BoxFit.contain,
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),

//           // Top Controls
//           if (_showControls)
//             Positioned(
//               top: 0,
//               left: 0,
//               right: 0,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 8,
//                 ),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [Colors.black.withOpacity(0.7), Colors.transparent],
//                   ),
//                 ),
//                 child: SafeArea(
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       IconButton(
//                         onPressed: () => Navigator.pop(context),
//                         icon: const Icon(Icons.arrow_back, color: Colors.white),
//                       ),
//                       Text(
//                         '${_currentIndex + 1} / ${widget.photoUrls.length}',
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                         ),
//                       ),
//                       const SizedBox(width: 48),
//                     ],
//                   ),
//                 ),
//               ),
//             ),

//           // Bottom Controls with Recording
//           if (_showControls)
//             Positioned(
//               bottom: 0,
//               left: 0,
//               right: 0,
//               child: Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.bottomCenter,
//                     end: Alignment.topCenter,
//                     colors: [Colors.black.withOpacity(0.8), Colors.transparent],
//                   ),
//                 ),
//                 child: SafeArea(
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       IconButton(
//                         onPressed: () {
//                           // Delete functionality
//                         },
//                         icon: const Icon(
//                           Icons.delete,
//                           color: Colors.white,
//                           size: 28,
//                         ),
//                       ),
//                       // Recording Button
//                       GestureDetector(
//                         onTap: () {
//                           _showRecordingBottomSheet(context);
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.all(12),
//                           decoration: BoxDecoration(
//                             color: Colors.red.withOpacity(0.8),
//                             shape: BoxShape.circle,
//                           ),
//                           child: const Icon(
//                             Icons.mic,
//                             color: Colors.white,
//                             size: 28,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   void _showRecordingBottomSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder:
//           (context) => RecordingBottomSheet(
//             photoIndex: _currentIndex,
//             folderName: widget.folderName,
//           ),
//     );
//   }
// }

// // Recording Bottom Sheet
// class RecordingBottomSheet extends StatefulWidget {
//   final int photoIndex;
//   final String folderName;

//   const RecordingBottomSheet({
//     Key? key,
//     required this.photoIndex,
//     required this.folderName,
//   }) : super(key: key);

//   @override
//   State<RecordingBottomSheet> createState() => _RecordingBottomSheetState();
// }

// class _RecordingBottomSheetState extends State<RecordingBottomSheet> {
//   final AudioRecorder _audioRecorder = AudioRecorder();
//   final AudioPlayer _audioPlayer = AudioPlayer();

//   bool _isRecording = false;
//   bool _isPlaying = false;
//   String? _recordingPath;
//   bool _hasExistingRecording = false;
//   Duration _recordingDuration = Duration.zero;
//   Duration _playbackPosition = Duration.zero;
//   Duration _playbackDuration = Duration.zero;
//   Timer? _recordingTimer;
//   StreamSubscription? _playerSubscription;
//   StreamSubscription? _durationSubscription;
//   StreamSubscription? _positionSubscription;

//   @override
//   void initState() {
//     super.initState();
//     _initializeAudioPlayer();
//     _checkExistingRecording();
//   }

//   @override
//   void dispose() {
//     _recordingTimer?.cancel();
//     _playerSubscription?.cancel();
//     _durationSubscription?.cancel();
//     _positionSubscription?.cancel();
//     _audioRecorder.dispose();
//     _audioPlayer.dispose();
//     super.dispose();
//   }

//   void _initializeAudioPlayer() {
//     // Set audio player mode for better file playback
//     _audioPlayer.setPlayerMode(PlayerMode.mediaPlayer);

//     // Listen to player state changes
//     _playerSubscription = _audioPlayer.onPlayerStateChanged.listen((
//       PlayerState state,
//     ) {
//       if (mounted) {
//         setState(() {
//           _isPlaying = state == PlayerState.playing;
//         });
//         print('Player state changed: $state');
//       }
//     });

//     // Listen to position changes
//     _positionSubscription = _audioPlayer.onPositionChanged.listen((
//       Duration position,
//     ) {
//       if (mounted) {
//         setState(() {
//           _playbackPosition = position;
//         });
//       }
//     });

//     // Listen to duration changes
//     _durationSubscription = _audioPlayer.onDurationChanged.listen((
//       Duration duration,
//     ) {
//       if (mounted) {
//         setState(() {
//           _playbackDuration = duration;
//         });
//         print('Duration changed: $duration');
//       }
//     });

//     // Listen to playback completion
//     _audioPlayer.onPlayerComplete.listen((event) {
//       if (mounted) {
//         setState(() {
//           _isPlaying = false;
//           _playbackPosition = Duration.zero;
//         });
//         print('Playback completed');
//       }
//     });
//   }

//   Future<void> _checkExistingRecording() async {
//     try {
//       final Directory appDocumentsDir =
//           await getApplicationDocumentsDirectory();
//       String savedPath;

//       // Check for saved recording first
//       savedPath =
//           '${appDocumentsDir.path}/saved_recordings/photo_${widget.photoIndex}_recording.m4a';
//       File recordingFile = File(savedPath);

//       if (await recordingFile.exists()) {
//         print('Found existing recording at: $savedPath');
//         final fileSize = await recordingFile.length();
//         print('File size: $fileSize bytes');

//         if (fileSize > 0) {
//           if (mounted) {
//             setState(() {
//               _recordingPath = savedPath;
//               _hasExistingRecording = true;
//             });
//             await _setAudioSource(savedPath);
//           }
//         } else {
//           print('Recording file is empty, deleting...');
//           await recordingFile.delete();
//         }
//         return;
//       }

//       // For demo: Photo 0 has test.mp3, others don't have recordings
//       if (widget.photoIndex == 0) {
//         print('Loading demo recording: test.mp3');
//         if (mounted) {
//           setState(() {
//             _recordingPath = 'assets/test.mp3';
//             _hasExistingRecording = true;
//           });
//           await _setAudioSource('assets/test.mp3', isAsset: true);
//         }
//       } else {
//         if (mounted) {
//           setState(() {
//             _hasExistingRecording = false;
//             _recordingPath = null;
//           });
//         }
//       }
//     } catch (e) {
//       print('Error checking existing recording: $e');
//       if (mounted) {
//         setState(() {
//           _hasExistingRecording = false;
//           _recordingPath = null;
//         });
//       }
//     }
//   }

//   Future<void> _setAudioSource(String path, {bool isAsset = false}) async {
//     try {
//       // Stop any current playback
//       await _audioPlayer.stop();

//       // Add a small delay to ensure proper cleanup
//       await Future.delayed(const Duration(milliseconds: 100));

//       if (isAsset) {
//         await _audioPlayer.setSource(AssetSource('test.mp3'));
//       } else {
//         await _audioPlayer.setSource(DeviceFileSource(path));
//       }
//       print('Audio source set successfully for: $path');
//     } catch (e) {
//       print('Error setting audio source: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Error loading audio: $e')));
//       }
//     }
//   }

//   Future<void> _startRecording() async {
//     try {
//       // Check and request permissions
//       bool hasPermission = await _audioRecorder.hasPermission();
//       if (!hasPermission) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Microphone permission required')),
//           );
//         }
//         return;
//       }

//       final Directory appDocumentsDir =
//           await getApplicationDocumentsDirectory();
//       final String filePath =
//           '${appDocumentsDir.path}/temp_recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

//       // Stop any current playback
//       if (_isPlaying) {
//         await _audioPlayer.stop();
//       }

//       // Enhanced recording configuration
//       const config = RecordConfig(
//         encoder: AudioEncoder.aacLc,
//         bitRate: 128000,
//         sampleRate: 44100,
//         numChannels: 1, // Mono recording
//       );

//       await _audioRecorder.start(config, path: filePath);
//       print('Recording started at: $filePath');

//       setState(() {
//         _isRecording = true;
//         _recordingDuration = Duration.zero;
//       });

//       _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//         if (mounted && _isRecording) {
//           setState(() {
//             _recordingDuration = Duration(seconds: timer.tick);
//           });
//         }
//       });
//     } catch (e) {
//       print('Error starting recording: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Error starting recording: $e')));
//       }
//     }
//   }

//   Future<void> _stopRecording() async {
//     try {
//       final String? path = await _audioRecorder.stop();
//       _recordingTimer?.cancel();
//       print('Recording stopped. Path: $path');

//       if (path != null) {
//         setState(() {
//           _isRecording = false;
//         });

//         // Verify file exists and has content
//         final File recordingFile = File(path);
//         if (await recordingFile.exists()) {
//           final int fileSize = await recordingFile.length();
//           print('Recording file size: $fileSize bytes');

//           if (fileSize > 1000) {
//             // Minimum file size check (1KB)
//             _showRecordingPreview(path);
//           } else {
//             if (mounted) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Recording too short or empty')),
//               );
//             }
//           }
//         } else {
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('Recording file not found')),
//             );
//           }
//         }
//       }
//     } catch (e) {
//       print('Error stopping recording: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Error stopping recording: $e')));
//       }
//     }
//   }

//   void _showRecordingPreview(String tempPath) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (context, setDialogState) {
//             return AlertDialog(
//               backgroundColor: const Color(0xFF1E1E1E),
//               title: const Text(
//                 'Recording Preview',
//                 style: TextStyle(color: Colors.white),
//               ),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Text(
//                     'Would you like to save this recording?',
//                     style: TextStyle(color: Colors.white70),
//                   ),
//                   const SizedBox(height: 20),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       IconButton(
//                         onPressed: () async {
//                           try {
//                             if (_isPlaying) {
//                               await _audioPlayer.pause();
//                             } else {
//                               await _audioPlayer.stop();
//                               await Future.delayed(
//                                 const Duration(milliseconds: 100),
//                               );
//                               await _audioPlayer.setSource(
//                                 DeviceFileSource(tempPath),
//                               );
//                               await _audioPlayer.resume();
//                             }
//                           } catch (e) {
//                             print('Error playing preview: $e');
//                             if (mounted) {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(
//                                   content: Text('Error playing preview: $e'),
//                                 ),
//                               );
//                             }
//                           }
//                         },
//                         icon: Icon(
//                           _isPlaying ? Icons.pause : Icons.play_arrow,
//                           color: Colors.white,
//                           size: 32,
//                         ),
//                       ),
//                       Text(
//                         _formatDuration(_recordingDuration),
//                         style: const TextStyle(color: Colors.white),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () async {
//                     await _audioPlayer.stop();
//                     // Delete temp file
//                     try {
//                       await File(tempPath).delete();
//                     } catch (e) {
//                       print('Error deleting temp file: $e');
//                     }
//                     Navigator.of(context).pop();
//                   },
//                   child: const Text(
//                     'Discard',
//                     style: TextStyle(color: Colors.red),
//                   ),
//                 ),
//                 ElevatedButton(
//                   onPressed: () async {
//                     await _saveRecording(tempPath);
//                     Navigator.of(context).pop();
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                   ),
//                   child: const Text(
//                     'Save',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   Future<void> _playRecording() async {
//     try {
//       if (_recordingPath != null) {
//         print('Attempting to play: $_recordingPath');

//         if (_isPlaying) {
//           await _audioPlayer.pause();
//           print('Paused playback');
//         } else {
//           // Stop and reset first
//           await _audioPlayer.stop();
//           await Future.delayed(const Duration(milliseconds: 200));

//           // Set source and play
//           if (_recordingPath!.startsWith('assets/')) {
//             await _audioPlayer.setSource(AssetSource('test.mp3'));
//           } else {
//             await _audioPlayer.setSource(DeviceFileSource(_recordingPath!));
//           }

//           await _audioPlayer.resume();
//           print('Started playback');
//         }
//       }
//     } catch (e) {
//       print('Error playing recording: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Error playing recording: $e')));
//       }
//     }
//   }

//   Future<void> _stopPlaying() async {
//     try {
//       await _audioPlayer.stop();
//       setState(() {
//         _isPlaying = false;
//         _playbackPosition = Duration.zero;
//       });
//       print('Stopped playback');
//     } catch (e) {
//       print('Error stopping playback: $e');
//     }
//   }

//   Future<void> _saveRecording(String tempPath) async {
//     try {
//       final Directory appDocumentsDir =
//           await getApplicationDocumentsDirectory();
//       final String savedDirPath = '${appDocumentsDir.path}/saved_recordings';
//       final String savedPath =
//           '$savedDirPath/photo_${widget.photoIndex}_recording.m4a';

//       final Directory savedDir = Directory(savedDirPath);
//       if (!await savedDir.exists()) {
//         await savedDir.create(recursive: true);
//       }

//       final File sourceFile = File(tempPath);
//       await sourceFile.copy(savedPath);
//       await sourceFile.delete(); // Delete temp file

//       print('Recording saved to: $savedPath');

//       setState(() {
//         _recordingPath = savedPath;
//         _hasExistingRecording = true;
//       });

//       await _setAudioSource(savedPath);

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Recording saved successfully!')),
//         );
//       }
//     } catch (e) {
//       print('Error saving recording: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Error saving recording: $e')));
//       }
//     }
//   }

//   Future<void> _deleteRecording() async {
//     if (_recordingPath != null && !_recordingPath!.startsWith('assets/')) {
//       try {
//         await _audioPlayer.stop(); // Stop playback first

//         final File recordingFile = File(_recordingPath!);
//         if (await recordingFile.exists()) {
//           await recordingFile.delete();
//         }

//         setState(() {
//           _recordingPath = null;
//           _hasExistingRecording = false;
//           _playbackPosition = Duration.zero;
//           _playbackDuration = Duration.zero;
//         });

//         if (mounted) {
//           ScaffoldMessenger.of(
//             context,
//           ).showSnackBar(const SnackBar(content: Text('Recording deleted')));
//         }
//       } catch (e) {
//         print('Error deleting recording: $e');
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Error deleting recording: $e')),
//           );
//         }
//       }
//     }
//   }

//   String _formatDuration(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     final minutes = twoDigits(duration.inMinutes.remainder(60));
//     final seconds = twoDigits(duration.inSeconds.remainder(60));
//     return '$minutes:$seconds';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: MediaQuery.of(context).size.height * 0.6,
//       decoration: const BoxDecoration(
//         color: Color(0xFF1E1E1E),
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       child: Column(
//         children: [
//           // Handle bar
//           Container(
//             width: 40,
//             height: 4,
//             margin: const EdgeInsets.symmetric(vertical: 12),
//             decoration: BoxDecoration(
//               color: Colors.grey[600],
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),

//           // Title
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Text(
//               'Voice Recording - Photo ${widget.photoIndex + 1}',
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),

//           // Content
//           Expanded(
//             child:
//                 _hasExistingRecording
//                     ? _buildExistingRecording()
//                     : _buildNewRecording(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildExistingRecording() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Container(
//           margin: const EdgeInsets.all(16),
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Colors.grey[800],
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Column(
//             children: [
//               Text(
//                 _recordingPath!.startsWith('assets/')
//                     ? 'Test Recording'
//                     : 'Saved Recording',
//                 style: const TextStyle(color: Colors.white, fontSize: 16),
//               ),
//               const SizedBox(height: 12),

//               // Debug info
//               Text(
//                 'File: ${_recordingPath!.split('/').last}',
//                 style: const TextStyle(color: Colors.grey, fontSize: 12),
//               ),
//               Text(
//                 'Duration: ${_formatDuration(_playbackDuration)}',
//                 style: const TextStyle(color: Colors.grey, fontSize: 12),
//               ),
//               Text(
//                 'Position: ${_formatDuration(_playbackPosition)}',
//                 style: const TextStyle(color: Colors.grey, fontSize: 12),
//               ),

//               const SizedBox(height: 12),

//               // Playback progress bar
//               if (_playbackDuration.inMilliseconds > 0) ...[
//                 Slider(
//                   value:
//                       _playbackDuration.inMilliseconds > 0
//                           ? (_playbackPosition.inMilliseconds /
//                                   _playbackDuration.inMilliseconds)
//                               .clamp(0.0, 1.0)
//                           : 0.0,
//                   onChanged: (value) async {
//                     if (_playbackDuration.inMilliseconds > 0) {
//                       final position = Duration(
//                         milliseconds:
//                             (value * _playbackDuration.inMilliseconds).round(),
//                       );
//                       await _audioPlayer.seek(position);
//                     }
//                   },
//                   activeColor: Colors.blue,
//                   inactiveColor: Colors.grey[600],
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       _formatDuration(_playbackPosition),
//                       style: const TextStyle(color: Colors.grey, fontSize: 12),
//                     ),
//                     Text(
//                       _formatDuration(_playbackDuration),
//                       style: const TextStyle(color: Colors.grey, fontSize: 12),
//                     ),
//                   ],
//                 ),
//               ],

//               const SizedBox(height: 16),

//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   IconButton(
//                     onPressed: _isPlaying ? _stopPlaying : _playRecording,
//                     icon: Icon(
//                       _isPlaying ? Icons.stop : Icons.play_arrow,
//                       color: Colors.white,
//                       size: 32,
//                     ),
//                   ),
//                   if (!_recordingPath!.startsWith('assets/'))
//                     IconButton(
//                       onPressed: _deleteRecording,
//                       icon: const Icon(
//                         Icons.delete,
//                         color: Colors.red,
//                         size: 32,
//                       ),
//                     ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildNewRecording() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         const Text(
//           'No recording found for this photo',
//           style: TextStyle(color: Colors.white70, fontSize: 16),
//         ),
//         const SizedBox(height: 30),

//         // Recording duration display
//         if (_isRecording)
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//             child: Text(
//               _formatDuration(_recordingDuration),
//               style: const TextStyle(
//                 color: Colors.red,
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),

//         // Recording button
//         GestureDetector(
//           onTap: _isRecording ? _stopRecording : _startRecording,
//           child: Container(
//             width: 80,
//             height: 80,
//             decoration: BoxDecoration(
//               color: _isRecording ? Colors.red : Colors.red.withOpacity(0.8),
//               shape: BoxShape.circle,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.red.withOpacity(0.3),
//                   blurRadius: 20,
//                   spreadRadius: _isRecording ? 10 : 0,
//                 ),
//               ],
//             ),
//             child: Icon(
//               _isRecording ? Icons.stop : Icons.mic,
//               color: Colors.white,
//               size: 40,
//             ),
//           ),
//         ),

//         const SizedBox(height: 20),

//         Text(
//           _isRecording ? 'Recording... Tap to stop' : 'Tap to start recording',
//           style: const TextStyle(color: Colors.white, fontSize: 16),
//         ),
//       ],
//     );
//   }
// }
