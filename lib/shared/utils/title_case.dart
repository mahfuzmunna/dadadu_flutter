/// Converts a string to title case.
/// Example: "john.doe" becomes "John Doe"
String toTitleCase(String input) {
  if (input.isEmpty) {
    return '';
  }

  // Replace common separators with a space and split into words
  final List<String> words = input.replaceAll(RegExp(r'[._]'), ' ').split(' ');

  // Capitalize the first letter of each word
  final capitalizedWords = words.map((word) {
    if (word.isEmpty) return '';
    return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
  });

  // Join the words back together with a space
  return capitalizedWords.join(' ');
}
