enum MyPageFeedTab {
  myPosts('내가 쓴 글'),
  myComments('내가 쓴 댓글'),
  likedPosts('좋아요한 글');

  final String label;

  const MyPageFeedTab(this.label);
}
