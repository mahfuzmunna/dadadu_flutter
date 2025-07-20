import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../features/home/domain/entities/post_entity.dart';
import '../../../../features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  @override
  Future<Either<Failure, List<PostEntity>>> getFeedPosts() async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));

    // Simulate success with dummy data
    final posts = [
      PostEntity(
        id: '1',
        authorId: 'user123',
        caption: 'Beautiful sunset!',
        imageUrl: 'https://example.com/sunset.jpg',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)), // Correct: Use DateTime
      ),
      PostEntity(
        id: '2',
        authorId: 'user456',
        caption: 'Coding all night...',
        imageUrl: 'https://example.com/coding.jpg',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)), // Correct: Use DateTime
      ),
      // Add more dummy posts if needed
    ];

    // Or simulate a failure
    // return const Left(ServerFailure(message: 'Failed to load posts'));
    return Right(posts);
  }
}