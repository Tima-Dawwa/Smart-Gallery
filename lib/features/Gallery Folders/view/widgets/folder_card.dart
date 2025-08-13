import 'package:flutter/material.dart';
import 'package:smartgallery/core/utils/themes.dart';

class FolderCard extends StatelessWidget {
  final Map<String, dynamic> folder;
  final VoidCallback onTap;
  final VoidCallback? onSettings;

  const FolderCard({
    super.key,
    required this.folder,
    required this.onTap,
    this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Themes.customWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Themes.customBlack.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  image: DecorationImage(
                    image: AssetImage(folder['coverImage']),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    if (folder['isLocked'])
                      Container(
                        decoration: BoxDecoration(
                          color: Themes.customBlack.withOpacity(0.6),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.lock,
                            color: Themes.customWhite,
                            size: 32,
                          ),
                        ),
                      ),

                    // Settings Button
                    Positioned(
                      top: 8,
                      left: 8,
                      child: GestureDetector(
                        onTap: () {
                          if (onSettings != null) {
                            onSettings!();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Themes.customBlack.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.settings,
                            color: Themes.customWhite,
                            size: 16,
                          ),
                        ),
                      ),
                    ),

                    // Photo Count
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Themes.customBlack.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${folder['photoCount']}',
                          style: TextStyle(
                            color: Themes.customWhite,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        if (folder['isLocked'])
                          Icon(Icons.lock, size: 16, color: Themes.accent),
                        if (folder['isLocked']) const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            folder['name'],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Themes.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
