// lib/core/common/widgets/scaffold_with_navbar.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.child,
    required this.currentLocation, // <--- Add this property
    super.key,
  });

  final Widget child;
  final String currentLocation; // <--- Store the passed location

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Upload',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.userFriends),
            label: 'Friends',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _getCurrentIndex(currentLocation), // <--- Use passed location
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) => _onTap(context, index),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  // Update this to accept String location directly
  int _getCurrentIndex(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/discover')) return 1;
    if (location.startsWith('/upload')) return 2;
    if (location.startsWith('/friends')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0; // Default to home if no match
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/home');
        break;
      case 1:
        GoRouter.of(context).go('/discover');
        break;
      case 2:
        GoRouter.of(context).go('/upload');
        break;
      case 3:
        GoRouter.of(context).go('/friends');
        break;
      case 4:
        GoRouter.of(context).go('/profile');
        break;
    }
  }
}