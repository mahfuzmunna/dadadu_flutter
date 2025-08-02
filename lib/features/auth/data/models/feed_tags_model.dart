import '../../domain/entities/feed_tags_entity.dart';

/// The data model that handles conversion from a Supabase map to a FeedTagsEntity.
class FeedTagsModel extends FeedTagsEntity {
  const FeedTagsModel({
    super.tags,
  });

  factory FeedTagsModel.fromMap(List<dynamic>? list) {
    if (list == null) {
      return const FeedTagsModel();
    }
    // ✅ CHANGED: Correctly parse the list of maps from the database.
    // Supabase returns a List<dynamic> where each item is a Map.
    final tagsList =
        list.map((item) => Map<String, String>.from(item as Map)).toList();
    return FeedTagsModel(tags: tagsList);
  }
}
