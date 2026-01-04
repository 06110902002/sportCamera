/// Author: Rambo.Liu
/// Date: 2026/1/4 11:44
/// @Copyright by JYXC Since 2023
/// Description: 教程中 feed 数据模型
class FeedItem {
  final String imageUrl; // 实际项目中替换为网络图片URL
  final String title;
  final String author;

  FeedItem({
    required this.imageUrl,
    required this.title,
    required this.author,
  });
}
