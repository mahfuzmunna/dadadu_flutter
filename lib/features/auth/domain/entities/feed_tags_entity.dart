import 'package:equatable/equatable.dart';

/// Represents the core FeedTags object, wrapping a list of tag maps.
class FeedTagsEntity extends Equatable {
  // ✅ CHANGED: Now a list of maps, e.g., [{"tag1": "score1"}, {"tag2": "score2"}]
  final List<Map<String, String>> tags;

  const FeedTagsEntity({
    this.tags = const [],
  });

  @override
  List<Object?> get props => [tags];
}
