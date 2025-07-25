// lib/features/now/presentation/pages/discover_page.dart
import 'dart:async';

import 'package:dadadu_app/features/upload/domain/entities/post_entity.dart';
import 'package:dadadu_app/shared/widgets/pulsing_radar_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../injection_container.dart' as di;
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../location/domain/usecases/get_location_name_usecase.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';

enum LocationPermissionStatus {
  initial,
  granted,
  denied,
  deniedForever,
  serviceDisabled,
  error,
}

class DiscoverPage extends StatefulWidget {
  DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

// ✅ REMOVED: SingleTickerProviderStateMixin is no longer needed
class _DiscoverPageState extends State<DiscoverPage> {
  // ✅ REMOVED: TabController is no longer needed
  // late TabController _tabController;

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final PageController _videoPageController = PageController();
  int _currentVideoPageIndex = 0;

  StreamSubscription<Position>? _positionStreamSubscription;
  bool _isLocationListenerActive = false;
  LocationPermissionStatus _locationStatus = LocationPermissionStatus.initial;
  String _locationErrorMessage = "";
  String? _selectedVibe;

  @override
  void initState() {
    super.initState();
    // ✅ REMOVED: No need to initialize TabController
    // _tabController = TabController(length: 2, vsync: this);
    _checkLocationPermissionAndService();
    _videoPageController.addListener(() {
      final newPage = _videoPageController.page?.round();
      if (newPage != null && newPage != _currentVideoPageIndex) {
        setState(() {
          _currentVideoPageIndex = newPage;
        });
      }
    });
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    // ✅ REMOVED: No need to dispose TabController
    // _tabController.dispose();
    _videoPageController.dispose();
    super.dispose();
  }

  // --- Location Handling Methods (No Changes Needed) ---
  Future<void> _checkLocationPermissionAndService() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      // Test if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationStatus = LocationPermissionStatus.serviceDisabled;
          _locationErrorMessage =
              'Location services are disabled. Please enable them in your device settings.';
        });
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationStatus = LocationPermissionStatus.denied;
            _locationErrorMessage =
                'Location permissions are denied. Please grant permission to personalize your experience.';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationStatus = LocationPermissionStatus.deniedForever;
          _locationErrorMessage =
              'Location permissions are permanently denied. Please enable them from the app settings.';
        });
        return;
      }

      // Permissions are granted, and service is enabled.
      setState(() {
        _locationStatus = LocationPermissionStatus.granted;
      });
      _startLocationUpdates();
      // _getCurrentLocation(); // Optionally get current location after permission
      // _getCurrentLocationAndUpdateProfile();
    } catch (e) {
      setState(() {
        _locationStatus = LocationPermissionStatus.error;
        _locationErrorMessage = 'An error occurred while checking location: $e';
      });
      debugPrint('Location Error: $e');
    }
  }

  void _startLocationUpdates() {
    if (_isLocationListenerActive) return; // Prevent multiple subscriptions

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100, // Update location every 100 meters.
    );

    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) {
        debugPrint(
            'New position received: ${position.latitude}, ${position.longitude}');
        // For each new position from the stream, run the update logic.
        _updateProfileLocation(position);
      },
      onError: (error) {
        debugPrint('Error in location stream: $error');
        _showSnackBar('Location tracking error.', isError: true);
      },
    );
    setState(() {
      _isLocationListenerActive = true;
    });
  }

  Future<void> _updateProfileLocation(Position position) async {
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        debugPrint('User not authenticated, cannot update location.');
        return;
      }
      final String currentUserId = authState.user.id;

      final getLocationNameUseCase = di.sl<GetLocationNameUseCase>();
      final result = await getLocationNameUseCase(GetLocationNameParams(
          lat: position.latitude, lon: position.longitude));

      result.fold(
        (failure) =>
            _showSnackBar('Could not get location name.', isError: true),
        (locationName) {
          debugPrint("Location name : $locationName");
          // Dispatch event to ProfileBloc to update the database
          context.read<ProfileBloc>().add(UpdateUserLocation(
                userId: currentUserId,
                latitude: position.latitude,
                longitude: position.longitude,
                locationName: locationName,
              ));
          _showSnackBar('Location updated to $locationName!');
        },
      );
    } catch (e) {
      debugPrint('Failed to update profile location: $e');
      _showSnackBar('Failed to update location.', isError: true);
    }
  }

  void _openAppSettings() {
    Geolocator.openAppSettings();
  }

  void _openLocationSettings() {
    Geolocator.openLocationSettings();
  }

  // --- Navigation & Other Callbacks (No Changes Needed) ---
  void _navigateToUserProfile(String userId) {
    // ... This entire method remains the same ...
  }

  void _navigateToPostDetail(PostEntity post) {
    // ... This entire method remains the same ...
  }

  // --- UI Building Methods ---
  @override
  Widget build(BuildContext context) {
    Widget bodyContent;

    switch (_locationStatus) {
      case LocationPermissionStatus.initial:
        bodyContent = const Center(child: CircularProgressIndicator());
        break;
      case LocationPermissionStatus.granted:
        // ✅ UPDATED LOGIC: If a vibe is selected, show the new content page.
        // Otherwise, show the vibe selection page.
        if (_selectedVibe == null) {
          bodyContent = _buildVibeSelectionPage();
        } else {
          bodyContent = _buildVibeContentPage();
        }
        break;
      default:
        bodyContent = _buildLocationErrorPage();
        break;
    }

    return Scaffold(
      key: _scaffoldMessengerKey,
      // ✅ The AppBar is now simpler and doesn't need a TabBar
      appBar: AppBar(
        leading: _selectedVibe != null
            ? IconButton(
                onPressed: () => setState(() {
                      _selectedVibe = null;
                    }),
                icon: const Icon(Icons.arrow_back_ios_new))
            : null,
        title: Text(_selectedVibe ?? 'Discover'),
        // The back button will appear automatically inside the Vibe Content Page
      ),
      body: bodyContent,
    );
  }

  Widget _buildVibeSelectionPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const PulsingRadarIcon(),
          const SizedBox(
            height: 24,
          ),
          const Text(
            "What's your vibe today?",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          _buildVibeButton("Love", Icons.favorite, Colors.pink),
          const SizedBox(height: 20),
          _buildVibeButton("Business", Icons.business_center, Colors.blue),
          const SizedBox(height: 20),
          _buildVibeButton("Entertainment", Icons.movie, Colors.purple),
        ],
      ),
    );
  }

  Widget _buildVibeButton(String label, IconData icon, Color color) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white),
      label: Text(label,
          style: const TextStyle(color: Colors.white, fontSize: 18)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        minimumSize: const Size(250, 60),
      ),
      onPressed: () {
        setState(() {
          _selectedVibe = label;
        });
      },
    );
  }

  Widget _buildLocationErrorPage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 80, color: Colors.grey[600]),
            const SizedBox(height: 20),
            Text(
              _locationErrorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                if (_locationStatus == LocationPermissionStatus.deniedForever) {
                  _openAppSettings();
                } else if (_locationStatus ==
                    LocationPermissionStatus.serviceDisabled) {
                  _openLocationSettings();
                } else {
                  _checkLocationPermissionAndService();
                }
              },
              child: Text(
                _locationStatus == LocationPermissionStatus.deniedForever
                    ? 'Open App Settings'
                    : _locationStatus ==
                            LocationPermissionStatus.serviceDisabled
                        ? 'Open Location Settings'
                        : 'Retry Permission',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ NEW WIDGET: This builds the page shown AFTER a vibe is selected.
  Widget _buildVibeContentPage() {
    // For demonstration, we'll show a simple placeholder.
    // You can easily swap these placeholders with your _buildVideoFeed()
    // and _buildExploreGrid() methods.

    return Column(
      children: [
        // Header moved to appbar

        // Content for the vibe
        Expanded(
          child: Center(
            child: Text(
              'Showing content for $_selectedVibe',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          // EXAMPLE of where your content would go:
          // child: TabBarView(
          //   controller: _tabController,
          //   children: [
          //     _buildVideoFeed(), // Your existing video feed
          //     _buildExploreGrid(), // Your existing explore grid
          //   ],
          // ),
        ),
      ],
    );
  }

  // This method is unchanged, ready to be used inside _buildVibeContentPage
  void _showSnackBar(String message, {bool isError = false}) {
    final scaffoldMessenger = _scaffoldMessengerKey.currentState;
    if (scaffoldMessenger == null) return;
    scaffoldMessenger.hideCurrentSnackBar();
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

/*
  // Your existing (commented out) methods are preserved and can be
  // placed inside the _buildVibeContentPage method.
  Widget _buildVideoFeed() {
    // ...
  }

  Widget _buildExploreGrid() {
    // ...
  }
  */
}
