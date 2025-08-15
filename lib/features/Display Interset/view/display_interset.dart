import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartgallery/core/utils/themes.dart';
import 'package:smartgallery/features/Display%20Interset/view%20model/display_intereset_cubit.dart';
import 'package:smartgallery/features/Display%20Interset/view%20model/display_interset_states.dart';
import 'package:smartgallery/features/Display%20Interset/view/widget/add_interset.dart';
import 'package:smartgallery/features/Display%20Interset/view/widget/add_interset_buttom.dart';
import 'package:smartgallery/features/Display%20Interset/view/widget/interset_header.dart';
import 'package:smartgallery/features/Display%20Interset/view/widget/save_buttom.dart';
import 'package:smartgallery/features/Display%20Interset/view/widget/selected_interset_section.dart';
import 'package:smartgallery/features/Gallery%20Folders/view/main_gallery_page.dart';

class SelectedInterestsPage extends StatelessWidget {
  final int userId; // Add userId parameter
  final Function(Set<String>)? onInterestsChanged;
  final VoidCallback? onSave;

  const SelectedInterestsPage({
    super.key,
    required this.userId,
    this.onInterestsChanged,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return SelectedInterestsView(
      userId: userId,
      onInterestsChanged: onInterestsChanged,
      onSave: onSave,
    );
  }
}

class SelectedInterestsView extends StatefulWidget {
  final int userId;
  final Function(Set<String>)? onInterestsChanged;
  final VoidCallback? onSave;

  const SelectedInterestsView({
    super.key,
    required this.userId,
    this.onInterestsChanged,
    this.onSave,
  });

  @override
  State<SelectedInterestsView> createState() => _SelectedInterestsViewState();
}

class _SelectedInterestsViewState extends State<SelectedInterestsView> {
  Set<String> _selectedInterests = {};
  List<String> _allInterests = [];
  bool _isInitialized = false;

  // Fallback icons for interests
  final Map<String, IconData> _interestIcons = {
    'Photography': Icons.camera_alt,
    'Travel': Icons.flight,
    'Food': Icons.restaurant,
    'Music': Icons.music_note,
    'Sports': Icons.sports_soccer,
    'Art': Icons.palette,
    'Technology': Icons.computer,
    'Books': Icons.book,
    'Movies': Icons.movie,
    'Gaming': Icons.videogame_asset,
    'Fashion': Icons.checkroom,
    'Fitness': Icons.fitness_center,
    'Nature': Icons.nature,
    'Cooking': Icons.kitchen,
    'Dancing': Icons.music_video,
    'Pets': Icons.pets,
    'Cars': Icons.directions_car,
    'Science': Icons.science,
    'History': Icons.history_edu,
    'Beauty': Icons.face_retouching_natural,
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // Load all classification types first
    context.read<ClassificationCubit>().getClassificationTypes();
    // Then load user's selected interests
    context.read<ClassificationCubit>().getUserClassificationTypes(
      widget.userId,
    );
  }

  void _removeInterest(String interest) {
    // Call API to delete user classification
    context.read<ClassificationCubit>().deleteUserClassification(
      userId: widget.userId,
      classificationType: interest,
    );
  }

  void _addInterest(String interest) {
    // Call API to insert user classification
    context.read<ClassificationCubit>().insertUserClassification(
      userId: widget.userId,
      classificationType: interest,
    );
  }

  void _notifyInterestsChanged() {
    widget.onInterestsChanged?.call(_selectedInterests);
  }

  void _showAddInterestDropdown() {
    final availableInterests =
        _allInterests
            .where((interest) => !_selectedInterests.contains(interest))
            .map(
              (interest) => {
                'name': interest,
                'icon': _getIconForInterest(interest),
              },
            )
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
    return _interestIcons[interestName] ?? Icons.star;
  }

  void _handleSave() {
    widget.onSave?.call();
    Navigator.pop(context, _selectedInterests);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainGalleryPage(userId: widget.userId,)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: Themes.customGradient),
        child: SafeArea(
          child: BlocListener<ClassificationCubit, ClassificationStates>(
            listener: (context, state) {
              if (state is ClassificationTypesLoadedState) {
                setState(() {
                  _allInterests = state.types;
                });
                // If user interests haven't been loaded yet, trigger that
                if (!_isInitialized) {
                  context
                      .read<ClassificationCubit>()
                      .getUserClassificationTypes(widget.userId);
                }
              } else if (state is UserClassificationTypesLoadedState) {
                setState(() {
                  _selectedInterests = state.userTypes.toSet();
                  _isInitialized = true;
                });
                _notifyInterestsChanged();
              } else if (state is ClassificationOperationSuccessState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Themes.primary,
                    duration: const Duration(seconds: 2),
                  ),
                );
                // Refresh user interests after successful operation
                // The cubit already does this, but we need to update our local state
              } else if (state is ClassificationFailureState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.failure.errMessage),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            child: Column(
              children: [
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
                      const SizedBox(width: 40),
                    ],
                  ),
                ),

                Expanded(
                  child: BlocBuilder<ClassificationCubit, ClassificationStates>(
                    builder: (context, state) {
                      if (state is LoadingClassificationState &&
                          !_isInitialized) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InterestsHeader(
                              selectedCount: _selectedInterests.length,
                            ),
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
                      );
                    },
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(20.0),
                  child: BlocBuilder<ClassificationCubit, ClassificationStates>(
                    builder: (context, state) {
                      final isLoading = state is LoadingClassificationState;
                      return SaveButton(
                        onSave: isLoading ? () {} : _handleSave,
                        isLoading: isLoading,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
