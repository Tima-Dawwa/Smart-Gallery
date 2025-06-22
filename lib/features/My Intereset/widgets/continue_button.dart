import 'package:flutter/material.dart';
import 'package:smartgallery/core/utils/themes.dart';

class ContinueButton extends StatelessWidget {
  final bool isEnabled;
  final int selectedCount;
  final VoidCallback onPressed;

  const ContinueButton({
    super.key,
    required this.isEnabled,
    required this.selectedCount,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? Themes.primary : Colors.grey.shade300,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          disabledForegroundColor: Colors.grey.shade500,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: isEnabled ? 4 : 0,
          shadowColor: isEnabled ? Themes.primary.withOpacity(0.3) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isEnabled && selectedCount > 0) ...[
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    selectedCount.toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Text(
              isEnabled ? 'Continue' : 'Select interests to continue',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isEnabled ? Colors.white : Colors.grey.shade500,
              ),
            ),
            if (isEnabled) ...[
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 20, color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }
}
