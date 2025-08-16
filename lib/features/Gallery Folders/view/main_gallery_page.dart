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
  final int userId;

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

  // Simple callback when photos are uploaded successfully
  void _onPhotosUploaded() {
    print('Photos uploaded successfully, refreshing folders...');
    _loadFolders(); // Refresh the folder list to show updated photo counts
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
                          onPhotosUploaded:
                              _onPhotosUploaded, // Simple callback
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
