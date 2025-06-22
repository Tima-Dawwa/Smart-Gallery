import 'package:flutter/material.dart';
import 'package:smartgallery/features/auth/presentation/views/SignIn/signIn.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Gallery',
      
      home: SignInPage(),
    );
  }
}
