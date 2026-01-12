/// Author: Rambo.Liu
/// Date: 2026/1/5 13:44
/// @Copyright by JYXC Since 2023
/// Description: 下拉刷新的当前状态
enum RefreshState {
  /// 初始状态（未下拉）
  idle,

  /// 正在下拉但未达到刷新阈值
  pulling,

  /// 已达到刷新阈值，松手即可刷新
  readyToRefresh,

  /// 正在刷新中
  refreshing,

  /// 刷新完成（短暂过渡状态，通常自动回到 idle）
  refreshed,
}
