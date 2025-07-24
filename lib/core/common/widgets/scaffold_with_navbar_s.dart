// lib/core/widgets/scaffold_with_nav_bar.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  void _onTap(BuildContext context, int index) {
    int targetBranchIndex;
    if (index < 2) {
      targetBranchIndex = index;
    } else {
      targetBranchIndex = index + 1;
    }
    navigationShell.goBranch(
      targetBranchIndex,
      initialLocation: targetBranchIndex == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final int currentBranchIndex = navigationShell.currentIndex;
    int selectedButtonIndex;
    if (currentBranchIndex <= 1) {
      selectedButtonIndex = currentBranchIndex;
    } else if (currentBranchIndex >= 3) {
      selectedButtonIndex = currentBranchIndex - 1;
    } else {
      selectedButtonIndex = -1;
    }

    // ✅ WRAP a Stack around the Scaffold to allow for overlaying widgets.
    return Stack(
      children: [
        Scaffold(
          body: navigationShell,
          floatingActionButton: FloatingActionButton(
            shape: const CircleBorder(),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
            onPressed: () {
              navigationShell.goBranch(2);
            },
            tooltip: 'Upload',
            elevation: currentBranchIndex == 2 ? 8 : 4,
            child: const Icon(Icons.add_a_photo),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 8.0,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            elevation: 4.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    selectedButtonIndex == 0 ? Icons.home : Icons.home_outlined,
                    color: selectedButtonIndex == 0
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () => _onTap(context, 0),
                  tooltip: 'Home',
                ),
                IconButton(
                  icon: Icon(
                    selectedButtonIndex == 1
                        ? Icons.explore
                        : Icons.explore_outlined,
                    color: selectedButtonIndex == 1
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () => _onTap(context, 1),
                  tooltip: 'Discover',
                ),
                const SizedBox(width: 48.0),
                IconButton(
                  icon: Icon(
                    selectedButtonIndex == 2
                        ? Icons.people
                        : Icons.people_outline,
                    color: selectedButtonIndex == 2
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () => _onTap(context, 2),
                  tooltip: 'Friends',
                ),
                IconButton(
                  icon: Icon(
                    selectedButtonIndex == 3
                        ? Icons.person
                        : Icons.person_outlined,
                    color: selectedButtonIndex == 3
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () => _onTap(context, 3),
                  tooltip: 'Profile',
                ),
              ],
            ),
          ),
        ),

        // ✅ ADD the second FAB here, positioned on top of the Scaffold.
        Positioned(
          // Standard Material Design positioning for a default FAB
          bottom: 96.0,
          right: 16.0,
          child: FloatingActionButton(
            // This is the "normal default" implementation
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Secondary Action Tapped!')),
              );
            },
            tooltip: 'Secondary Action',
            child: const Icon(Icons.chat_bubble_outline_rounded),
          ),
        ),
      ],
    );
  }
}
