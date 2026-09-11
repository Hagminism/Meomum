class CommunityPostUpdateResult {
  final String postId;
  final List<String> removedStoragePaths;

  const CommunityPostUpdateResult({
    required this.postId,
    required this.removedStoragePaths,
  });
}
