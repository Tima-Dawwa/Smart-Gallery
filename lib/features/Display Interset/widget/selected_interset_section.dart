import 'package:flutter/material.dart';
import 'package:smartgallery/core/utils/themes.dart';
import 'package:smartgallery/features/Display%20Interset/widget/interset_chip_selected.dart';

class SelectedInterestsSection extends StatelessWidget {
  final Set<String> selectedInterests;
  final Function(String) onRemoveInterest;
  final IconData Function(String) getIconForInterest;

  const SelectedInterestsSection({
    super.key,
    required this.selectedInterests,
    required this.onRemoveInterest,
    required this.getIconForInterest,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selected Interests',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Themes.primary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children:
              selectedInterests.map((interest) {
                return InterestChipSelected(
                  interest: interest,
                  icon: getIconForInterest(interest),
                  onRemove: () => onRemoveInterest(interest),
                );
              }).toList(),
        ),
      ],
    );
  }
}
