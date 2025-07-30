// lib/core/widgets/scaffold_with_nav_bar.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class ScaffoldWithNavBar extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  @override
  State<ScaffoldWithNavBar> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends State<ScaffoldWithNavBar>
    with SingleTickerProviderStateMixin {
  // late final AnimationController _controller;
  late final AnimationController _lottieController;

  @override
  void initState() {
    super.initState();
    // _controller = AnimationController(
    //   duration: const Duration(seconds: 5),
    //   vsync: this,
    // )..repeat();
    _lottieController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    // _controller.dispose();
    _lottieController.dispose();
    super.dispose();
  }

  // ✅ Logic updated for the new button order
  void _onTap(BuildContext context, int index) {
    // Branch order in AppRouter: 0=Home, 1=Discover, 2=Upload, 3=Friends, 4=Profile
    // Button order in BottomAppBar: 0=Home, 1=Upload, (FAB), 2=Friends, 3=Profile
    int targetBranchIndex;
    switch (index) {
      case 0: // Home
        targetBranchIndex = 0;
        break;
      case 1: // Upload
        targetBranchIndex = 2;
        break;
      case 2: // Friends
        targetBranchIndex = 3;
        break;
      case 3: // Profile
        targetBranchIndex = 4;
        break;
      default:
        targetBranchIndex = 0;
    }

    widget.navigationShell.goBranch(
      targetBranchIndex,
      initialLocation: targetBranchIndex == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final int currentBranchIndex = widget.navigationShell.currentIndex;

    // ✅ Logic updated to map branch index back to the visual button index
    int selectedButtonIndex;
    switch (currentBranchIndex) {
      case 0: // Home
        selectedButtonIndex = 0;
        break;
      case 2: // Upload
        selectedButtonIndex = 1;
        break;
      case 3: // Friends
        selectedButtonIndex = 2;
        break;
      case 4: // Profile
        selectedButtonIndex = 3;
        break;
      default: // Discover (FAB is active) or no match
        selectedButtonIndex = -1;
        break;
    }

    return Scaffold(
      body: widget.navigationShell,
      floatingActionButton: FloatingActionButton(
        heroTag: 'discover_fab_hero',
        shape: const CircleBorder(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        onPressed: () {
          // ✅ FAB now navigates to the 'Discover' branch (branch index 1)
          widget.navigationShell.goBranch(1);
        },
        tooltip: 'Discover',
        // ✅ Tooltip updated
        elevation: currentBranchIndex == 1 ? 12 : 6,
        // ✅ Elevation check updated
        // child: RotationTransition(
        //   turns: _controller,
        //   child: const Icon(
        //       Icons.public), // The spinning globe is now for Discover
        // ),
        child: Lottie.asset(
          'assets/animations/globe.json', // Your Lottie file path
          controller: _lottieController,
          onLoaded: (composition) {
            // Configure the animation to play continuously
            _lottieController
              ..duration = composition.duration
              ..repeat();
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        height: 60,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        elevation: 4.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            // Home Button (Unchanged)
            IconButton(
              icon: AnimatedScale(
                scale: selectedButtonIndex == 0 ? 1.2 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  selectedButtonIndex == 0 ? Icons.home : Icons.home_outlined,
                  color: selectedButtonIndex == 0
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              onPressed: () => _onTap(context, 0),
              tooltip: 'Home',
            ),
            IconButton(
              icon: AnimatedScale(
                scale: selectedButtonIndex == 1 ? 1.2 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  selectedButtonIndex == 1
                      ? Icons.camera_alt
                      : Icons.camera_alt_outlined,
                  color: selectedButtonIndex == 1
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              onPressed: () => _onTap(context, 1),
              tooltip: 'Upload',
            ),
            const SizedBox(width: 48.0), // Spacer for the FAB
            IconButton(
              icon: AnimatedScale(
                scale: selectedButtonIndex == 2 ? 1.2 : 1.0,
                duration: Duration(milliseconds: 200),
                child: Icon(
                  selectedButtonIndex == 2
                      ? Icons.message
                      : Icons.message_outlined,
                  color: selectedButtonIndex == 2
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              onPressed: () => _onTap(context, 2),
              tooltip: 'Chats',
            ),

            IconButton(
              icon: AnimatedScale(
                scale: selectedButtonIndex == 3 ? 1.2 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  selectedButtonIndex == 3
                      ? Icons.person
                      : Icons.person_outlined,
                  color: selectedButtonIndex == 3
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              onPressed: () => _onTap(context, 3),
              tooltip: 'Chats',
            ),
          ],
        ),
      ),
    );
  }
}