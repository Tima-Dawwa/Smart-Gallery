import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartgallery/core/utils/themes.dart';
import 'package:smartgallery/core/widgets/custom_text_fiels.dart';
import 'package:smartgallery/features/Auth/view%20model/auth_cubit.dart';
import 'package:smartgallery/features/Auth/view%20model/auth_states.dart';
import 'package:smartgallery/features/My%20Intereset/view/interset_page.dart';

class AuthForm extends StatefulWidget {
  final bool isSignUp;
  final Function(String name, String? age, String password) onSubmit;

  const AuthForm({super.key, required this.isSignUp, required this.onSubmit});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AuthForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSignUp != widget.isSignUp) {
      _nameController.clear();
      _ageController.clear();
      _passwordController.clear();
      _formKey.currentState?.reset();
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && !_isLoading) {
      setState(() {
        _isLoading = true;
      });

      widget.onSubmit(
        _nameController.text,
        widget.isSignUp ? _ageController.text : null,
        _passwordController.text,
      );
    }
  }

  void _navigateToInterests(int userId) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => InterestsPage(userId: userId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthStates>(
      listener: (context, state) {
        setState(() {
          _isLoading = false;
        });

        if (state is SuccessAuthState) {
          _navigateToInterests(state.userId);
        } else if (state is FailureAuthState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.failure.errMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            CustomTextField(
              controller: _nameController,
              labelText: 'Name',
              prefixIcon: Icons.person,
              enabled: !_isLoading,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                if (value.length < 2) {
                  return 'Name must be at least 2 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            if (widget.isSignUp) ...[
              CustomTextField(
                controller: _ageController,
                labelText: 'Age',
                prefixIcon: Icons.cake,
                keyboardType: TextInputType.number,
                enabled: !_isLoading,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  int? age = int.tryParse(value);
                  if (age == null || age < 1 || age > 120) {
                    return 'Please enter a valid age (1-120)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
            ],

            CustomTextField(
              controller: _passwordController,
              labelText: 'Password',
              prefixIcon: Icons.lock,
              isPassword: true,
              enabled: !_isLoading,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                gradient: _isLoading ? null : Themes.customGradient,
                color: _isLoading ? Colors.grey.withOpacity(0.5) : null,
                borderRadius: BorderRadius.circular(12),
                boxShadow:
                    _isLoading
                        ? null
                        : [
                          BoxShadow(
                            color: Themes.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white70,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    _isLoading
                        ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Loading...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                        : Text(
                          widget.isSignUp ? 'Sign Up' : 'Sign In',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
