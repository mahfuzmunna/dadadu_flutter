import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import 'custom_bottom_nav_bar.dart'; // Import your new nav bar

class CustomScaffold extends StatefulWidget {
  final Widget child;

  const CustomScaffold({super.key, required this.child});

  @override
  State<CustomScaffold> createState() => _CustomScaffoldState();
}

class _CustomScaffoldState extends State<CustomScaffold>
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () => context.go('/discover'),
        tooltip: 'Discover',
        child: Lottie.asset(
          'assets/animations/globe.json',
          controller: _lottieController,
          onLoaded: (composition) {
            _lottieController
              ..duration = composition.duration
              ..repeat();
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
