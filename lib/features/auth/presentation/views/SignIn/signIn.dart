import 'package:flutter/material.dart';
import 'package:smartgallery/core/utils/themes.dart';
import 'package:smartgallery/features/auth/presentation/views/widgets/app_logo.dart';
import 'package:smartgallery/features/auth/presentation/views/widgets/auth_form.dart';
import 'package:smartgallery/features/auth/presentation/views/widgets/auth_header.dart';
import 'package:smartgallery/features/auth/presentation/views/widgets/auth_toggle.dart';


class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool _isSignIn = true; 

  void _toggleMode() {
    setState(() {
      _isSignIn = !_isSignIn;
    });
  }

  void _handleSubmit(String name, String? age, String password) {
    if (_isSignIn) {
      print('Sign Up - Name: $name, Age: $age');
    } else {
      print('Login - Name: $name');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Themes.secondary,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppLogo(),
                const SizedBox(height: 32),
                AuthHeader(isSignUp: _isSignIn),
                const SizedBox(height: 32),
                AuthForm(isSignUp: _isSignIn, onSubmit: _handleSubmit),
                const SizedBox(height: 24),
                AuthToggle(isSignUp: _isSignIn, onToggle: _toggleMode),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
