// /// Author: Rambo.Liu
// /// Date: 2026/1/5 13:45
// /// @Copyright by JYXC Since 2023
// /// Description: TODO
// import 'package:flutter/material.dart';
// import 'package:sport_camera/widget/refresh_state.dart';
// // ============ 2. 组件定义 ============
//
//
// class CustomCustomCustomCustomCustomCustomCustomCustomCustomPullToRefresh extends StatefulWidget {
//   final Widget child;
//   final Future<void> Function()? onRefresh;
//
//   const CustomCustomCustomCustomCustomCustomCustomCustomCustomPullToRefresh({
//     super.key,
//     required this.child,
//     this.onRefresh,
//   });
//
//   @override
//   State<CustomCustomCustomCustomCustomCustomCustomCustomCustomPullToRefresh> createState() => _CustomCustomCustomCustomCustomCustomCustomCustomCustomPullToRefreshState();
// }
//
// class _CustomCustomCustomCustomCustomCustomCustomCustomCustomPullToRefreshState extends State<CustomCustomCustomCustomCustomCustomCustomCustomCustomPullToRefresh>
//     with TickerProviderStateMixin {
//   double _dragOffset = 0.0;
//   double _currentHeaderHeight = 0.0; // ✅ 当前显示的高度
//   RefreshState _currentState = RefreshState.idle;
//   Offset? _startPosition;
//
//   static const double maxHeight = 80.0;
//   static const double threshold = 80.0;
//   static const double growthFactor = 0.8; // 调大一点，确保可见
//
//   bool _isAtTop = true;
//
//   void _updateHeaderHeight(double targetHeight) {
//     setState(() {
//       _currentHeaderHeight = targetHeight.clamp(0.0, maxHeight);
//     });
//   }
//
//   void _handlePointerDown(PointerDownEvent event) {
//     if (_currentState == RefreshState.refreshing || !_isAtTop) return;
//     _startPosition = event.position;
//   }
//
//   void _handlePointerMove(PointerMoveEvent event) {
//     if (_startPosition == null ||
//         _currentState == RefreshState.refreshing ||
//         !_isAtTop) {
//       return;
//     }
//
//     final delta = event.position.dy - _startPosition!.dy;
//     if (delta < 0) return;
//
//     final newOffset = delta.clamp(0.0, threshold * 1.5);
//     setState(() {
//       _dragOffset = newOffset;
//     });
//
//     // ✅ 计算目标高度
//     final targetHeight = newOffset * growthFactor;
//     _updateHeaderHeight(targetHeight);
//
//     if (_dragOffset >= threshold) {
//       _currentState = RefreshState.readyToRefresh;
//     } else {
//       _currentState = RefreshState.pulling;
//     }
//   }
//
//   void _handlePointerUp(PointerUpEvent event) {
//     if (_startPosition == null ||
//         _currentState == RefreshState.refreshing ||
//         !_isAtTop) {
//       _startPosition = null;
//       return;
//     }
//
//     if (_currentState == RefreshState.readyToRefresh && widget.onRefresh != null) {
//       _currentState = RefreshState.refreshing;
//       _updateHeaderHeight(maxHeight); // 保持最大高度
//
//       widget.onRefresh?.call().then((_) {
//         if (mounted) {
//           // ✅ 刷新完成后：300ms 动画收起
//           _animateHeaderHeightTo(0, Duration(milliseconds: 300));
//         }
//       }).catchError((_) {
//         if (mounted) {
//           _animateHeaderHeightTo(0, Duration(milliseconds: 300));
//         }
//       });
//     } else {
//       // 未触发刷新：快速收起
//       _animateHeaderHeightTo(0, Duration(milliseconds: 200));
//     }
//     _startPosition = null;
//   }
//
//   void _animateHeaderHeightTo(double target, Duration duration) {
//     final controller = AnimationController(vsync: this, duration: duration);
//     final animation = Tween<double>(begin: _currentHeaderHeight, end: target).animate(
//       CurvedAnimation(parent: controller, curve: Curves.easeOut),
//     );
//
//     animation.addListener(() {
//       if (mounted) {
//         setState(() {
//           _currentHeaderHeight = animation.value;
//           // 同步 dragOffset（用于 Transform 偏移）
//           _dragOffset = animation.value / growthFactor;
//         });
//       }
//     });
//
//     animation.addStatusListener((status) {
//       if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
//         controller.dispose();
//         if (mounted) {
//           setState(() {
//             _currentState = RefreshState.idle;
//             _dragOffset = 0;
//           });
//         }
//       }
//     });
//
//     controller.forward();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return NotificationListener<ScrollNotification>(
//       onNotification: (notification) {
//         _isAtTop = notification.metrics.extentBefore <= 0.1;
//         if (!_isAtTop && _currentHeaderHeight > 0) {
//           _animateHeaderHeightTo(0, Duration(milliseconds: 200));
//         }
//         return false;
//       },
//       child: Listener(
//         onPointerDown: _handlePointerDown,
//         onPointerMove: _handlePointerMove,
//         onPointerUp: _handlePointerUp,
//         onPointerCancel: (_) => _startPosition = null,
//         child: Stack(
//           clipBehavior: Clip.none,
//           children: [
//             // ✅ 主体内容：偏移量 = _currentHeaderHeight（不是 _dragOffset！）
//             Transform.translate(
//               offset: Offset(0, _currentHeaderHeight),
//               child: widget.child,
//             ),
//
//             // ✅ Header：高度 = _currentHeaderHeight，贴顶
//             if (_currentHeaderHeight > 0)
//               Positioned(
//                 top: 0,
//                 left: 0,
//                 right: 0,
//                 height: _currentHeaderHeight,
//                 child: Container(
//                   color: Colors.yellow,
//                   alignment: Alignment.center,
//                   child: _buildHeadView(),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeadView() {
//     switch (_currentState) {
//       case RefreshState.refreshing:
//         return const CircularProgressIndicator();
//
//       case RefreshState.readyToRefresh:
//         return Transform.rotate(
//           angle: 3.14159,
//           child: const Icon(Icons.arrow_downward, color: Colors.grey, size: 24),
//         );
//
//       case RefreshState.pulling:
//         return const Icon(Icons.arrow_downward, color: Colors.grey, size: 24);
//
//       default:
//         return const SizedBox.shrink();
//     }
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//   }
// }



import 'package:flutter/material.dart';
import 'package:sport_camera/widget/refresh_state.dart';






class CustomPullToRefresh extends StatefulWidget {
  final Widget Function(ScrollController controller) builder;
  final Future<void> Function()? onRefresh;

  const CustomPullToRefresh({
    super.key,
    required this.builder,
    this.onRefresh,
  });

  @override
  State<CustomPullToRefresh> createState() => _CustomPullToRefreshState();
}

class _CustomPullToRefreshState extends State<CustomPullToRefresh> {
  late final ScrollController _scrollController = ScrollController();
  double _headerHeight = 0.0;
  RefreshState _state = RefreshState.idle;

  static const double kMaxHeaderHeight = 80.0;
  static const double kThreshold = 60.0;

  void _updateHeader(double overscroll) {
    if (_state == RefreshState.refreshing) return;

    final newHeight = overscroll.clamp(0.0, kMaxHeaderHeight);
    final newState = overscroll >= kThreshold
        ? RefreshState.readyToRefresh
        : RefreshState.pulling;

    if (newHeight != _headerHeight || newState != _state) {
      setState(() {
        _headerHeight = newHeight;
        _state = newState;
      });
    }
  }

  void _startRefreshing() {
    if (_state != RefreshState.readyToRefresh || widget.onRefresh == null) return;

    setState(() {
      _state = RefreshState.refreshing;
      _headerHeight = kMaxHeaderHeight; // 固定高度
    });

    widget.onRefresh!().whenComplete(() {
      if (mounted) _hideHeader();
    });
  }

  void _hideHeader() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    ).then((_) {
      if (mounted) {
        setState(() {
          _headerHeight = 0;
          _state = RefreshState.idle;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollUpdateNotification) {
              final position = notification.metrics;
              final scrollExtent = position.maxScrollExtent;

              // 如果内容不满一屏，无法下拉
              if (scrollExtent <= 0) return false;

              // 计算 overscroll：当前位置 - 最小可滚动位置
              final overscroll = position.pixels - position.minScrollExtent;

              if (overscroll < 0 && _state != RefreshState.refreshing) {
                _updateHeader(-overscroll);
              } else if (overscroll >= 0 && _headerHeight > 0 && _state != RefreshState.refreshing) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && _state != RefreshState.refreshing) {
                    setState(() {
                      _headerHeight = 0;
                      _state = RefreshState.idle;
                    });
                  }
                });
              }
            }

            if (notification is ScrollEndNotification &&
                _state == RefreshState.readyToRefresh) {
              _startRefreshing();
            }

            return false;
          },
          child: widget.builder(_scrollController),
        ),

        // Header 覆盖在顶部
        if (_headerHeight > 0)
          Positioned(
            top: -_headerHeight,
            left: 0,
            right: 0,
            child: Container(
              height: _headerHeight,
              color: Theme.of(context).scaffoldBackgroundColor,
              alignment: Alignment.center,
              child: _buildIndicator(),
            ),
          ),
      ],
    );
  }

  Widget _buildIndicator() {
    switch (_state) {
      case RefreshState.refreshing:
        return const CircularProgressIndicator.adaptive();
      case RefreshState.readyToRefresh:
        return const Icon(Icons.arrow_upward, color: Colors.blue, size: 24);
      case RefreshState.pulling:
        return const Icon(Icons.arrow_downward, color: Colors.grey, size: 24);
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}