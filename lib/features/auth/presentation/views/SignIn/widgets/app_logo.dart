import 'package:flutter/material.dart';
import 'package:smartgallery/core/utils/themes.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Themes.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Themes.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(Icons.photo_library, size: 50, color: Colors.white),
    );
  }
}
