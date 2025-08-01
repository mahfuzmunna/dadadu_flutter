// lib/features/home/presentation/pages/discover_page.dart

import 'dart:async';

import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart';
import 'package:dadadu_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:dadadu_app/features/discover/presentation/pages/vibe_users_page_s.dart';
import 'package:dadadu_app/features/location/domain/usecases/get_location_name_usecase.dart';
import 'package:dadadu_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:dadadu_app/injection_container.dart' as di;
import 'package:dadadu_app/l10n/app_localizations.dart';
import 'package:dadadu_app/shared/widgets/pulsing_radar_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';

enum LocationPermissionStatus {
  initial,
  granted,
  denied,
  deniedForever,
  serviceDisabled,
  error,
}

class DiscoverPage extends StatelessWidget {
  final String userId;

  const DiscoverPage({required this.userId, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) =>
                di.sl<ProfileBloc>()..add(SubscribeToUserProfile(userId))),
      ],
      child: const _DiscoverPageContent(),
    );
  }
}

class _DiscoverPageContent extends StatefulWidget {
  const _DiscoverPageContent({super.key});

  @override
  State<_DiscoverPageContent> createState() => _DiscoverPageContentState();
}

class _DiscoverPageContentState extends State<_DiscoverPageContent> {
  LocationPermissionStatus _locationStatus = LocationPermissionStatus.initial;
  String _locationErrorMessage = "";
  Position? _currentPosition;
  bool _isLocationListenerActive = false;
  double _selectedDistance = 1; // Default distance in km
  bool _isDistanceLocked = false;
  bool _goToVide = false;
  String _selectedVibe = "";
  Position? _selectedCurrentPosition;
  double _selectedMaxDistance = 1;
  final TextEditingController referralController = TextEditingController();
  String? _referralLink;
  int? _referralsCount;
  List<UserEntity>? referred;

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _positionStreamSubscription?.cancel();
    _checkLocationPermissionAndService();
    _goToVide = false;
  }

  Future<void> _checkLocationPermissionAndService() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      // Test if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(
              () => _locationStatus = LocationPermissionStatus.serviceDisabled);
        }
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() => _locationStatus = LocationPermissionStatus.denied);
          }
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(
              () => _locationStatus = LocationPermissionStatus.deniedForever);
        }
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
        _locationErrorMessage =
            AppLocalizations.of(context)!.locationErrorMessage(e.toString());
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
        _showSnackBar(AppLocalizations.of(context)!.locationTrackingError,
            isError: true);
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
        (failure) => _showSnackBar(
            AppLocalizations.of(context)!.couldNotGetLocationName,
            isError: true),
        (locationName) {
          debugPrint("Location name : $locationName");
          // Dispatch event to ProfileBloc to update the database
          context.read<ProfileBloc>().add(UpdateUserLocation(
                userId: currentUserId,
                latitude: position.latitude,
                longitude: position.longitude,
                locationName: locationName,
              ));
          _showSnackBar(
              AppLocalizations.of(context)!.locationUpdatedTo(locationName));
        },
      );
    } catch (e) {
      debugPrint('Failed to update profile location: $e');
      _showSnackBar(AppLocalizations.of(context)!.failedToUpdateLocation,
          isError: true);
    }
  }

  void _openAppSettings() => Geolocator.openAppSettings();

  void _openLocationSettings() => Geolocator.openLocationSettings();


  Widget _buildBody() {
    switch (_locationStatus) {
      case LocationPermissionStatus.initial:
      // return const Center(child: CircularProgressIndicator());
      case LocationPermissionStatus.granted:
        if (_goToVide) {
          return VibeUsersPage(
              vibe: _selectedVibe,
              currentPosition: _selectedCurrentPosition as Position,
              maxDistance: _selectedMaxDistance,
              onBackPressed: () {
                setState(() {
                  _goToVide = false;
                });
              });
        }
        return BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
          // if (state is ProfileLoading || state is ProfileInitial) {
          //   return const Scaffold(
          //       body: Center(child: CircularProgressIndicator()));
          // }
          if (state is ProfileError) {
            return Scaffold(body: Center(child: Text(state.message)));
          }
          if (state is ProfileLoaded) {
            final currentUser = state.user;

            _referralLink =
                'https://sqdqbmnqosfzhmrpbvqe.supabase.co/functions/v1/invite-handler?referred_by=${currentUser.id}';
            _referralsCount = currentUser.referralsCount;
            referralController.text = _referralLink!;

            _isDistanceLocked =
                (_referralsCount != null && _referralsCount! >= 10)
                    ? false
                    : true;

            // All UI is now built using the live data from the BLoC state
            return _buildVibeSelectionPage();
          }

          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));

          // return const Scaffold(
          //     body: Center(child: Text('Something went wrong')));
        });
      default:
        return _buildLocationErrorPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (!_goToVide)
          ? AppBar(
              title: Hero(
                // This tag MUST match the one on the FloatingActionButton.
                tag: 'discover_fab_hero',
                // A common pattern to avoid text style issues during animation.
                flightShuttleBuilder: (
                  flightContext,
                  animation,
                  flightDirection,
                  fromHeroContext,
                  toHeroContext,
                ) {
                  return DefaultTextStyle(
                    style: DefaultTextStyle.of(toHeroContext).style,
                    child: toHeroContext.widget,
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 32, // Match size roughly to the destination look
                      width: 32,
                      child: Lottie.asset('assets/animations/globe.json'),
                    ),
                    const SizedBox(width: 8),
                    Text(AppLocalizations.of(context)!.discover),
                  ],
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
            )
          : null,
      body: _buildBody(),
    );
  }

  Widget _buildVibeSelectionPage() {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const PulsingRadarIcon(),
              const SizedBox(height: 24),
              Text(AppLocalizations.of(context)!.whatsYourVibe,
                  style: TextStyle(fontSize: 24)),
              const SizedBox(height: 40),
              _buildVibeButton(AppLocalizations.of(context)!.love,
                  Icons.favorite, Colors.pink),
              const SizedBox(height: 20),
              _buildVibeButton(AppLocalizations.of(context)!.business,
                  Icons.business_center, Colors.blue),
              const SizedBox(height: 20),
              _buildVibeButton(AppLocalizations.of(context)!.entertainment,
                  Icons.movie, Colors.purple),

              // NEW: Distance Selector UI
              _buildDistanceSelector(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDistanceSelector() {
    final theme = Theme.of(context);
    return Column(
      children: [
        const SizedBox(
          height: 18,
        ),
        Text(
          _isDistanceLocked
              ? AppLocalizations.of(context)!.searchWithin
              : AppLocalizations.of(context)!.searchAroundThe,
          style: theme.textTheme.titleMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 4),
        Text(
          _isDistanceLocked
              ? _selectedDistance < 1
                  ? AppLocalizations.of(context)!.distanceMeters(
                      (_selectedDistance * 1000).round() as String)
                  : AppLocalizations.of(context)!
                      .distanceKilometers(_selectedDistance.round() as String)
              : AppLocalizations.of(context)!.globe,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16), // Increased spacing for a cleaner look
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Left Icon Button: Update Location
              _buildSelectorButton(
                icon: Icons.my_location,
                tooltip: AppLocalizations.of(context)!.updateMyLocation,
                onPressed: () {
                  _showSnackBar(
                      AppLocalizations.of(context)!.updatingYourLocation);
                  _checkLocationPermissionAndService();
                },
              ),
              // Center Slider
              Expanded(
                child: _isDistanceLocked
                    ? Slider(
                        value: _selectedDistance,
                  min: 0.1,
                  // Start at 100m
                  max: 1.0,
                  // Max at 1km (locked limit)
                        divisions: 9,
                        // Creates 100m steps
                  label: _selectedDistance < 1
                            ? AppLocalizations.of(context)!.distanceMeters(
                                (_selectedDistance * 1000).round() as String)
                            : AppLocalizations.of(context)!.distanceKilometers(
                                _selectedDistance.round() as String),
                        activeColor: theme.colorScheme.primary,
                  inactiveColor: theme.colorScheme.surfaceContainerHighest,
                  onChanged: (double value) {
                    setState(() {
                      _selectedDistance = value;
                    });
                  },
                      )
                    : const Text(''),
              ),
              // Right Icon Button: Increase Limit
              _buildSelectorButton(
                icon: _isDistanceLocked ? Icons.lock : Icons.lock_open,
                tooltip: AppLocalizations.of(context)!.increaseDistanceLimit,
                onPressed: () => _showIncreaseLimitDialog(),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildSelectorButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon),
        color: theme.colorScheme.primary,
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );
  }

  // NEW: Method to show the "Increase Limit" dialog
  void _showIncreaseLimitDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (!_isDistanceLocked) {
              // --- UNLOCKED DIALOG ---
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                contentPadding: const EdgeInsets.all(24),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Lottie animation for a celebratory effect
                    Lottie.asset(
                      'assets/animations/globe.json', // Add your animation file
                      height: 120,
                      repeat: false,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.featureUnlocked,
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.congratulationsUnlocked,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
                actionsAlignment: MainAxisAlignment.center,
                actions: [
                  FilledButton(
                    child: Text(AppLocalizations.of(context)!.awesome),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              );
            } else {
              // --- INVITE DIALOG (Your existing UI) ---
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                title: Row(
                  children: [
                    Icon(Icons.people_alt_outlined),
                    SizedBox(width: 10),
                    Text(AppLocalizations.of(context)!.unlockMoreDistance,
                        style: TextStyle(fontSize: 20)),
                  ],
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          AppLocalizations.of(context)!
                              .unlockDistanceDescription,
                          style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 20),
                      Center(
                        child: Text.rich(
                          TextSpan(
                            style: Theme.of(context).textTheme.titleMedium,
                            children: [
                              TextSpan(
                                  text: AppLocalizations.of(context)!
                                      .yourReferrals),
                              TextSpan(
                                text: AppLocalizations.of(context)!
                                    .referralProgress(
                                        _referralsCount as String),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: referralController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText:
                              AppLocalizations.of(context)!.yourInviteLink,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.copy_all_rounded),
                            tooltip: AppLocalizations.of(context)!.copyLink,
                            onPressed: () {
                              if (_referralLink != null) {
                                Clipboard.setData(
                                    ClipboardData(text: _referralLink!));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          AppLocalizations.of(context)!
                                              .linkCopied)),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  FilledButton.icon(
                    icon: const Icon(Icons.share_rounded),
                    label: Text(AppLocalizations.of(context)!.share),
                    onPressed: () {
                      if (_referralLink != null) {
                        Share.share(
                          'Hey! Come join me on Dadadu, a new app for sharing moments. Use my link to sign up: $_referralLink',
                          subject: 'Invitation to Dadadu!',
                        );
                      }
                    },
                  ),
                  TextButton(
                    child: Text(AppLocalizations.of(context)!.gotIt),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            }
          },
        );
      },
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
        final authState = context.read<AuthBloc>().state;
        if (_currentPosition != null) {
          // ✅ Navigate to the new page, passing the vibe and position
          // context.push('/discover/users', extra: {
          //   'vibe': label,
          //   'position': _currentPosition!,
          //   'distance': _selectedDistance,
          // });

          if (authState is AuthAuthenticated) {
            context.read<ProfileBloc>().add(UpdateDiscoverMode(
                  userId: authState.user.id,
                  discoverMode: label,
                ));
          }

          setState(() {
            _goToVide = true;
            _selectedVibe = label;
            _selectedCurrentPosition = _currentPosition;
            _selectedMaxDistance =
                _isDistanceLocked ? _selectedDistance : 25000;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Text(AppLocalizations.of(context)!.gettingYourLocation)));
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
                    ? AppLocalizations.of(context)!.openAppSettings
                    : _locationStatus ==
                            LocationPermissionStatus.serviceDisabled
                        ? AppLocalizations.of(context)!.openLocationSettings
                        : AppLocalizations.of(context)!.retryPermission,
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
