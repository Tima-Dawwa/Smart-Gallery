import 'package:flutter/material.dart';
import 'package:smartgallery/core/utils/themes.dart';

class InterestChipSelected extends StatelessWidget {
  final String interest;
  final IconData icon;
  final VoidCallback onRemove;

  const InterestChipSelected({
    super.key,
    required this.interest,
    required this.icon,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Themes.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Themes.primary.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Themes.primary),
          const SizedBox(width: 8),
          Text(
            interest,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Themes.primary,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 12, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
