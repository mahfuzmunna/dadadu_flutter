// // lib/features/now/presentation/widgets/video_post_item.dart
//
// import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart';
// import 'package:dadadu_app/features/now/presentation/bloc/post_bloc.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// class VideoPostItem extends StatelessWidget {
//   final bool isCurrentPage;
//   final Function(String userId) onUserTapped;
//
//   const VideoPostItem({
//     super.key,
//     required this.isCurrentPage,
//     required this.onUserTapped,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<PostBloc, PostState>(
//       builder: (context, state) {
//         // Handle Loading State
//         if (state is PostLoading || state is PostInitial) {
//           return const Center(child: CircularProgressIndicator());
//         }
//
//         // Handle Error State
//         if (state is PostError) {
//           return Center(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Text(
//                 'Could not load post: ${state.message}',
//                 style: const TextStyle(color: Colors.white),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           );
//         }
//
//         // Handle Loaded State
//         if (state is PostLoaded) {
//           // Now we get the post and author directly from the state
//           final post = state.post;
//           final author = state.author; // This can be null while loading
//
//           return Stack(
//             fit: StackFit.expand,
//             children: [
//               // Your Video Player would go here, using post.videoUrl
//               // It would use `isPlaying: isCurrentPage` to play/pause.
//               Container(
//                 color: Colors.black,
//                 alignment: Alignment.center,
//                 child: Text(post.caption, style: const TextStyle(color: Colors.white, fontSize: 18)),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(12.0),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // This sub-widget gracefully handles the author loading state
//                     _AuthorInfo(author: author, onUserTapped: onUserTapped),
//                     const SizedBox(height: 8),
//                     Text(
//                       post.caption,
//                       style: const TextStyle(color: Colors.white, shadows: [
//                         Shadow(blurRadius: 4.0, color: Colors.black)
//                       ]),
//                     ),
//                   ],
//                 ),
//               ),
//               // You can add like buttons etc. on the right side
//             ],
//           );
//         }
//
//         // Fallback for any other unhandled state
//         return const SizedBox.shrink();
//       },
//     );
//   }
// }
//
// // A dedicated sub-widget to display author info and handle its loading state
// class _AuthorInfo extends StatelessWidget {
//   final UserEntity? author;
//   final Function(String userId) onUserTapped;
//
//   const _AuthorInfo({required this.author, required this.onUserTapped});
//
//   @override
//   Widget build(BuildContext context) {
//     if (author == null) {
//       // Show a placeholder while the author is loading
//       return const Row(
//         children: [
//           CircleAvatar(radius: 20, backgroundColor: Colors.grey),
//           SizedBox(width: 8),
//           Text('loading...', style: TextStyle(color: Colors.white70)),
//         ],
//       );
//     }
//
//     return GestureDetector(
//       onTap: () => onUserTapped(author!.id),
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 20,
//             backgroundImage: author!.avatarUrl != null && author!.avatarUrl!.isNotEmpty
//                 ? NetworkImage(author!.avatarUrl!)
//                 : null,
//             child: author!.avatarUrl == null || author!.avatarUrl!.isEmpty
//                 ? const Icon(Icons.person)
//                 : null,
//           ),
//           const SizedBox(width: 8),
//           Text(
//             author!.username,
//             style: const TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//               shadows: [Shadow(blurRadius: 4.0, color: Colors.black)],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
