/// Common validation utilities used across features.
abstract class Validators {
  /// Check if a string is empty or null.
  static bool isEmpty(String? value) {
    return value == null || value.trim().isEmpty;
  }

  /// Check if a string is not empty.
  static bool isNotEmpty(String? value) {
    return !isEmpty(value);
  }

  /// Validate a title (non-empty, reasonable length).
  static bool isValidTitle(String? value) {
    if (isEmpty(value)) return false;
    final trimmed = value!.trim();
    return trimmed.isNotEmpty && trimmed.length <= 500;
  }

  /// Validate a composer name.
  static bool isValidComposer(String? value) {
    if (isEmpty(value)) return false;
    final trimmed = value!.trim();
    return trimmed.isNotEmpty && trimmed.length <= 200;
  }

  /// Validate notes field.
  static bool isValidNotes(String? value) {
    if (value == null) return true; // Notes are optional
    return value.length <= 2000;
  }

  /// Validate a tag name.
  static bool isValidTag(String? value) {
    if (isEmpty(value)) return false;
    final trimmed = value!.trim();
    return trimmed.isNotEmpty && trimmed.length <= 50;
  }

  /// Check if a list contains valid tags.
  static bool hasValidTags(List<String>? tags) {
    if (tags == null || tags.isEmpty) return true;
    return tags.every((tag) => isValidTag(tag));
  }
}
