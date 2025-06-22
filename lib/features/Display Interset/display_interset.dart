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
        const SnackBar(
          content: Text('All interests have been added!'),
          duration: Duration(seconds: 2),
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
      backgroundColor: Themes.secondary,
      appBar: InterestsAppBar(),
      body: SafeArea(
        child: Padding(
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
              const Spacer(),
              SaveButton(onSave: _handleSave),
            ],
          ),
        ),
      ),
    );
  }
}

class InterestsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const InterestsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'My Interests',
          style: TextStyle(color: Themes.primary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
