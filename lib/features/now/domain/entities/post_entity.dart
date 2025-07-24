import 'package:equatable/equatable.dart';

class PostEntity extends Equatable {
  final String id;
  final String authorId;
  final String caption;
  final String imageUrl;
  final DateTime timestamp;

  const PostEntity({
    required this.id,
    required this.authorId,
    required this.caption,
    required this.imageUrl,
    required this.timestamp,
  });

  @override
  List<Object> get props => [id, authorId, caption, imageUrl, timestamp];
}