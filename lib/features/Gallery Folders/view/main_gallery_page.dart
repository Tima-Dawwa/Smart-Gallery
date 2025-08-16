import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartgallery/core/utils/themes.dart';
import 'package:smartgallery/core/widgets/password_dialog.dart';
import 'package:smartgallery/features/Display%20Interset/view/display_interset.dart';
import 'package:smartgallery/features/Gallery%20Folders/model/folders.dart';
import 'package:smartgallery/features/Gallery%20Folders/view/widgets/folder_card.dart';
import 'package:smartgallery/features/Gallery%20Folders/view/widgets/folder_settings_dialog.dart';
import 'package:smartgallery/features/Gallery%20Folders/view/widgets/gallery_header.dart';
import 'package:smartgallery/features/Photos%20Gallery/view/widget/photo_grid.dart';
import 'package:smartgallery/features/Gallery%20Folders/view%20model/gallery_folder_cubit.dart';
import 'package:smartgallery/features/Gallery%20Folders/view%20model/gallery_folder_states.dart';

class MainGalleryPage extends StatefulWidget {
  final int userId; // Add userId parameter

  const MainGalleryPage({super.key, required this.userId});

  @override
  State<MainGalleryPage> createState() => _MainGalleryPageState();
}

class _MainGalleryPageState extends State<MainGalleryPage> {
  List<Map<String, dynamic>> _folders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  void _loadFolders() {
    context.read<GalleryFolderCubit>().getAllFolders(userId: widget.userId);
  }

  void _openFolder(Map<String, dynamic> folder) {
    if (folder['isLocked']) {
      _showPasswordDialog(folder);
    } else {
      _navigateToFolderPhotos(folder);
    }
  }

  void _showPasswordDialog(Map<String, dynamic> folder) {
    showDialog(
      context: context,
      builder:
          (context) => PasswordDialog(
            folder: folder,
            onPasswordCorrect: () => _navigateToFolderPhotos(folder),
          ),
    );
  }

  void _navigateToFolderPhotos(Map<String, dynamic> folder) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => PhotoGrid(
              photoUrls: [
                'assets/family.jpeg',
                'assets/family.jpeg',
                'assets/family.jpeg',
              ],
              folderName: folder['name'],
            ),
      ),
    );
  }

  void _showFolderSettings(Map<String, dynamic> folder) {
    showDialog(
      context: context,
      builder:
          (context) => FolderSettingsDialog(
            folder: folder,
            onFolderUpdated: _updateFolder,
            onFolderDeleted: _deleteFolder,
          ),
    );
  }

  void _updateFolder(Map<String, dynamic> updatedFolder) {
    // Update local state immediately for better UX
    setState(() {
      final index = _folders.indexWhere(
        (folder) => folder['id'] == updatedFolder['id'],
      );
      if (index != -1) {
        _folders[index] = updatedFolder;
      }
    });

    print('Folder updated locally: ${updatedFolder['name']}');
    print('Is locked: ${updatedFolder['isLocked']}');
    print('Password: ${updatedFolder['password']}');
  }

  void _deleteFolder(Map<String, dynamic> folder) {
    context.read<GalleryFolderCubit>().deleteFolder(
      folderName: folder['name'],
      userId: widget.userId,
    );
  }

  void _navigateToUpdateInterests() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => SelectedInterestsPage(
              userId: widget.userId,
              onInterestsChanged: (interests) {
                print('Interests changed: $interests');
              },
              onSave: () {
                print('Interests saved');
              },
            ),
      ),
    );
  }

  // Updated method name to handle multiple photos
  void _onPhotosAdded(List<String> photoPaths) {
    print('Photos added to gallery: $photoPaths');
    if (photoPaths.isNotEmpty) {
      // If only one photo, show folder selection dialog
      if (photoPaths.length == 1) {
        _showFolderSelectionDialog(photoPaths.first);
      } else {
        // For multiple photos, show batch folder selection
        _showBatchFolderSelectionDialog(photoPaths);
      }
    }
  }

  void _showFolderSelectionDialog(String photoPath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.folder_open, color: Themes.primary),
              const SizedBox(width: 8),
              Text(
                'Select Folder',
                style: TextStyle(
                  color: Themes.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _folders.length,
              itemBuilder: (context, index) {
                final folder = _folders[index];
                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: AssetImage(
                          folder['coverImage'] ?? 'assets/travel.jpeg',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child:
                        folder['isLocked']
                            ? Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.lock,
                                color: Colors.white,
                                size: 16,
                              ),
                            )
                            : null,
                  ),
                  title: Text(folder['name']),
                  subtitle: Text('${folder['photoCount']} photos'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _addPhotoToFolder(photoPath, folder);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Themes.accent)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _createNewFolder(photoPath);
              },
              child: Text(
                'New Folder',
                style: TextStyle(color: Themes.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  // New method to handle multiple photos at once
  void _showBatchFolderSelectionDialog(List<String> photoPaths) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.folder_open, color: Themes.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Select Folder for ${photoPaths.length} Photos',
                  style: TextStyle(
                    color: Themes.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _folders.length,
              itemBuilder: (context, index) {
                final folder = _folders[index];
                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: AssetImage(
                          folder['coverImage'] ?? 'assets/travel.jpeg',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child:
                        folder['isLocked']
                            ? Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.lock,
                                color: Colors.white,
                                size: 16,
                              ),
                            )
                            : null,
                  ),
                  title: Text(folder['name']),
                  subtitle: Text('${folder['photoCount']} photos'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _addPhotosToFolder(photoPaths, folder);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Themes.accent)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _createNewFolderWithPhotos(photoPaths);
              },
              child: Text(
                'New Folder',
                style: TextStyle(color: Themes.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  void _addPhotoToFolder(String photoPath, Map<String, dynamic> folder) {
    // Upload image using Cubit
    context.read<GalleryFolderCubit>().uploadImages(
      imagePaths: [photoPath],
      userId: widget.userId.toString(),
    );

    // Update local state
    setState(() {
      final index = _folders.indexWhere((f) => f['id'] == folder['id']);
      if (index != -1) {
        _folders[index]['photoCount'] =
            (_folders[index]['photoCount'] ?? 0) + 1;
      }
    });
  }

  // New method to handle multiple photos
  void _addPhotosToFolder(
    List<String> photoPaths,
    Map<String, dynamic> folder,
  ) {
    // Upload images using Cubit
    context.read<GalleryFolderCubit>().uploadImages(
      imagePaths: photoPaths,
      userId: widget.userId.toString(),
    );

    // Update local state
    setState(() {
      final index = _folders.indexWhere((f) => f['id'] == folder['id']);
      if (index != -1) {
        _folders[index]['photoCount'] =
            (_folders[index]['photoCount'] ?? 0) + photoPaths.length;
      }
    });
  }

  void _createNewFolder(String photoPath) {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Create New Folder',
            style: TextStyle(
              color: Themes.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: 'Enter folder name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Themes.primary, width: 2),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Themes.accent)),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  // First upload the image
                  context.read<GalleryFolderCubit>().uploadImages(
                    imagePaths: [photoPath],
                    userId: widget.userId.toString(),
                  );

                  // Create new folder locally (in real app, this would be handled by backend)
                  final newFolder = {
                    'id': DateTime.now().millisecondsSinceEpoch.toString(),
                    'name': nameController.text.trim(),
                    'photoCount': 1,
                    'coverImage': 'assets/travel.jpeg',
                    'isLocked': false,
                    'password': null,
                  };

                  setState(() {
                    _folders.add(newFolder);
                  });

                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Themes.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Create',
                style: TextStyle(color: Themes.customWhite),
              ),
            ),
          ],
        );
      },
    );
  }

  // New method to create folder with multiple photos
  void _createNewFolderWithPhotos(List<String> photoPaths) {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Create New Folder for ${photoPaths.length} Photos',
            style: TextStyle(
              color: Themes.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: 'Enter folder name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Themes.primary, width: 2),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Themes.accent)),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  // Upload all images
                  context.read<GalleryFolderCubit>().uploadImages(
                    imagePaths: photoPaths,
                    userId: widget.userId.toString(),
                  );

                  // Create new folder locally (in real app, this would be handled by backend)
                  final newFolder = {
                    'id': DateTime.now().millisecondsSinceEpoch.toString(),
                    'name': nameController.text.trim(),
                    'photoCount': photoPaths.length,
                    'coverImage': 'assets/travel.jpeg',
                    'isLocked': false,
                    'password': null,
                  };

                  setState(() {
                    _folders.add(newFolder);
                  });

                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Themes.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Create',
                style: TextStyle(color: Themes.customWhite),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Themes.secondary,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        toolbarHeight: kToolbarHeight + 48,
        title: Padding(
          padding: const EdgeInsets.only(top: 48),
          child: Text(
            'Pixort',
            style: TextStyle(
              color: Themes.primary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: BlocListener<GalleryFolderCubit, GalleryFolderStates>(
        listener: (context, state) {
          if (state is SuccessAllFoldersState) {
            setState(() {
              _isLoading = false;
              // Convert List<Folder> to List<Map<String, dynamic>> using toUIMap()
              _folders =
                  state.folders.map((folder) => folder.toUIMap()).toList();
            });
          } else if (state is FailureGalleryFolderState) {
            setState(() {
              _isLoading = false;
            });
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
          } else if (state is SuccessGalleryFolderState) {
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
            // Refresh folders after successful operations
            _loadFolders();
          }
        },
        child:
            _isLoading
                ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Themes.primary),
                  ),
                )
                : Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: GalleryHeader(
                          foldersCount: _folders.length,
                          onUpdateInterests: _navigateToUpdateInterests,
                          onPhotosAdded:
                              _onPhotosAdded, // Updated parameter name
                          userId: widget.userId,
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.85,
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final folder = _folders[index];
                            return FolderCard(
                              folder: Folder.fromUIMap(folder),
                              onTap: () => _openFolder(folder),
                              onSettings: () => _showFolderSettings(folder),
                            );
                          }, childCount: _folders.length),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 20)),
                    ],
                  ),
                ),
      ),
    );
  }
}
