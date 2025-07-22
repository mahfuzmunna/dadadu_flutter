// // lib/data/models/mock_data.dart
//
// // Assuming your entities are structured like this.
// // If your actual entities differ, please update these classes
// // to match your 'lib/features/auth/domain/entities/user_entity.dart'
// // and 'lib/features/upload/domain/entities/post_entity.dart' files.
//
// import '../../features/auth/domain/entities/user_entity.dart';
// import '../../features/upload/domain/entities/post_entity.dart';
//
// // --- Re-defining Entities for completeness (Adjust if yours are different) ---
// // This is a placeholder. In your actual project, these should be imported from
// // 'package:dadadu_app/features/auth/domain/entities/user_entity.dart'
// // and 'package:dadadu_app/features/upload/domain/entities/post_entity.dart'
// // I'm including them here so this mock_data.dart is a complete, runnable file
// // if you were to paste it directly into a blank project for testing.
//
// // If you already have these, you can remove these definitions
// // and just ensure the imports at the top of this file are correct.
//
// /*
// // Example UserEntity (based on previous conversations)
// class UserEntity {
//   final String uid;
//   final String username;
//   final String? email;
//   final String? profilePhotoUrl;
//   // Add other user fields as needed (e.g., bio, followers count)
//
//   const UserEntity({
//     required this.uid,
//     required this.username,
//     this.email,
//     this.profilePhotoUrl,
//   });
// }
//
// // Example PostEntity (based on previous conversations)
// class PostEntity {
//   final String id;
//   final String userId; // ID of the user who posted
//   final String videoUrl;
//   final String thumbnailUrl; // For grid views
//   final String description;
//   final int diamonds;
//   final int comments;
//   final DateTime timestamp;
//   // Add other post fields as needed (e.g., location, tags)
//
//   const PostEntity({
//     required this.id,
//     required this.userId,
//     required this.videoUrl,
//     required this.thumbnailUrl,
//     required this.description,
//     required this.diamonds,
//     required this.comments,
//     required this.timestamp,
//   });
// }
// */
// // --- END of Entity Re-definition ---
//
// // Mock Users
// final List<UserEntity> mockUsers = [
//   UserEntity(
//     uid: 'user1',
//     username: 'travel_lover',
//     email: 'travel@example.com',
//     profilePhotoUrl:
//         'https://picsum.photos/id/1011/50/50', // Replace with real URLs if you have them
//   ),
//   UserEntity(
//     uid: 'user2',
//     username: 'code_master',
//     email: 'code@example.com',
//     profilePhotoUrl: 'https://picsum.photos/id/1012/50/50',
//   ),
//   UserEntity(
//     uid: 'user3',
//     username: 'foodie_explorers',
//     email: 'foodie@example.com',
//     profilePhotoUrl: 'https://picsum.photos/id/1025/50/50',
//   ),
//   UserEntity(
//     uid: 'user4',
//     username: 'art_gallery',
//     email: 'art@example.com',
//     profilePhotoUrl: 'https://picsum.photos/id/1015/50/50',
//   ),
//   UserEntity(
//     uid: 'user5',
//     username: 'nature_walks',
//     email: 'nature@example.com',
//     profilePhotoUrl: 'https://picsum.photos/id/1016/50/50',
//   ),
// ];
//
// // Mock Posts
// final List<PostEntity> mockPosts = [
//   PostEntity(
//     id: 'post1',
//     userId: 'user1',
//     videoUrl:
//         'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
//     thumbnailUrl: 'https://picsum.photos/id/10/200/300',
//     // Example thumbnail for the grid
//     description: 'Beautiful butterfly in slow motion!',
//     diamonds: 1234,
//     comments: 56,
//     timestamp:
//         DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
//   ),
//   PostEntity(
//     id: 'post2',
//     userId: 'user2',
//     videoUrl:
//         'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
//     thumbnailUrl: 'https://picsum.photos/id/20/200/300',
//     description: 'A buzzing bee hard at work in the garden.',
//     diamonds: 876,
//     comments: 23,
//     timestamp:
//         DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
//   ),
//   PostEntity(
//     id: 'post3',
//     userId: 'user3',
//     videoUrl:
//         'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4',
//     // Another sample video
//     thumbnailUrl: 'https://picsum.photos/id/30/200/300',
//     description: 'Exploring the flavors of local street food!',
//     diamonds: 2500,
//     comments: 120,
//     timestamp:
//         DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
//   ),
//   PostEntity(
//     id: 'post4',
//     userId: 'user4',
//     videoUrl:
//         'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
//     // Reusing for variety
//     thumbnailUrl: 'https://picsum.photos/id/40/200/300',
//     description: 'Abstract art installation, truly captivating.',
//     diamonds: 999,
//     comments: 45,
//     timestamp:
//         DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
//   ),
//   PostEntity(
//     id: 'post5',
//     userId: 'user5',
//     videoUrl:
//         'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4',
//     thumbnailUrl: 'https://picsum.photos/id/50/200/300',
//     description: 'Peaceful hike through the mountains.',
//     diamonds: 3100,
//     comments: 180,
//     timestamp:
//         DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
//   ),
//   // Add more posts for a richer feed
//   PostEntity(
//     id: 'post6',
//     userId: 'user1',
//     videoUrl:
//         'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
//     thumbnailUrl: 'https://picsum.photos/id/60/200/300',
//     description: 'Another beautiful day for an adventure!',
//     diamonds: 700,
//     comments: 30,
//     timestamp:
//         DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
//   ),
//   PostEntity(
//     id: 'post7',
//     userId: 'user2',
//     videoUrl:
//         'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
//     thumbnailUrl: 'https://picsum.photos/id/70/200/300',
//     description: 'Solving complex algorithms, one line at a time.',
//     diamonds: 1500,
//     comments: 70,
//     timestamp:
//         DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
//   ),
//   PostEntity(
//     id: 'post8',
//     userId: 'user3',
//     videoUrl:
//         'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4',
//     thumbnailUrl: 'https://picsum.photos/id/80/200/300',
//     description: 'A culinary journey, from farm to table.',
//     diamonds: 2100,
//     comments: 90,
//     timestamp:
//         DateTime.now().subtract(const Duration(days: 6)).toIso8601String(),
//   ),
// ];
//
// // Helper to get user by ID
// UserEntity? getUserById(String uid) {
//   try {
//     return mockUsers.firstWhere((user) => user.uid == uid);
//   } catch (e) {
//     // Return null if user not found, or handle error as appropriate
//     return null;
//   }
// }
