extension TimeAgoExtension on DateTime {
  String toTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) {
      return '방금 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}일 전';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months달 전';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years년 전';
    }
  }
}
