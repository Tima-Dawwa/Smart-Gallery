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
    return MaterialApp(
      title: 'Smart Gallery',
      debugShowCheckedModeBanner: false,
      home: MainGalleryPage(),
    );
  }
}
