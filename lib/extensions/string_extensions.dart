extension StringExtension on String? {
  String? capitalize() {
    if (this == null) return this;
    if (this!.length > 0) return "${this![0].toUpperCase()}${this!.substring(1)}";
    return this;
  }
}
