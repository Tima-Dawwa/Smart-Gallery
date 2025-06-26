import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:smartgallery/features/Auth/presentation/views/SignIn/signIn.dart';
import 'package:smartgallery/features/Gallery%20Folders/Presentation/view/main_gallery.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AudioPlayer _audioPlayer = AudioPlayer();

  void _playAudio() async {
    await _audioPlayer.play(AssetSource('test.mp3')); // note: no `assets/` prefix here
  }
    return MaterialApp(
      title: 'Pixort',
      debugShowCheckedModeBanner: false,
      home:MainGalleryPage(),
    );
  }
}




// Scaffold(
//       appBar: AppBar(title: Text('MP3 Audio Player')),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: _playAudio,
//           child: Text('Play MP3'),
//         ),
//       ),
//     )