import 'package:flutter/material.dart';
import 'package:smartgallery/core/utils/themes.dart';

class GalleryHeader extends StatelessWidget {
  final int foldersCount;
  final VoidCallback onUpdateInterests;

  const GalleryHeader({
    super.key,
    required this.foldersCount,
    required this.onUpdateInterests,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Themes.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.folder, color: Themes.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Folders',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Themes.primary,
                  ),
                ),
                Text(
                  '$foldersCount folders available',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          // Update Interests Button
          ElevatedButton.icon(
            onPressed: onUpdateInterests,
            icon: const Icon(Icons.favorite, size: 18),
            label: const Text('Interests'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Themes.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }
}
