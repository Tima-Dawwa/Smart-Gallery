import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartgallery/core/utils/themes.dart';
import 'package:smartgallery/core/widgets/interest_chip_widget.dart';
import 'package:smartgallery/features/Display%20Interset/view/display_interset.dart';
import 'package:smartgallery/features/My%20Intereset/view/widgets/intereset_header.dart';
import 'package:smartgallery/features/My%20Intereset/view%20model/my_interset_cubit.dart';
import 'package:smartgallery/features/My%20Intereset/view%20model/my_interset_states.dart';

import 'widgets/continue_button.dart';

class InterestsPage extends StatefulWidget {
  final int userId;

  const InterestsPage({super.key, required this.userId});

  @override
  State<InterestsPage> createState() => _InterestsPageState();
}

class _InterestsPageState extends State<InterestsPage> {
  final Set<String> _selectedInterests = {};
  List<String> _availableInterests = [];
  List<String> _userInterests = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _isLoading = true;
    });

    // Use the combined method to load both data sets at once
    context.read<IntersetCubit>().loadAllData(widget.userId);
  }

  void _toggleInterest(String interest) {
    // Prevent toggling while operations are in progress
    if (_isLoading) return;

    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
        // Remove from user's interests if it was previously selected
        if (_userInterests.contains(interest)) {
          context.read<IntersetCubit>().deleteUserClassification(
            userId: widget.userId,
            classificationType: interest,
          );
        }
      } else {
        _selectedInterests.add(interest);
        // Add to user's interests
        context.read<IntersetCubit>().insertUserClassification(
          userId: widget.userId,
          classificationType: interest,
        );
      }
    });
  }

  void _continueToApp() {
    if (_selectedInterests.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => SelectedInterestsPage(
                userId: widget.userId,
                onInterestsChanged: (interests) {
                  print('Interests changed: $interests');
                },
                onSave: () {
                  print('Interests saved');
                },
              ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: Themes.customGradient),
        child: SafeArea(
          child: BlocListener<IntersetCubit, IntersetsStates>(
            listener: (context, state) {
              print('State received: ${state.runtimeType}');

              if (state is AllDataLoadedState) {
                setState(() {
                  _availableInterests = state.allTypes;
                  _userInterests = state.userTypes;
                  _selectedInterests.clear();
                  _selectedInterests.addAll(state.userTypes);
                  _isLoading = false;
                });
                print(
                  'All data loaded - Available: ${state.allTypes}, User: ${state.userTypes}',
                );
              } else if (state is LoadingIntersetsStates) {
                setState(() {
                  _isLoading = true;
                });
                print('Loading state received');
              } else if (state is ClassificationOperationSuccessState) {
                // Show success message but don't change loading state
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
              } else if (state is UserClassificationTypesLoadedState) {
                // Handle individual user types update (from refresh operations)
                setState(() {
                  _userInterests = state.userTypes;
                  _selectedInterests.clear();
                  _selectedInterests.addAll(state.userTypes);
                });
                print('User interests updated: ${state.userTypes}');
              } else if (state is ClassificationFailureState) {
                setState(() {
                  _isLoading = false;
                });
                // Show error message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${state.failure.errMessage}'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 4),
                  ),
                );
                print('Error: ${state.failure.errMessage}');
              }
            },
            child: Column(
              children: [
                const InterestsHeader(),

                if (_isLoading)
                  const Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            'Loading your interests...',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '${_selectedInterests.length} selected',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
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
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1,
                                      ),
                                    ),
                                    child: const Text(
                                      'Great choice!',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          if (_availableInterests.isNotEmpty)
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children:
                                  _availableInterests.map((interest) {
                                    final isSelected = _selectedInterests
                                        .contains(interest);
                                    return InterestChip(
                                      name: interest,
                                      icon: _getIconForInterest(interest),
                                      isSelected: isSelected,
                                      onTap: () => _toggleInterest(interest),
                                    );
                                  }).toList(),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.all(40),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 48,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No interests available at the moment',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _loadData,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white.withOpacity(
                                        0.2,
                                      ),
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),

                Container(
                  padding: const EdgeInsets.all(20.0),
                  child: ContinueButton(
                    isEnabled: _selectedInterests.isNotEmpty && !_isLoading,
                    selectedCount: _selectedInterests.length,
                    onPressed: _continueToApp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to get icons for interests
  IconData _getIconForInterest(String interest) {
    final iconMap = {
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
      // Add mappings for your actual interests from API
      'clothes': Icons.checkroom,
      'food': Icons.restaurant,
      'text': Icons.text_fields,
    };
    return iconMap[interest] ?? Icons.star;
  }
}
