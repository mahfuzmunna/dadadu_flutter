// lib/core/widgets/scaffold_with_nav_bar.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  // This method maps the index of the tapped button in the BottomAppBar's Row
  // to the actual branch index in GoRouter's StatefulNavigationShell.
  // The 'Upload' button (FAB) is handled separately.
  void _onTap(BuildContext context, int index) {
    // Branch order in AppRouter: 0=Home, 1=Discover, 2=Upload, 3=Friends, 4=Profile
    // Button order in BottomAppBar: 0=Home, 1=Discover, (FAB), 2=Friends, 3=Profile
    int targetBranchIndex;
    if (index < 2) { // Home (0), Discover (1)
      targetBranchIndex = index;
    } else { // Friends (2 -> branch 3), Profile (3 -> branch 4)
      targetBranchIndex = index + 1;
    }

    navigationShell.goBranch(
      targetBranchIndex,
      initialLocation: targetBranchIndex == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the current selected branch index from GoRouter
    final int currentBranchIndex = navigationShell.currentIndex;

    // Map the current branch index to the index of the corresponding button
    // in the BottomAppBar's Row (excluding the FAB).
    int selectedButtonIndex;
    if (currentBranchIndex == 0) { // Home
      selectedButtonIndex = 0;
    } else if (currentBranchIndex == 1) { // Discover
      selectedButtonIndex = 1;
    } else if (currentBranchIndex == 3) { // Friends
      selectedButtonIndex = 2; // Friends is the 3rd button in the Row (index 2)
    } else if (currentBranchIndex == 4) { // Profile
      selectedButtonIndex = 3; // Profile is the 4th button in the Row (index 3)
    } else {
      selectedButtonIndex = -1; // Upload FAB is selected, or no button is selected
    }

    return Scaffold(
      body: navigationShell, // This renders the content of the currently active branch

      // Floating Action Button for 'Upload'
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(), // Makes the FAB circular
        backgroundColor: Theme.of(context).colorScheme.primaryContainer, // Example color
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer, // Icon color
        onPressed: () {
          // Navigate to the 'Upload' branch (assuming it's branch index 2)
          navigationShell.goBranch(2);
        },
        tooltip: 'Upload',
        elevation: currentBranchIndex == 2 ? 8 : 4, // Higher elevation if Upload is active
        child: const Icon(Icons.add_a_photo), // Icon for upload
      ),
      // Position the FAB in the center, docked to the BottomAppBar
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // BottomAppBar to create the cutout effect
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(), // Creates the semi-circular cutout
        notchMargin: 8.0, // Space between FAB and BottomAppBar
        color: Theme.of(context).colorScheme.surfaceContainerHighest, // Background color of the bar
        elevation: 4.0, // Shadow beneath the bar
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            // Home Button
            IconButton(
              icon: Icon(
                selectedButtonIndex == 0 ? Icons.home : Icons.home_outlined,
                color: selectedButtonIndex == 0 ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              onPressed: () => _onTap(context, 0), // Taps branch 0
              tooltip: 'Home',
            ),
            // Discover Button
            IconButton(
              icon: Icon(
                selectedButtonIndex == 1 ? Icons.explore : Icons.explore_outlined,
                color: selectedButtonIndex == 1 ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              onPressed: () => _onTap(context, 1), // Taps branch 1
              tooltip: 'Discover',
            ),
            // Spacer for the FloatingActionButton
            const SizedBox(width: 48.0), // Adjust width as needed to fit the FAB
            // Friends Button
            IconButton(
              icon: Icon(
                selectedButtonIndex == 2 ? Icons.people : Icons.people_outline, // Note: index 2 here corresponds to branch 3
                color: selectedButtonIndex == 2 ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              onPressed: () => _onTap(context, 2), // Taps branch 3
              tooltip: 'Friends',
            ),
            // Profile Button
            IconButton(
              icon: Icon(
                selectedButtonIndex == 3 ? Icons.person : Icons.person_outlined, // Note: index 3 here corresponds to branch 4
                color: selectedButtonIndex == 3 ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              onPressed: () => _onTap(context, 3), // Taps branch 4
              tooltip: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}