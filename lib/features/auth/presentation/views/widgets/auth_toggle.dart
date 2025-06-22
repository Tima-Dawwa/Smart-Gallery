import 'package:flutter/material.dart';
import 'package:smartgallery/core/utils/themes.dart';

class AuthToggle extends StatelessWidget {
  final bool isSignUp;
  final VoidCallback onToggle;

  const AuthToggle({super.key, required this.isSignUp, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isSignUp ? 'Already have an account? ' : "Don't have an account? ",
          style: TextStyle(color: Colors.grey[600]),
        ),
        GestureDetector(
          onTap: onToggle,
          child: Text(
            isSignUp ? 'Sign In' : 'Sign Up',
            style: TextStyle(
              color: Themes.third,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
