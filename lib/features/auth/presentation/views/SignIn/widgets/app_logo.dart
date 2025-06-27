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
        color: Themes.customWhite,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Themes.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipOval(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Your image as background
            Image.asset(
              "assets/logoapp.jpeg",
              fit: BoxFit.cover,
              color: Colors.white.withOpacity(0.3),
              colorBlendMode: BlendMode.overlay,
            ),

            // Icon on top
          ],
        ),
      ),
    );

    // OPTION 3: Text-based logo
    /*
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: Themes.customGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Themes.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'SG',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
      ),
    );
    */
  }
}
