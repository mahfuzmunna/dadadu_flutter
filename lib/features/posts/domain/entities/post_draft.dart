import 'dart:typed_data';

class PostDraft {
  final String caption;
  final String intent;
  final Uint8List? selectedThumbnail;

  const PostDraft({
    this.caption = '',
    this.intent = 'Entertainment',
    this.selectedThumbnail,
  });

  PostDraft copyWith({
    String? caption,
    String? intent,
    Uint8List? selectedThumbnail,
  }) {
    return PostDraft(
      caption: caption ?? this.caption,
      intent: intent ?? this.intent,
      selectedThumbnail: selectedThumbnail ?? this.selectedThumbnail,
    );
  }
}
