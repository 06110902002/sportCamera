/// Author: Rambo.Liu
/// Date: 2026/1/6 15:17
/// @Copyright by JYXC Since 2023
/// Description: TODO
/// 下拉刷新状态枚举
enum RefreshStatus {
  idle, // 闲置状态
  pulling, // 下拉中
  refreshing, // 刷新中
  completed, // 刷新完成
}

/// 下拉刷新配置类（统一管理可配置参数）
class RefreshConfig {
  // 触发刷新的最小下拉距离
  final double triggerDistance;
  // 刷新指示器高度
  final double indicatorHeight;
  // 回弹动画时长
  final Duration bounceDuration;
  // 刷新动画时长
  final Duration refreshDuration;

  const RefreshConfig({
    this.triggerDistance = 80.0,
    this.indicatorHeight = 60.0,
    this.bounceDuration = const Duration(milliseconds: 300),
    this.refreshDuration = const Duration(milliseconds: 500),
  });
}

