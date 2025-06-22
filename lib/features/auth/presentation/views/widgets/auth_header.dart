import 'package:flutter/material.dart';
import 'package:smartgallery/core/utils/themes.dart';

class AuthHeader extends StatelessWidget {
  final bool isSignUp;

  const AuthHeader({super.key, required this.isSignUp});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          isSignUp ? 'Create Account' : 'Welcome Back',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Themes.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isSignUp ? 'Sign up to get started' : 'Sign in to continue',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
