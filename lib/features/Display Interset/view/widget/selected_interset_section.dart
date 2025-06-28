import 'package:flutter/material.dart';
import 'package:smartgallery/features/Display%20Interset/view/widget/interset_chip_selected.dart';

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
        const Text(
          'Selected Interests',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
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
