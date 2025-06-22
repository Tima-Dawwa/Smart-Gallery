
import 'package:flutter/material.dart';
import 'package:smartgallery/core/utils/themes.dart';

class AddInterestButton extends StatelessWidget {
  final VoidCallback onTap;

  const AddInterestButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Themes.primary.withOpacity(0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Themes.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Add New Interest',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Themes.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
