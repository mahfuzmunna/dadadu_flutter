// feed_repository.dart
import '../../data/datasources/feed_remote_data_source.dart';

abstract class FeedRepository {
  Stream<FeedResult> streamFeed();
}

class FeedRepositoryImpl implements FeedRepository {
  final FeedRemoteDataSource _remote;

  FeedRepositoryImpl(this._remote);

  @override
  Stream<FeedResult> streamFeed() => _remote.streamFeed();
}
