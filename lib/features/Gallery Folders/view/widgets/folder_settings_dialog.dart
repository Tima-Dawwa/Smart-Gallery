import 'package:flutter/material.dart';
import 'package:smartgallery/core/utils/themes.dart';

class FolderSettingsDialog extends StatefulWidget {
  final Map<String, dynamic> folder;
  final Function(Map<String, dynamic>) onFolderUpdated;

  const FolderSettingsDialog({
    super.key,
    required this.folder,
    required this.onFolderUpdated,
  });

  @override
  State<FolderSettingsDialog> createState() => _FolderSettingsDialogState();
}

class _FolderSettingsDialogState extends State<FolderSettingsDialog> {
  late TextEditingController _nameController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  late bool _isLocked;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  String? _nameError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.folder['name']);
    _passwordController = TextEditingController(
      text: widget.folder['password'] ?? '',
    );
    _confirmPasswordController = TextEditingController(
      text: widget.folder['password'] ?? '',
    );
    _isLocked = widget.folder['isLocked'] ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateAndSave() {
    setState(() {
      _nameError = null;
      _passwordError = null;
    });

    // Validate folder name
    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _nameError = 'Folder name cannot be empty';
      });
      return;
    }

    // Validate password if folder is locked
    if (_isLocked) {
      if (_passwordController.text.isEmpty) {
        setState(() {
          _passwordError = 'Password cannot be empty for locked folders';
        });
        return;
      }

      if (_passwordController.text != _confirmPasswordController.text) {
        setState(() {
          _passwordError = 'Passwords do not match';
        });
        return;
      }

      if (_passwordController.text.length < 4) {
        setState(() {
          _passwordError = 'Password must be at least 4 characters';
        });
        return;
      }
    }

    // Create updated folder
    final updatedFolder = Map<String, dynamic>.from(widget.folder);
    updatedFolder['name'] = _nameController.text.trim();
    updatedFolder['isLocked'] = _isLocked;
    updatedFolder['password'] = _isLocked ? _passwordController.text : null;

    widget.onFolderUpdated(updatedFolder);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: Themes.primary, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Folder Settings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Themes.primary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, color: Themes.dark),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Folder Name Field
            Text(
              'Folder Name',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Themes.primary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Enter folder name',
                errorText: _nameError,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Themes.accent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Themes.primary, width: 2),
                ),
                prefixIcon: Icon(Icons.folder, color: Themes.primary),
              ),
            ),
            const SizedBox(height: 20),

            // Lock Toggle
            Row(
              children: [
                Icon(
                  _isLocked ? Icons.lock : Icons.lock_open,
                  color: _isLocked ? Themes.accent : Themes.dark,
                ),
                const SizedBox(width: 8),
                Text(
                  'Password Protection',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Themes.primary,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: _isLocked,
                  onChanged: (value) {
                    setState(() {
                      _isLocked = value;
                      if (!value) {
                        _passwordController.clear();
                        _confirmPasswordController.clear();
                        _passwordError = null;
                      }
                    });
                  },
                  activeColor: Themes.primary,
                ),
              ],
            ),

            // Password Fields (only show if locked)
            if (_isLocked) ...[
              const SizedBox(height: 16),
              Text(
                'Password',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Themes.primary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  hintText: 'Enter password',
                  errorText: _passwordError,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Themes.accent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Themes.primary, width: 2),
                  ),
                  prefixIcon: Icon(Icons.lock, color: Themes.primary),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off,
                      color: Themes.dark,
                    ),
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Confirm Password',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Themes.primary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmPasswordController,
                obscureText: !_showConfirmPassword,
                decoration: InputDecoration(
                  hintText: 'Confirm password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Themes.accent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Themes.primary, width: 2),
                  ),
                  prefixIcon: Icon(Icons.lock, color: Themes.primary),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Themes.dark,
                    ),
                    onPressed: () {
                      setState(() {
                        _showConfirmPassword = !_showConfirmPassword;
                      });
                    },
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Themes.accent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Themes.accent),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _validateAndSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Themes.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Save Changes',
                      style: TextStyle(
                        color: Themes.customWhite,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
