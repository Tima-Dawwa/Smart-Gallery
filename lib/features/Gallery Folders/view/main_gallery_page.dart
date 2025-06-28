import 'package:flutter/material.dart';
import 'package:smartgallery/core/utils/themes.dart';
import 'package:smartgallery/core/widgets/password_dialog.dart';
import 'package:smartgallery/features/Display%20Interset/view/display_interset.dart';
import 'package:smartgallery/features/Gallery%20Folders/view/widgets/folder_card.dart';
import 'package:smartgallery/features/Gallery%20Folders/view/widgets/gallery_header.dart';
import 'package:smartgallery/features/Photos%20Gallery/view/widget/photo_grid.dart';

class MainGalleryPage extends StatefulWidget {
  const MainGalleryPage({super.key});

  @override
  State<MainGalleryPage> createState() => _MainGalleryPageState();
}

class _MainGalleryPageState extends State<MainGalleryPage> {
  final List<Map<String, dynamic>> _folders = [
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
              folderName: 'My Photos',
            ),
      ),
    );
  }

  void _navigateToUpdateInterests() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => SelectedInterestsPage(
              initialSelectedInterests: {"Photography", "Books"},
            ),
      ),
    );
    print('Navigate to update interests page');
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
