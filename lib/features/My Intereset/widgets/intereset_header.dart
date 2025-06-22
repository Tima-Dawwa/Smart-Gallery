import 'package:flutter/material.dart';
import 'package:smartgallery/core/utils/themes.dart';

class InterestsHeader extends StatelessWidget {
  const InterestsHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
      child: Column(
        children: [
          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Themes.primary.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: Themes.primary.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(Icons.favorite, size: 40, color: Themes.primary),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            'What are you into?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Themes.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            'Choose your interests to personalize your experience',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Suggestion text
          Text(
            'Select at least 3 interests',
            style: TextStyle(
              fontSize: 14,
              color: Themes.third,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
