extension StringSlugExtension on String {
  String toFolderSlug() {
    final normalized = trim().toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]+'),
      '_',
    );
    final collapsed = normalized.replaceAll(RegExp('_+'), '_');
    return collapsed.replaceAll(RegExp(r'^_|_$'), '');
  }
}
