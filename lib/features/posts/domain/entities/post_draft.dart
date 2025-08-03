import 'dart:typed_data';

class PostDraft {
  final String caption;
  final int intent;
  final Uint8List? selectedThumbnail;

  const PostDraft({
    this.caption = '',
    this.intent = 3,
    this.selectedThumbnail,
  });

  PostDraft copyWith({
    String? caption,
    int? intent,
    Uint8List? selectedThumbnail,
  }) {
    return PostDraft(
      caption: caption ?? this.caption,
      intent: intent ?? this.intent,
      selectedThumbnail: selectedThumbnail ?? this.selectedThumbnail,
    );
  }
}
