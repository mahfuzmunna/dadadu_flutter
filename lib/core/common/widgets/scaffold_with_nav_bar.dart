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
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Often preferred for 5 items
        currentIndex: navigationShell.currentIndex,
        onTap: (int index) {
          // Navigates to the selected branch and maintains its state
          navigationShell.goBranch(
            index,
            // Navigate to the root location of the branch
            initialLocation: index == navigationShell.currentIndex,
          );
          // If the tapped index is the 'Upload' tab (e.g., index 2),
          // GoRouter's redirect on '/upload' will handle sending it to '/camera'.
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Discover'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Upload'), // Changed icon for clarity
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Friends'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}