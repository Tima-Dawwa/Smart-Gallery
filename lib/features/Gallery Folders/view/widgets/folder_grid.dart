import 'package:flutter/material.dart';
import 'package:smartgallery/core/utils/themes.dart';
import 'package:smartgallery/features/Gallery%20Folders/view/widgets/photo_grid_item.dart';

class FolderPhotosPage extends StatelessWidget {
  final Map<String, dynamic> folder;

  const FolderPhotosPage({super.key, required this.folder});

  void _addPhoto() {
    print('Add photo to ${folder['name']}');
  }

  void _showPhoto(int index) {
    print('Show photo ${index + 1}');
  }

  @override
  Widget build(BuildContext context) {
    final List<String> photos = List.generate(
      folder['photoCount'],
      (index) => 'assets/images/photo_${index + 1}.jpg',
    );

    return Scaffold(
      backgroundColor: Themes.secondary,
      appBar: AppBar(
        backgroundColor: Themes.customWhite,
        elevation: 2,
        shadowColor: Themes.customBlack.withOpacity(0.1),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Themes.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              folder['name'],
              style: TextStyle(
                color: Themes.primary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              '${folder['photoCount']} photos',
              style: TextStyle(
                color: Themes.dark.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _addPhoto,
            icon: Icon(Icons.add_a_photo, color: Themes.primary),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              return PhotoGridItem(
                photoPath: photos[index],
                onTap: () => _showPhoto(index),
              );
            },
          ),
        ),
      ),
    );
  }
}
