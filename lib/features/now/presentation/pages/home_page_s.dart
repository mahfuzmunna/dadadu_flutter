// // Example in your HomePage (or wherever you manage the video feed)
// // Make sure you have your dependencies set up in injection_container.dart for PostBloc
//
// import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart';
// import 'package:dadadu_app/features/now/presentation/bloc/feed_bloc.dart';
// import 'package:dadadu_app/features/now/presentation/widgets/video_post_item.dart';
// import 'package:dadadu_app/features/upload/domain/entities/post_entity.dart';
// import 'package:dadadu_app/injection_container.dart'; // For sl()
// // lib/features/now/presentation/pages/now_page.dart (Example)
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// class HomePage extends StatefulWidget {
//   const HomePage({super.key});
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   final PageController _pageController = PageController();
//   int _currentPageIndex = 0;
//
//   // Dummy data for demonstration. In a real app, this would come from a feed bloc/repository.
//   final List<PostEntity> _posts = [
//     PostEntity(
//       id: 'post_1_id',
//       userId: 'user_a_id',
//       videoUrl:
//           'https://dadadu.b-cdn.net/user_videos/a6a13d27-8ad1-4ea9-8bc6-72f0e01b193e/1753185415382.mp4',
//       description: 'Beautiful abstract particles.',
//       thumbnailUrl: '',
//       createdAt: DateTime.now(),
//       diamonds: 10,
//       comments: 3,
//       location: 'New York',
//       tag: 'abstract',
//       isDisabled: false,
//       visibilityLevel: 0,
//       views: 0,
//     ),
//     PostEntity(
//       id: 'post_1_id',
//       userId: 'user_a_id',
//       videoUrl:
//           'https://dadadu.b-cdn.net/user_videos/a6a13d27-8ad1-4ea9-8bc6-72f0e01b193e/1753185415382.mp4',
//       description: 'Beautiful abstract particles.',
//       thumbnailUrl: '',
//       createdAt: DateTime.now(),
//       diamonds: 10,
//       comments: 3,
//       location: 'New York',
//       tag: 'abstract',
//       isDisabled: false,
//       visibilityLevel: 0,
//       views: 0,
//     ),
//
//     // Add more dummy posts or fetch real ones
//   ];
//
//   // Dummy user data for demonstration
//   final Map<String, UserEntity> _users = {
//     // 'user_a_id': UserEntity(
//     //     id: 'user_a_id',
//     //     username: '@particle_master',
//     //     email: 'a@example.com',
//     //     profilePhotoUrl: 'https://i.pravatar.cc/150?img=1'),
//     // 'user_b_id': UserEntity(
//     //     id: 'user_b_id',
//     //     username: '@aurora_hunter',
//     //     email: 'b@example.com',
//     //     profilePhotoUrl: 'https://i.pravatar.cc/150?img=2'),
//   };
//
//   @override
//   void initState() {
//     super.initState();
//     _pageController.addListener(() {
//       int nextPageIndex = _pageController.page?.round() ?? 0;
//       if (_currentPageIndex != nextPageIndex) {
//         setState(() {
//           _currentPageIndex = nextPageIndex;
//         });
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: PageView.builder(
//         controller: _pageController,
//         scrollDirection: Axis.vertical,
//         itemCount: _posts.length,
//         itemBuilder: (context, index) {
//           final PostEntity post = _posts[index];
//           final UserEntity? postUser =
//               _users[post.userId]; // Get user for the post
//
//           return BlocProvider<FeedBloc>(
//             create: (context) => sl<FeedBloc>()
//               // ..add(LoadFeed(post.id)), // Load and subscribe to this post
//               ..add(LoadFeed()), // Load and subscribe to this post
//             child: VideoPostItem(
//               postUser: postUser,
//               isCurrentPage: index == _currentPageIndex,
//               onUserTapped: (userId) {
//                 // Navigate to user profile page
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('Tapped on user: $userId')),
//                 );
//                 // Navigator.of(context).push(MaterialPageRoute(builder: (_) => UserProfilePage(userId: userId)));
//               },
//               post: _posts.first,
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
