/// Author: Rambo.Liu
/// Date: 2025/12/25 16:50
/// @Copyright by JYXC Since 2023
/// Description: 推荐类型
enum RecommendId {
  like,
  focus,
  recommend,
  daily,
  travel,
  moto
}

class RecommendType {

  String name;

  RecommendId id;

  RecommendType(this.name, this.id);
}
