import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:start/dadadu/globe_button.dart';
import 'package:start/screens/feed_screen.dart';
import 'package:start/screens/profile_screen.dart';
import 'package:start/screens/upload_screen.dart';
import 'package:start/shared/services/notifications_service.dart';
import 'package:start/generated/l10n.dart'; // ✅ localization import

class HomeScreen extends StatefulWidget {
  final int initialIndex;
  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _selectedIndex;
  final PageStorageBucket _bucket = PageStorageBucket();
  final NotificationsService _notificationService = NotificationsService();
final ValueNotifier<bool> tabChanged = ValueNotifier(false);


  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      await _notificationService.initialize(context);
      debugPrint('✅ Services Dadadu initialisés avec succès!');
    } catch (e) {
      debugPrint('❌ Erreur initialisation services: $e');
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
        tabChanged.value=true;
      });
    }
  }

  void _onGlobeTapped() {
    debugPrint('🌍 Globe button tapped (localization menu maybe?)');
    // TODO: Show locale/language picker
  }

  void _onNotificationsTapped() {
    _notificationService.markAllAsRead();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '🔔 Notifications screen coming soon!',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.tealAccent,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;
    final s = S.of(context); // ✅ localization shortcut
  final List<Widget> _screens =  [
    FeedScreen(key: const PageStorageKey('Feed'), tabChanged: tabChanged,),
    const UploadScreen(key: PageStorageKey('Upload')),
    const ProfileScreen(key: PageStorageKey('Profile')),
  ];
    return Scaffold(
      body: Stack(
        children: [
          PageStorage(
            bucket: _bucket,
            child: _screens[_selectedIndex],
          ),
          if (_selectedIndex == 0)
            Positioned(
              bottom: 48,
              left: MediaQuery.of(context).size.width / 2 - 30,
              child: GlobeButton(onTap: _onGlobeTapped),
            ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: ValueListenableBuilder<int>(
              valueListenable: _notificationService.unreadCountNotifier,
              builder: (context, unreadCount, child) {
                return GestureDetector(
                  onTap: _onNotificationsTapped,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.black.withOpacity(0.7)
                          : Colors.white.withOpacity(0.7),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.tealAccent.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.tealAccent.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Icon(
                          unreadCount > 0
                              ? Icons.notifications_active
                              : Icons.notifications_outlined,
                          color: unreadCount > 0
                              ? Colors.tealAccent
                              : isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                          size: 24,
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.5),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                unreadCount > 99
                                    ? '99+'
                                    : unreadCount.toString(),
                                style: TextStyle(
                                  color: theme.primaryColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(
              color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
              width: 0.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withValues(alpha: 0.5)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.amberAccent,
          unselectedItemColor: isDarkMode ? Colors.white54 : Colors.black54,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.explore),
              activeIcon: const Icon(Icons.explore, size: 28),
              label: s.navNow, // ✅ Localized
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.upload),
              activeIcon: const Icon(Icons.upload, size: 28),
              label: s.navUpload, // ✅ Localized
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person),
              activeIcon: const Icon(Icons.person, size: 28),
              label: s.navProfile, // ✅ Localized
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
