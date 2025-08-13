import 'package:flutter/material.dart';
import 'package:smartgallery/core/utils/themes.dart';
import 'package:smartgallery/core/widgets/password_dialog.dart';
import 'package:smartgallery/features/Display%20Interset/view/display_interset.dart';
import 'package:smartgallery/features/Gallery%20Folders/view/widgets/folder_card.dart';
import 'package:smartgallery/features/Gallery%20Folders/view/widgets/folder_settings_dialog.dart';
import 'package:smartgallery/features/Gallery%20Folders/view/widgets/gallery_header.dart';
import 'package:smartgallery/features/Photos%20Gallery/view/widget/photo_grid.dart';

class MainGalleryPage extends StatefulWidget {
  const MainGalleryPage({super.key});

  @override
  State<MainGalleryPage> createState() => _MainGalleryPageState();
}

class _MainGalleryPageState extends State<MainGalleryPage> {
  List<Map<String, dynamic>> _folders = [
    {
      'id': '1',
      'name': 'Travel Photos',
      'photoCount': 25,
      'coverImage': 'assets/travel.jpeg',
      'isLocked': false,
      'password': null,
    },
    {
      'id': '2',
      'name': 'Family',
      'photoCount': 48,
      'coverImage': 'assets/family.jpeg',
      'isLocked': false,
      'password': null,
    },
    {
      'id': '3',
      'name': 'Private',
      'photoCount': 12,
      'coverImage': 'assets/private.jpeg',
      'isLocked': true,
      'password': '1234',
    },
    {
      'id': '4',
      'name': 'Work',
      'photoCount': 33,
      'coverImage': 'assets/work.jpeg',
      'isLocked': false,
      'password': null,
    },
    {
      'id': '5',
      'name': 'Vacation 2024',
      'photoCount': 67,
      'coverImage': 'assets/vacation.jpeg',
      'isLocked': true,
      'password': 'vacation',
    },
    {
      'id': '6',
      'name': 'Events',
      'photoCount': 19,
      'coverImage': 'assets/event.jpeg',
      'isLocked': false,
      'password': null,
    },
  ];

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

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Folder "${updatedFolder['name']}" updated successfully!',
          style: TextStyle(color: Themes.customWhite),
        ),
        backgroundColor: Themes.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _navigateToUpdateInterests() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => SelectedInterestsPage(
              userId: 1, // Replace with actual user ID
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

  void _onPhotoAdded(String photoPath) {
    print('Photo added to gallery: $photoPath');

    // You can implement logic here to:
    // 1. Show a folder selection dialog
    // 2. Add the photo to a default folder
    // 3. Create a new folder for the photo
    // 4. Send the photo to backend processing

    // Example: Show dialog to select folder
    _showFolderSelectionDialog(photoPath);
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
                        image: AssetImage(folder['coverImage']),
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

  void _addPhotoToFolder(String photoPath, Map<String, dynamic> folder) {
    setState(() {
      // Update photo count
      final index = _folders.indexWhere((f) => f['id'] == folder['id']);
      if (index != -1) {
        _folders[index]['photoCount'] =
            (_folders[index]['photoCount'] ?? 0) + 1;
      }
    });

    // TODO: Implement actual photo addition logic
    print('Adding photo $photoPath to folder ${folder['name']}');

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Photo added to "${folder['name']}" successfully!',
          style: TextStyle(color: Themes.customWhite),
        ),
        backgroundColor: Themes.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      ),
    );
  }

  void _createNewFolder(String photoPath) {
    // TODO: Implement new folder creation
    print('Creating new folder with photo: $photoPath');

    // Show a dialog to get folder name
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
                  final newFolder = {
                    'id': DateTime.now().millisecondsSinceEpoch.toString(),
                    'name': nameController.text.trim(),
                    'photoCount': 1,
                    'coverImage': 'assets/travel.jpeg', // Default cover
                    'isLocked': false,
                    'password': null,
                  };

                  setState(() {
                    _folders.add(newFolder);
                  });

                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'New folder "${newFolder['name']}" created with photo!',
                        style: TextStyle(color: Themes.customWhite),
                      ),
                      backgroundColor: Themes.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      margin: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                    ),
                  );
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
      body: Padding(
        padding: const EdgeInsets.only(top: 18),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: GalleryHeader(
                foldersCount: _folders.length,
                onUpdateInterests: _navigateToUpdateInterests,
                onPhotoAdded: _onPhotoAdded, // Pass the callback
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final folder = _folders[index];
                  return FolderCard(
                    folder: folder,
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
    );
  }
}
