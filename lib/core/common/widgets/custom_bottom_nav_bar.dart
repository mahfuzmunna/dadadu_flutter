import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomBottomNavBar extends StatefulWidget {
  const CustomBottomNavBar({super.key});

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar>
    with TickerProviderStateMixin {
  late final AnimationController _lottieController;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  void _onTap(String route) {
    // Use context.go to switch tabs without building a stack on top
    GoRouter.of(context).go(route);
  }

  @override
  Widget build(BuildContext context) {
    // Find the current location to determine which icon is active
    final String location = GoRouterState.of(context).uri.toString();

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      elevation: 4.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildNavItem(
              icon: Icons.home_outlined,
              selectedIcon: Icons.home,
              route: '/home',
              location: location),
          _buildNavItem(
              icon: Icons.add_a_photo_outlined,
              selectedIcon: Icons.add_a_photo,
              route: '/upload',
              location: location),
          const SizedBox(width: 48.0), // Spacer for the FAB
          _buildNavItem(
              icon: Icons.people_outline,
              selectedIcon: Icons.people,
              route: '/friends',
              location: location),
          _buildNavItem(
              icon: Icons.person_outlined,
              selectedIcon: Icons.person,
              route: '/profile',
              location: location),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String route,
    required String location,
  }) {
    final bool isSelected = location.startsWith(route);
    return IconButton(
      icon: Icon(isSelected ? selectedIcon : icon),
      color: isSelected
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.onSurfaceVariant,
      onPressed: () => _onTap(route),
    );
  }
}
