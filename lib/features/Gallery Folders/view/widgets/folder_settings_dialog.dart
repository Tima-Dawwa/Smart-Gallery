import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartgallery/core/utils/themes.dart';
import 'package:smartgallery/features/Gallery%20Folders/view%20model/gallery_folder_cubit.dart';
import 'package:smartgallery/features/Gallery%20Folders/view%20model/gallery_folder_states.dart';

class FolderSettingsDialog extends StatefulWidget {
  final Map<String, dynamic> folder;
  final Function(Map<String, dynamic>) onFolderUpdated;
  final Function(Map<String, dynamic>)? onFolderDeleted;

  const FolderSettingsDialog({
    super.key,
    required this.folder,
    required this.onFolderUpdated,
    this.onFolderDeleted,
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
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.folder['name']);
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _isLocked = widget.folder['isLocked'] ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  int? _getFolderId() {
    final folderIdValue = widget.folder['id'];

    if (folderIdValue == null) {
      return null;
    }

    int? folderId;

    if (folderIdValue is int) {
      folderId = folderIdValue;
    } else if (folderIdValue is String) {
      folderId = int.tryParse(folderIdValue);
      if (folderId == null) {
        print('Failed to parse folder ID string: "$folderIdValue"');
        return null;
      }
    } else {
      return null;
    }

    if (folderId <= 0) {
      return null;
    }

    return folderId;
  }

  void _validateAndSave() async {
    setState(() {
      _nameError = null;
      _passwordError = null;
    });

    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _nameError = 'Folder name cannot be empty';
      });
      return;
    }

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

    setState(() {
      _isProcessing = true;
    });

    final folderId = _getFolderId();

    if (folderId == null) {
      setState(() {
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Invalid folder ID. Please try refreshing the folder list.',
            style: TextStyle(color: Themes.customWhite),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      bool hasUpdates = false;

      if (_nameController.text.trim() != widget.folder['name']) {
        await context.read<GalleryFolderCubit>().updateNameFolder(
          folderId: folderId,
          newName: _nameController.text.trim(),
        );
        hasUpdates = true;
      }

      if (_isLocked && _passwordController.text.isNotEmpty) {
        await context.read<GalleryFolderCubit>().updateFolderPassword(
          folderId: folderId,
          newPassword: _passwordController.text,
        );
        hasUpdates = true;
      }

      if (!hasUpdates && _isLocked != (widget.folder['isLocked'] ?? false)) {
        hasUpdates = true;
      }

      if (hasUpdates) {
        final updatedFolder = Map<String, dynamic>.from(widget.folder);
        updatedFolder['name'] = _nameController.text.trim();
        updatedFolder['isLocked'] = _isLocked;
        if (_isLocked && _passwordController.text.isNotEmpty) {
          updatedFolder['password'] = _passwordController.text;
        } else if (!_isLocked) {
          updatedFolder['password'] = null;
        }

        widget.onFolderUpdated(updatedFolder);
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error updating folder: $e',
              style: TextStyle(color: Themes.customWhite),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _deleteFolder() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.warning, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'Delete Folder',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Text(
              'Are you sure you want to delete "${widget.folder['name']}"? This action cannot be undone and all photos in this folder will be deleted.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel', style: TextStyle(color: Themes.accent)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();

                  if (widget.onFolderDeleted != null) {
                    widget.onFolderDeleted!(widget.folder);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Delete', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GalleryFolderCubit, GalleryFolderStates>(
      listener: (context, state) {
        if (state is SuccessGalleryFolderState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: TextStyle(color: Themes.customWhite),
              ),
              backgroundColor: Themes.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        } else if (state is FailureGalleryFolderState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error: ${state.failure.errMessage}',
                style: TextStyle(color: Themes.customWhite),
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.settings, color: Themes.primary, size: 24),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Folder Settings',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Themes.primary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.close, color: Themes.dark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

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
                    enabled: !_isProcessing,
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
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Icon(
                          _isLocked ? Icons.lock : Icons.lock_open,
                          color: _isLocked ? Themes.accent : Themes.dark,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Password Protection',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Themes.primary,
                            ),
                          ),
                        ),
                        Switch(
                          value: _isLocked,
                          onChanged:
                              _isProcessing
                                  ? null
                                  : (value) {
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
                  ),

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
                      enabled: !_isProcessing,
                      decoration: InputDecoration(
                        hintText:
                            widget.folder['password'] != null
                                ? 'Enter new password (leave empty to keep current)'
                                : 'Enter password',
                        errorText: _passwordError,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Themes.accent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Themes.primary,
                            width: 2,
                          ),
                        ),
                        prefixIcon: Icon(Icons.lock, color: Themes.primary),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Themes.dark,
                          ),
                          onPressed: () {
                            setState(() {
                              _showPassword = !_showPassword;
                            });
                          },
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
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
                      enabled: !_isProcessing,
                      decoration: InputDecoration(
                        hintText: 'Confirm password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Themes.accent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Themes.primary,
                            width: 2,
                          ),
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
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isProcessing ? null : _deleteFolder,
                      icon: Icon(Icons.delete, color: Colors.red),
                      label: Text(
                        'Delete Folder',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed:
                              _isProcessing
                                  ? null
                                  : () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Themes.accent),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
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
                          onPressed: _isProcessing ? null : _validateAndSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Themes.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child:
                              _isProcessing
                                  ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Themes.customWhite,
                                      ),
                                    ),
                                  )
                                  : Text(
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

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
