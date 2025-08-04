import 'package:equatable/equatable.dart';

/// Represents the core FeedTags object, wrapping a list of tag maps.
class FeedTagsEntity extends Equatable {
  // Now a list of maps, e.g., [{"tag1": "score1"}, {"tag2": "score2"}]
  final List<Map<String, String>> tags;

  const FeedTagsEntity({
    this.tags = const [],
  });

  @override
  List<Object?> get props => [tags];

  static List<Map<String, String>> _parseTags(dynamic maybeTags) {
    if (maybeTags is Iterable) {
      final List<Map<String, String>> result = [];
      for (final item in maybeTags) {
        if (item is Map) {
          // Keep only string->string entries
          final clean = <String, String>{};
          item.forEach((key, value) {
            if (key is String && value is String) {
              clean[key] = value;
            }
          });
          if (clean.isNotEmpty) {
            result.add(clean);
          }
        }
      }
      return result;
    }
    return [];
  }

  factory FeedTagsEntity.fromMap(Map<String, dynamic> map) {
    return FeedTagsEntity(
      tags: _parseTags(map['tags']),
    );
  }
}
