// lib/features/home/presentation/pages/discover_page.dart
import 'package:dadadu_app/data/models/mock_data.dart';
import 'package:dadadu_app/features/home/presentation/widgets/video_post_item.dart';
import 'package:dadadu_app/features/upload/domain/entities/post_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:geolocator/geolocator.dart'; // Import geolocator

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

class _DiscoverPageState extends State<DiscoverPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PageController _videoPageController = PageController();
  int _currentVideoPageIndex = 0;

  LocationPermissionStatus _locationStatus = LocationPermissionStatus.initial;
  String _locationErrorMessage = "";
  String?
      _selectedVibe; // To store the selected vibe (Love, Business, Entertainment)

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkLocationPermissionAndService();

    _videoPageController.addListener(() {
      final newPage = _videoPageController.page?.round();
      if (newPage != null && newPage != _currentVideoPageIndex) {
        setState(() {
          _currentVideoPageIndex = newPage;
          debugPrint(
              '[DiscoverPage - Video Feed] Current page updated to $_currentVideoPageIndex');
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _videoPageController.dispose();
    super.dispose();
  }

  // --- Location Handling Methods ---
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
      _getCurrentLocation(); // Optionally get current location after permission
    } catch (e) {
      setState(() {
        _locationStatus = LocationPermissionStatus.error;
        _locationErrorMessage = 'An error occurred while checking location: $e';
      });
      debugPrint('Location Error: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      debugPrint(
          'Current Location: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      debugPrint('Failed to get current location: $e');
    }
  }

  void _openAppSettings() {
    Geolocator.openAppSettings();
  }

  void _openLocationSettings() {
    Geolocator.openLocationSettings();
  }

  // --- Navigation & Other Callbacks ---
  void _navigateToUserProfile(String userId) {
    debugPrint('Navigating to user profile: $userId');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Navigating to user $userId profile!')),
    );
  }

  void _navigateToPostDetail(PostEntity post) {
    debugPrint('Navigating to post detail: ${post.id}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing full post ${post.id} details!')),
    );
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
        if (_selectedVibe == null) {
          bodyContent = _buildVibeSelectionPage();
        } else {
          bodyContent = _buildDiscoverContent();
        }
        break;
      case LocationPermissionStatus.denied:
      case LocationPermissionStatus.deniedForever:
      case LocationPermissionStatus.serviceDisabled:
      case LocationPermissionStatus.error:
        bodyContent = _buildLocationErrorPage();
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        bottom: _selectedVibe != null &&
                _locationStatus == LocationPermissionStatus.granted
            ? TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Videos', icon: Icon(Icons.play_circle_fill)),
                  Tab(text: 'Explore', icon: Icon(Icons.grid_on)),
                ],
              )
            : null, // Hide tabs if vibe not selected or permission not granted
      ),
      body: bodyContent,
    );
  }

  Widget _buildVibeSelectionPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
        minimumSize: const Size(250, 60), // Fixed size for consistency
      ),
      onPressed: () {
        setState(() {
          _selectedVibe = label;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Vibe set to: $label! Loading relevant content...')),
        );
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

  Widget _buildDiscoverContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildVideoFeed(),
        _buildExploreGrid(),
      ],
    );
  }

  Widget _buildVideoFeed() {
    final filteredPosts = mockPosts;
    return PageView.builder(
      controller: _videoPageController,
      scrollDirection: Axis.vertical,
      itemCount: filteredPosts.length,
      // cacheExtent: 1.0,
      itemBuilder: (context, index) {
        final post = filteredPosts[index];
        final postUser = getUserById(post.userId);

        return VideoPostItem(
          key: ValueKey(post.id),
          post: post,
          postUser: postUser,
          isCurrentPage: _currentVideoPageIndex == index,
          onUserTapped: _navigateToUserProfile,
        );
      },
    );
  }

  // UPDATED: _buildExploreGrid to use StaggeredGrid.count
  Widget _buildExploreGrid() {
    final filteredPosts = mockPosts; // Or filter based on _selectedVibe

    // Manually create the list of StaggeredGridTile children
    final List<StaggeredGridTile> gridTiles =
        filteredPosts.asMap().entries.map((entry) {
      final int index = entry.key;
      final PostEntity post = entry.value;

      // Determine the size of the tile based on index
      final double mainAxisCellCount = (index % 5 == 0) ? 1.5 : 1.0;

      return StaggeredGridTile.count(
        crossAxisCellCount: 1, // Always 1 column wide for simplicity
        mainAxisCellCount: mainAxisCellCount,
        child: GestureDetector(
          onTap: () => _navigateToPostDetail(post),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              post.thumbnailUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[300],
                child: const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey)),
              ),
            ),
          ),
        ),
      );
    }).toList();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StaggeredGrid.count(
          crossAxisCount: 2, // Number of columns
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
          children: gridTiles, // Pass the pre-built list of tiles
        ),
      ),
    );
  }
}