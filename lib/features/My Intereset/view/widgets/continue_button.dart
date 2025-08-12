import 'package:flutter/material.dart';
import 'package:smartgallery/core/utils/themes.dart';

class ContinueButton extends StatelessWidget {
  final bool isEnabled;
  final int selectedCount;
  final VoidCallback onPressed;
  final bool isLoading;

  const ContinueButton({
    super.key,
    required this.isEnabled,
    required this.selectedCount,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: isEnabled && !isLoading ? Themes.primaryGradient : null,
        color: isEnabled && !isLoading ? null : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isEnabled && !isLoading
                  ? Colors.transparent
                  : Colors.white.withOpacity(0.3),
          width: 1,
        ),
        boxShadow:
            isEnabled && !isLoading
                ? [
                  BoxShadow(
                    color: Themes.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ]
                : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled && !isLoading ? onPressed : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading) ...[
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                ] else if (isEnabled && selectedCount > 0) ...[
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
                  isLoading
                      ? 'Saving...'
                      : isEnabled
                      ? 'Continue'
                      : 'Select interests to continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color:
                        isEnabled && !isLoading
                            ? Colors.white
                            : Colors.white.withOpacity(0.6),
                  ),
                ),
                if (isEnabled && !isLoading) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward,
                    size: 20,
                    color: Colors.white,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
