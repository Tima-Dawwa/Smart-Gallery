import 'package:flutter/material.dart';
import 'package:smartgallery/core/utils/themes.dart';
import 'package:smartgallery/core/widgets/interest_chip_widget.dart';
import 'package:smartgallery/features/Display%20Interset/display_interset.dart';
import 'package:smartgallery/features/My%20Intereset/widgets/intereset_header.dart';

import 'widgets/continue_button.dart';

class InterestsPage extends StatefulWidget {
  const InterestsPage({Key? key}) : super(key: key);

  @override
  State<InterestsPage> createState() => _InterestsPageState();
}

class _InterestsPageState extends State<InterestsPage> {
  final Set<String> _selectedInterests = {};

  // Predefined interests with icons
  final List<Map<String, dynamic>> _availableInterests = [
    {'name': 'Photography', 'icon': Icons.camera_alt},
    {'name': 'Travel', 'icon': Icons.flight},
    {'name': 'Food', 'icon': Icons.restaurant},
    {'name': 'Music', 'icon': Icons.music_note},
    {'name': 'Sports', 'icon': Icons.sports_soccer},
    {'name': 'Art', 'icon': Icons.palette},
    {'name': 'Technology', 'icon': Icons.computer},
    {'name': 'Books', 'icon': Icons.book},
    {'name': 'Movies', 'icon': Icons.movie},
    {'name': 'Gaming', 'icon': Icons.videogame_asset},
    {'name': 'Fashion', 'icon': Icons.checkroom},
    {'name': 'Fitness', 'icon': Icons.fitness_center},
    {'name': 'Nature', 'icon': Icons.nature},
    {'name': 'Cooking', 'icon': Icons.kitchen},
    {'name': 'Dancing', 'icon': Icons.music_video},
    {'name': 'Pets', 'icon': Icons.pets},
    {'name': 'Cars', 'icon': Icons.directions_car},
    {'name': 'Science', 'icon': Icons.science},
    {'name': 'History', 'icon': Icons.history_edu},
    {'name': 'Beauty', 'icon': Icons.face_retouching_natural},
  ];

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        _selectedInterests.add(interest);
      }
    });
  }

  void _continueToApp() {
    if (_selectedInterests.isNotEmpty) {
      print('Selected interests: $_selectedInterests');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => SelectedInterestsPage(
                initialSelectedInterests: _selectedInterests,
              ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Themes.secondary,
      body: SafeArea(
        child: Column(
          children: [
            const InterestsHeader(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        children: [
                          Text(
                            '${_selectedInterests.length} selected',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          if (_selectedInterests.length >= 3)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.green,
                                  width: 1,
                                ),
                              ),
                              child: const Text(
                                'Great choice!',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children:
                          _availableInterests.map((interest) {
                            final isSelected = _selectedInterests.contains(
                              interest['name'],
                            );
                            return InterestChip(
                              name: interest['name'],
                              icon: interest['icon'],
                              isSelected: isSelected,
                              onTap: () => _toggleInterest(interest['name']),
                            );
                          }).toList(),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(20.0),
              child: ContinueButton(
                isEnabled: _selectedInterests.isNotEmpty,
                selectedCount: _selectedInterests.length,
                onPressed: _continueToApp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
