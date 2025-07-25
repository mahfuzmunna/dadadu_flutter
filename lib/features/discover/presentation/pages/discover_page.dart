// lib/features/home/presentation/pages/discover_page.dart

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dadadu_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:dadadu_app/features/discover/domain/usecases/find_users_by_vibe_usecase.dart';
import 'package:dadadu_app/features/location/domain/usecases/get_location_name_usecase.dart';
import 'package:dadadu_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:dadadu_app/injection_container.dart' as di;
import 'package:dadadu_app/shared/widgets/pulsing_radar_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

enum LocationPermissionStatus {
  initial,
  granted,
  denied,
  deniedForever,
  serviceDisabled,
  error,
}

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  LocationPermissionStatus _locationStatus = LocationPermissionStatus.initial;
  String _locationErrorMessage = "";
  Position? _currentPosition;
  bool _isLocationListenerActive = false;

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final PageController _videoPageController = PageController();

  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _positionStreamSubscription?.cancel();
    _checkLocationPermissionAndService();
  }

  Future<void> _checkLocationPermissionAndService() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      // Test if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted)
          setState(
              () => _locationStatus = LocationPermissionStatus.serviceDisabled);
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted)
            setState(() => _locationStatus = LocationPermissionStatus.denied);
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted)
          setState(
              () => _locationStatus = LocationPermissionStatus.deniedForever);
        return;
      }

      // Permissions are granted, and service is enabled.
      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _locationStatus = LocationPermissionStatus.granted;
          _currentPosition = position;
        });
      }
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

  void _openAppSettings() => Geolocator.openAppSettings();

  void _openLocationSettings() => Geolocator.openLocationSettings();

  // --- Navigation & Other Callbacks (No Changes Needed) ---
  void _navigateToUserProfile(String userId) {
    // ... This entire method remains the same ...
  }

  Widget _buildBody() {
    switch (_locationStatus) {
      case LocationPermissionStatus.initial:
        return const Center(child: CircularProgressIndicator());
      case LocationPermissionStatus.granted:
        return _buildVibeSelectionPage();
      default:
        return _buildLocationErrorPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildVibeSelectionPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const PulsingRadarIcon(),
          const SizedBox(height: 24),
          const Text("What's your vibe today?", style: TextStyle(fontSize: 24)),
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
        if (_currentPosition != null) {
          // ✅ Navigate to the new page, passing the vibe and position
          context.push('/discover/users', extra: {
            'vibe': label,
            'position': _currentPosition!,
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Getting your location, please wait...')));
        }
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
}

class _UserCard extends StatelessWidget {
  final UserWithDistance userWithDistance;

  const _UserCard({required this.userWithDistance});

  @override
  Widget build(BuildContext context) {
    final user = userWithDistance.user;
    final distance = userWithDistance.distanceInKm.toStringAsFixed(1);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundImage: user.profilePhotoUrl != null
                  ? CachedNetworkImageProvider(user.profilePhotoUrl!)
                  : null,
              child: user.profilePhotoUrl == null
                  ? const Icon(Icons.person)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.fullName ?? 'No Name',
                      style: Theme.of(context).textTheme.titleLarge),
                  if (user.username != null)
                    Text('@${user.username!}',
                        style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  if (user.bio != null && user.bio!.isNotEmpty)
                    Text(user.bio!,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                          '$distance km away - ${user.location ?? 'Unknown Location'}',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
