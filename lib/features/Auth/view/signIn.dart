import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartgallery/core/utils/themes.dart';
import 'package:smartgallery/features/Auth/view/widgets/app_logo.dart';
import 'package:smartgallery/features/Auth/view/widgets/auth_form.dart';
import 'package:smartgallery/features/Auth/view/widgets/auth_header.dart';
import 'package:smartgallery/features/Auth/view/widgets/auth_toggle.dart';
import 'package:smartgallery/features/Auth/view%20model/auth_cubit.dart';
import 'package:smartgallery/features/Auth/view%20model/auth_states.dart';

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

  void _handleSubmit(String name, String? age, String password) async {
    final authCubit = context.read<AuthCubit>();

    if (_isSignIn) {
      if (age == null || age.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Age is required for sign up')),
        );
        return;
      }

      try {
        final ageInt = int.parse(age);
        await authCubit.register(
          username: name,
          password: password,
          age: ageInt,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid age')),
        );
      }
    } else {
      await authCubit.login(username: name, password: password);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthCubit, AuthStates>(
        listener: (context, state) {
          if (state is SuccessAuthState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${_isSignIn ? 'Sign up' : 'Login'} successful! User ID: ${state.userId}',
                ),
                backgroundColor: Colors.green,
              ),
            );

            // TODO: Navigate to home page with user data
            // You can now pass the userId to the next screen
            // Navigator.pushReplacementNamed(
            //   context,
            //   '/home',
            //   arguments: {'userId': state.userId}
            // );

            print('User authenticated with ID: ${state.userId}');
          } else if (state is FailureAuthState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.failure.errMessage),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Container(
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
                  child: BlocBuilder<AuthCubit, AuthStates>(
                    builder: (context, state) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const AppLogo(),
                          const SizedBox(height: 32),
                          AuthHeader(isSignUp: _isSignIn),
                          const SizedBox(height: 32),
                          AuthForm(
                            isSignUp: _isSignIn,
                            onSubmit: _handleSubmit,
                          ),
                          const SizedBox(height: 24),
                          if (state is LoadingAuthState)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: CircularProgressIndicator(),
                            ),
                          AuthToggle(
                            isSignUp: _isSignIn,
                            onToggle: _toggleMode,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
