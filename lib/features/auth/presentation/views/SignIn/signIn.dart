import 'package:flutter/material.dart';
import 'package:smartgallery/core/utils/themes.dart';
import 'package:smartgallery/features/Auth/presentation/views/SignIn/widgets/app_logo.dart';
import 'package:smartgallery/features/Auth/presentation/views/SignIn/widgets/auth_form.dart';
import 'package:smartgallery/features/Auth/presentation/views/SignIn/widgets/auth_header.dart';
import 'package:smartgallery/features/Auth/presentation/views/SignIn/widgets/auth_toggle.dart';

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
      body: Container(
        decoration: BoxDecoration(gradient: Themes.customGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                padding: const EdgeInsets.all(32.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
        ),
      ),
    );
  }
}
