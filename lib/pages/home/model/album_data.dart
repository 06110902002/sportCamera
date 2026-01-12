/// Author: Rambo.Liu
/// Date: 2025/12/25 19:43
/// @Copyright by JYXC Since 2023
/// Description: 相册文件
/// 相册文件类型
enum AlbumType {
  //相机文件
  camera(0),
  //已下载文件
  download(1);

  const AlbumType(this.value);
  final int value;
}

/// 相机文件 二级类型
enum AlbumSecondType {
  memory(0, "回忆"),
  all(1, "全部"),
  like(2, "收藏"),
  video(3, "视频"),
  photo(4, "照片"),
  livePhoto(5, "实况"),
  panoramic(6, "全景"),
  plat(7, "平面"),
  mark(8, "标记");

  const AlbumSecondType(this.value, this.name);
  final int value;
  final String name;
}

class AlbumData {
  AlbumType albumType;
  AlbumSecondType secondType;
  String title;
  String? imageUrl;

  AlbumData({
    required this.albumType,
    required this.secondType,
    required this.title,
    this.imageUrl,
  });
}
