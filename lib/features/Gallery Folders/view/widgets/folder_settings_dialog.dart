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
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmNewPasswordController;
  late bool _isLocked;
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmNewPassword = false;
  String? _nameError;
  String? _currentPasswordError;
  String? _newPasswordError;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.folder['name']);
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmNewPasswordController = TextEditingController();
    _isLocked = widget.folder['isLocked'] ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
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
      _currentPasswordError = null;
      _newPasswordError = null;
    });

    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _nameError = 'Folder name cannot be empty';
      });
      return;
    }

    final bool wasLocked = widget.folder['isLocked'] ?? false;
    final bool hasPassword =
        widget.folder['password'] != null &&
        widget.folder['password'].toString().isNotEmpty;

    if (_isLocked && !wasLocked) {
      if (_newPasswordController.text.isEmpty) {
        setState(() {
          _newPasswordError = 'New password cannot be empty';
        });
        return;
      }

      if (_newPasswordController.text != _confirmNewPasswordController.text) {
        setState(() {
          _newPasswordError = 'Passwords do not match';
        });
        return;
      }

      if (_newPasswordController.text.length < 4) {
        setState(() {
          _newPasswordError = 'Password must be at least 4 characters';
        });
        return;
      }
    }
    else if (_isLocked && wasLocked && _newPasswordController.text.isNotEmpty) {
      if (_currentPasswordController.text.isEmpty) {
        setState(() {
          _currentPasswordError =
              'Current password is required to change password';
        });
        return;
      }

      if (_currentPasswordController.text != widget.folder['password']) {
        setState(() {
          _currentPasswordError = 'Current password is incorrect';
        });
        return;
      }

      if (_newPasswordController.text != _confirmNewPasswordController.text) {
        setState(() {
          _newPasswordError = 'New passwords do not match';
        });
        return;
      }

      if (_newPasswordController.text.length < 4) {
        setState(() {
          _newPasswordError = 'New password must be at least 4 characters';
        });
        return;
      }
    }
    else if (!_isLocked && wasLocked && hasPassword) {
      if (_currentPasswordController.text.isEmpty) {
        setState(() {
          _currentPasswordError = 'Current password is required to remove lock';
        });
        return;
      }

      if (_currentPasswordController.text != widget.folder['password']) {
        setState(() {
          _currentPasswordError = 'Current password is incorrect';
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

      if (_isLocked && _newPasswordController.text.isNotEmpty) {
        await context.read<GalleryFolderCubit>().updateFolderPassword(
          folderId: folderId,
          newPassword: _newPasswordController.text,
        );
        hasUpdates = true;
      }

      if (_isLocked != wasLocked) {
        hasUpdates = true;
      }

      if (hasUpdates) {
        final updatedFolder = Map<String, dynamic>.from(widget.folder);
        updatedFolder['name'] = _nameController.text.trim();
        updatedFolder['isLocked'] = _isLocked;

        if (_isLocked && _newPasswordController.text.isNotEmpty) {
          updatedFolder['password'] = _newPasswordController.text;
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
    final bool wasLocked = widget.folder['isLocked'] ?? false;
    final bool hasPassword =
        widget.folder['password'] != null &&
        widget.folder['password'].toString().isNotEmpty;

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
                                        _newPasswordController.clear();
                                        _confirmNewPasswordController.clear();
                                        _newPasswordError = null;
                                      }
                                    });
                                  },
                          activeColor: Themes.primary,
                        ),
                      ],
                    ),
                  ),

                  if (_isLocked || (wasLocked && !_isLocked)) ...[
                    const SizedBox(height: 16),

                    if (wasLocked && hasPassword) ...[
                      Text(
                        'Current Password',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Themes.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _currentPasswordController,
                        obscureText: !_showCurrentPassword,
                        enabled: !_isProcessing,
                        decoration: InputDecoration(
                          hintText: 'Enter current password',
                          errorText: _currentPasswordError,
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
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: Themes.primary,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showCurrentPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Themes.dark,
                            ),
                            onPressed: () {
                              setState(() {
                                _showCurrentPassword = !_showCurrentPassword;
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
                    ],

                    if (_isLocked) ...[
                      Text(
                        wasLocked
                            ? 'New Password (leave empty to keep current)'
                            : 'New Password',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Themes.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _newPasswordController,
                        obscureText: !_showNewPassword,
                        enabled: !_isProcessing,
                        decoration: InputDecoration(
                          hintText:
                              wasLocked
                                  ? 'Enter new password (optional)'
                                  : 'Enter new password',
                          errorText: _newPasswordError,
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
                              _showNewPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Themes.dark,
                            ),
                            onPressed: () {
                              setState(() {
                                _showNewPassword = !_showNewPassword;
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

                      if (_newPasswordController.text.isNotEmpty ||
                          !wasLocked) ...[
                        Text(
                          'Confirm New Password',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Themes.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _confirmNewPasswordController,
                          obscureText: !_showConfirmNewPassword,
                          enabled: !_isProcessing,
                          decoration: InputDecoration(
                            hintText: 'Confirm new password',
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
                                _showConfirmNewPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Themes.dark,
                              ),
                              onPressed: () {
                                setState(() {
                                  _showConfirmNewPassword =
                                      !_showConfirmNewPassword;
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
                    ],
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

                  // Action Buttons
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
