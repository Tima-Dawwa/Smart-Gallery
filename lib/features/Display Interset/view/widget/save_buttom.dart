import 'package:flutter/material.dart';
import 'package:smartgallery/core/utils/themes.dart';

class SaveButton extends StatelessWidget {
  final VoidCallback onSave;
  final bool isLoading;

  const SaveButton({super.key, required this.onSave, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: isLoading ? null : Themes.primaryGradient,
        color: isLoading ? Colors.grey : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow:
            isLoading
                ? null
                : [
                  BoxShadow(
                    color: Themes.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onSave,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child:
                isLoading
                    ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                    : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.check, size: 20, color: Colors.white),
                      ],
                    ),
          ),
        ),
      ),
    );
  }
}
