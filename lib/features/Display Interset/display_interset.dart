import 'package:flutter/material.dart';
import 'package:smartgallery/core/utils/themes.dart';
import 'package:smartgallery/features/Display%20Interset/widget/add_interset.dart';
import 'package:smartgallery/features/Display%20Interset/widget/add_interset_buttom.dart';
import 'package:smartgallery/features/Display%20Interset/widget/interset_header.dart';
import 'package:smartgallery/features/Display%20Interset/widget/save_buttom.dart';
import 'package:smartgallery/features/Display%20Interset/widget/selected_interset_section.dart';

class SelectedInterestsPage extends StatelessWidget {
  final Set<String> initialSelectedInterests;
  final Function(Set<String>)? onInterestsChanged;
  final VoidCallback? onSave;

  const SelectedInterestsPage({
    super.key,
    required this.initialSelectedInterests,
    this.onInterestsChanged,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return SelectedInterestsView(
      initialSelectedInterests: initialSelectedInterests,
      onInterestsChanged: onInterestsChanged,
      onSave: onSave,
    );
  }
}

class SelectedInterestsView extends StatefulWidget {
  final Set<String> initialSelectedInterests;
  final Function(Set<String>)? onInterestsChanged;
  final VoidCallback? onSave;

  const SelectedInterestsView({
    super.key,
    required this.initialSelectedInterests,
    this.onInterestsChanged,
    this.onSave,
  });

  @override
  State<SelectedInterestsView> createState() => _SelectedInterestsViewState();
}

class _SelectedInterestsViewState extends State<SelectedInterestsView> {
  late Set<String> _selectedInterests;

  final List<Map<String, dynamic>> _allInterests = [
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

  @override
  void initState() {
    super.initState();
    _selectedInterests = Set.from(widget.initialSelectedInterests);
  }

  void _removeInterest(String interest) {
    setState(() {
      _selectedInterests.remove(interest);
    });
    _notifyInterestsChanged();
  }

  void _addInterest(String interest) {
    setState(() {
      _selectedInterests.add(interest);
    });
    _notifyInterestsChanged();
  }

  void _notifyInterestsChanged() {
    widget.onInterestsChanged?.call(_selectedInterests);
  }

  void _showAddInterestDropdown() {
    final availableInterests =
        _allInterests
            .where((interest) => !_selectedInterests.contains(interest['name']))
            .toList();

    if (availableInterests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('All interests have been added!'),
          backgroundColor: Themes.primary,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => AddInterestBottomSheet(
            availableInterests: availableInterests,
            onInterestSelected: _addInterest,
          ),
    );
  }

  IconData _getIconForInterest(String interestName) {
    final interest = _allInterests.firstWhere(
      (interest) => interest['name'] == interestName,
      orElse: () => {'name': interestName, 'icon': Icons.star},
    );
    return interest['icon'];
  }

  void _handleSave() {
    widget.onSave?.call();
    Navigator.pop(context, _selectedInterests);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: Themes.customGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Padding(
                padding: const EdgeInsets.all(32),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'My Interests',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40), // Balance the back button
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InterestsHeader(selectedCount: _selectedInterests.length),

                      const SizedBox(height: 24),

                      if (_selectedInterests.isNotEmpty) ...[
                        SelectedInterestsSection(
                          selectedInterests: _selectedInterests,
                          onRemoveInterest: _removeInterest,
                          getIconForInterest: _getIconForInterest,
                        ),
                        const SizedBox(height: 20),
                      ],
                      AddInterestButton(onTap: _showAddInterestDropdown),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              // Save Button at bottom
              Container(
                padding: const EdgeInsets.all(20.0),
                child: SaveButton(onSave: _handleSave),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
