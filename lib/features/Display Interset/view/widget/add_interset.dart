import 'package:flutter/material.dart';
import 'package:smartgallery/core/utils/themes.dart';

class AddInterestBottomSheet extends StatelessWidget {
  final List<Map<String, dynamic>> availableInterests;
  final Function(String) onInterestSelected;

  const AddInterestBottomSheet({
    super.key,
    required this.availableInterests,
    required this.onInterestSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Add New Interest',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Themes.primary,
              ),
            ),
          ),

          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: availableInterests.length,
              itemBuilder: (context, index) {
                final interest = availableInterests[index];
                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Themes.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      interest['icon'],
                      color: Themes.primary,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    interest['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    onInterestSelected(interest['name']);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
