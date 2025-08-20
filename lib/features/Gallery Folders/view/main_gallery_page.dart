import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartgallery/core/utils/themes.dart';
import 'package:smartgallery/core/widgets/password_dialog.dart';
import 'package:smartgallery/features/Display%20Interset/view/display_interset.dart';
import 'package:smartgallery/features/Gallery%20Folders/model/folders.dart';
import 'package:smartgallery/features/Gallery%20Folders/model/media.dart';
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
  bool _isLoadingMedia = false;
  Map<String, dynamic>? _currentFolderBeingLoaded;

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
    setState(() {
      _isLoadingMedia = true;
      _currentFolderBeingLoaded = folder;
    });

    final int folderId = folder['id'];

    context.read<GalleryFolderCubit>().getFolderMedia(folderId: folderId);
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
    setState(() {
      final index = _folders.indexWhere(
        (folder) => folder['id'] == updatedFolder['id'],
      );
      if (index != -1) {
        _folders[index] = updatedFolder;
      }
    });
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

  void _onPhotosUploaded() {
    _loadFolders();
  }

  void _handleFolderMediaSuccess(
    List<Media> mediaList,
    String folderName,
    int folderId,
  ) {
    setState(() {
      _isLoadingMedia = false;
      _currentFolderBeingLoaded = null;
    });

    List<String> photoUrls =
        mediaList
            .where((media) => media.hasImage)
            .map((media) => "https://518f08bdc897.ngrok-free.app${media.imageBase64!}")
            .toList();

    if (photoUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'This folder is empty',
            style: TextStyle(color: Themes.customWhite),
          ),
          backgroundColor: Themes.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => PhotoGrid(
              folderid: folderId,
              photoUrls: photoUrls,
              folderName: folderName,
              mediaList: mediaList, 
              onPhotoUrlsUpdated: (updatedUrls) {
                print('Photo URLs updated: ${updatedUrls.length} photos');
              },
            ),
      ),
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
      body: Stack(
        children: [
          BlocListener<GalleryFolderCubit, GalleryFolderStates>(
            listener: (context, state) {
              if (state is SuccessAllFoldersState) {
                setState(() {
                  _isLoading = false;
                  _folders =
                      state.folders.map((folder) => folder.toUIMap()).toList();
                });
              } else if (state is SuccessFolderMediaState) {
                if (_currentFolderBeingLoaded != null) {
                  _handleFolderMediaSuccess(
                    state.mediaList,
                    _currentFolderBeingLoaded!['name'] ?? 'Unknown Folder',
                    _currentFolderBeingLoaded!['id'] ?? 0,
                  );
                } else {
                  final currentFolder =
                      _folders.isNotEmpty
                          ? _folders.first
                          : {'name': 'Unknown Folder', 'id': 0};
                  _handleFolderMediaSuccess(
                    state.mediaList,
                    currentFolder['name'],
                    currentFolder['id'],
                  );
                }
              } else if (state is FailureGalleryFolderState) {
                setState(() {
                  _isLoading = false;
                  _isLoadingMedia = false;
                  _currentFolderBeingLoaded = null;
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
                _loadFolders();
              }
            },
            child:
                _isLoading
                    ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Themes.primary,
                        ),
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
                              onPhotosUploaded: _onPhotosUploaded,
                              userId: widget.userId,
                            ),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            sliver:
                                _folders.isEmpty
                                    ? SliverToBoxAdapter(
                                      child: Container(
                                        height: 300,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.folder_outlined,
                                              size: 80,
                                              color: Themes.primary.withOpacity(
                                                0.5,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'No folders yet',
                                              style: TextStyle(
                                                color: Themes.primary
                                                    .withOpacity(0.7),
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Upload some photos to get started',
                                              style: TextStyle(
                                                color: Themes.primary
                                                    .withOpacity(0.5),
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    : SliverGrid(
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
                                          onSettings:
                                              () => _showFolderSettings(folder),
                                        );
                                      }, childCount: _folders.length),
                                    ),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 20)),
                        ],
                      ),
                    ),
          ),
          if (_isLoadingMedia)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Themes.primary),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _currentFolderBeingLoaded != null
                          ? 'Loading ${_currentFolderBeingLoaded!['name']} content...'
                          : 'Loading folder content...',
                      style: TextStyle(color: Themes.customWhite, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
