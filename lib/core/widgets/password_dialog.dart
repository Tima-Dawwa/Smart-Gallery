import 'package:flutter/material.dart';
import 'package:smartgallery/core/utils/themes.dart';

class PasswordDialog extends StatefulWidget {
  final Map<String, dynamic> folder;
  final VoidCallback onPasswordCorrect;

  const PasswordDialog({
    super.key,
    required this.folder,
    required this.onPasswordCorrect,
  });

  @override
  State<PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<PasswordDialog> {
  final TextEditingController passwordController = TextEditingController();

  void _validatePassword() {
    if (passwordController.text == widget.folder['password']) {
      Navigator.pop(context);
      widget.onPasswordCorrect();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incorrect password'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.lock, color: Themes.primary),
          const SizedBox(width: 8),
          Text('Folder Locked', style: TextStyle(color: Themes.primary)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter password to access "${widget.folder['name']}"',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.key, color: Themes.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Themes.primary, width: 2),
              ),
              labelStyle: TextStyle(color: Themes.primary),
            ),
            onSubmitted: (_) => _validatePassword(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
        ),
        ElevatedButton(
          onPressed: _validatePassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: Themes.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Unlock'),
        ),
      ],
    );
  }
}
