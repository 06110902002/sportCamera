import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'ScrollViewBehavior.dart';

/// Author: Rambo.Liu
/// Date: 2026/1/7 19:49
/// @Copyright by JYXC Since 2023
/// Description: 支持下拉刷新，上拉加载更多的滚动列表，目前仅支持垂直方向
///
/// =======================
/// 用户手势方向（只表示意图）
/// =======================
enum ScrollDirection {
  up, // 用户上推
  down, // 用户下拉
  idle,
}

/// =======================
/// 滚动物理阶段
/// =======================
enum ScrollPhase {
  dragging, // 拖动中
  ballistic, // 回弹中
  ballisticUp, //向上回弹
  ballisticDown, //向下回弹
  settling, // 回弹结束
  idle, // 静止
}

/// listView 组件构建器，主要是将ScrollPhysics 这类参数封装方便外部使用
typedef ScrollBehaviorBuilder = ScrollBehavior Function(ScrollPhysics? physics);

/// =======================
/// ChangeNotifier with Safe Notification Scheduling
/// 滚动时的数据通知
/// =======================
class ScrollPositionNotifier extends ChangeNotifier {
  double _position = 0.0;
  ScrollDirection _direction = ScrollDirection.idle;
  ScrollPhase _phase = ScrollPhase.idle;
  bool _isNotificationScheduled = false;

  double get position => _position;
  ScrollDirection get direction => _direction;
  ScrollPhase get phase => _phase;

  /// 安全地调度通知，以避免在帧渲染期间调用 notifyListeners
  void _scheduleNotify() {
    if (_isNotificationScheduled) return;
    _isNotificationScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isNotificationScheduled = false;
      notifyListeners();
    });
  }

  /// 用户拖动
  void onUserDrag(double position, double offset) {
    _position = position;
    _phase = ScrollPhase.dragging;

    if (offset != 0) {
      // 用户手指上推，列表内容向上滚动，offset 为负值。
      // 用户手指下拉，列表内容向下滚动，offset 为正值。
      _direction = offset > 0 ? ScrollDirection.down : ScrollDirection.up;
    }
    _scheduleNotify();
  }

  /// 开始回弹
  void startBallistic(double position) {
    _position = position;
    _phase = ScrollPhase.ballistic;
    _direction = ScrollDirection.up; // 回弹总是向上
    _scheduleNotify();
  }

  /// 开始回弹 区分回弹方向：向下还是向上
  void startBallisticWithDirection(
    double position,
    ScrollPhase ballisticDirection,
    ScrollDirection direction,
  ) {
    _position = position;
    _phase = ballisticDirection;
    _direction = direction; // 回弹区分向下还是向上
    _scheduleNotify();
  }

  /// 回弹过程中
  void updateBallistic(double position) {
    /// 处理三种回弹情况，防止不更新滚动值，导致listView 回弹暂停
    if (_phase != ScrollPhase.ballistic &&
        _phase != ScrollPhase.ballisticUp &&
        _phase != ScrollPhase.ballisticDown) {
      return;
    }
    _position = position;
    _scheduleNotify();
  }

  /// 回弹结束
  void finishBallistic() {
    if (_phase != ScrollPhase.ballistic &&
        _phase != ScrollPhase.ballisticUp &&
        _phase != ScrollPhase.ballisticDown) {
      return;
    }
    _phase = ScrollPhase.settling;
    _scheduleNotify();
  }

  /// 完全静止
  void settleToIdle() {
    // 允许从 settling 或 dragging 状态变为 idle
    if (_phase == ScrollPhase.idle) return;
    _phase = ScrollPhase.idle;
    _direction = ScrollDirection.idle;
    _scheduleNotify();
  }
}

/// =======================
/// ScrollPhysics 滚动监听，适配android /IOS 平台
/// =======================
class NotifyingBouncingScrollPhysics extends BouncingScrollPhysics {
  final ScrollPositionNotifier notifier;

  const NotifyingBouncingScrollPhysics({
    required this.notifier,
    ScrollPhysics? parent,
  }) : super(parent: parent);

  @override
  NotifyingBouncingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return NotifyingBouncingScrollPhysics(
      notifier: notifier,
      parent: buildParent(ancestor),
    );
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    final newPixels = position.pixels - offset;
    notifier.onUserDrag(newPixels, offset);
    return super.applyPhysicsToUserOffset(position, offset);
  }

  ///用户松手后的“惯性阶段”（可能是 fling，也可能是 overscroll 回弹）
  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    final sim = super.createBallisticSimulation(position, velocity);
    if (sim == null) {
      // 如果没有产生模拟（例如，滚动没有超出边界），则通知变为静止
      notifier.settleToIdle();
      return null;
    }
    //向上回弹
    final bool isOverscrollTop = position.pixels < position.minScrollExtent;
    //向下回弹
    final bool isOverscrollBottom = position.pixels > position.maxScrollExtent;
    final ScrollPhase ballistDirection = isOverscrollTop
        ? ScrollPhase.ballisticUp
        : ScrollPhase.ballisticDown;
    final ScrollDirection direction = isOverscrollTop
        ? ScrollDirection.up
        : ScrollDirection.down;
    print(
      "172-------------isOverscrollTop = $isOverscrollTop  isOverscrollBottom = $isOverscrollBottom",
    );

    final bool isBounce = isOverscrollTop || isOverscrollBottom;

    return _NotifierSimulation(
      sim,
      notifier,
      position.pixels,
      isBounce,
      ballistDirection,
      direction,
    );
  }
}

/// =======================
/// Simulation 包装，滚动列表的回弹器封装
/// =======================
class _NotifierSimulation extends Simulation {
  final Simulation _sim;
  final ScrollPositionNotifier _notifier;
  final bool _isBounce;
  final ScrollPhase _ballisticDirection;
  final ScrollDirection _direction;

  bool _ended = false;

  _NotifierSimulation(
    this._sim,
    this._notifier,
    double startPosition,
    this._isBounce,
    this._ballisticDirection,
    this._direction,
  ) {
    if (_isBounce) {
      _notifier.startBallisticWithDirection(
        startPosition,
        _ballisticDirection,
        _direction,
      );
    }
  }

  @override
  double x(double time) {
    final value = _sim.x(time);

    if (_isBounce) {
      _notifier.updateBallistic(value);

      if (!_ended && _sim.isDone(time)) {
        _ended = true;

        _notifier.finishBallistic();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _notifier.settleToIdle();
        });
      }
    }

    return value;
  }

  @override
  double dx(double time) => _sim.dx(time);

  @override
  bool isDone(double time) => _sim.isDone(time);
}

class PullToRefreshListView extends StatefulWidget {
  ///下拉加载任务通常是异常执行
  FutureOr Function()? onRefresh;

  /// 下拉刷新的头部视图，由外部自定义，可空。当没有时不创建这个视图
  Widget? headView;

  /// 是否开始的时候就刷新
  bool isOnStartRefresh = false;

  ///达到开始刷新的阈值，默认100，设置时这个值尽量大于headView的高度
  double? refreshThreshold;

  ///滚动列表视图
  ListView? contentView;

  static ScrollBehavior Function(ScrollPhysics? physics)
  defaultScrollBehaviorBuilder = _defaultScrollBehaviorBuilder;

  static ScrollBehavior _defaultScrollBehaviorBuilder(ScrollPhysics? physics) =>
      ScrollViewBehavior(physics);

  PullToRefreshListView({
    super.key,
    this.onRefresh,
    this.isOnStartRefresh = false,
    this.headView,
    this.refreshThreshold = 100.0,
    this.contentView,
  });

  @override
  State<PullToRefreshListView> createState() => _PullToRefreshListViewState();
}

class _PullToRefreshListViewState extends State<PullToRefreshListView> {
  final ScrollPositionNotifier _notifier = ScrollPositionNotifier();

  Timer? _hideHeaderTimer;
  ScrollPhase _previousPhase = ScrollPhase.idle;
  bool _isHoldingHeader = false;

  /// This flag is crucial. It's true only when we are animating the close.
  bool _isAnimatingClose = false;
  double _heldHeaderHeight = 0;

  @override
  void initState() {
    super.initState();
    _notifier.addListener(_handleScrollPhaseChange);
    if (mounted && widget.isOnStartRefresh) {
      setState(() {});
      // 滚动日志到底部
      WidgetsBinding.instance.addPostFrameCallback((_) {
        refreshOnStart();
      });
    };
  }

  @override
  void dispose() {
    _hideHeaderTimer?.cancel();
    _notifier.removeListener(_handleScrollPhaseChange);
    _notifier.dispose();
    super.dispose();
  }

  /// 一开始的时候就执行刷新
  void refreshOnStart() {
    setState(() {
      _heldHeaderHeight = widget.refreshThreshold ?? 100.0;
      _isHoldingHeader = true;
      _isAnimatingClose = false;
    });

    // 执行异步任务
    if (widget.onRefresh != null) {
      Future.sync(widget.onRefresh!)
          .then((_) {
            if (!mounted) return;
            setState(() {
              _isHoldingHeader = false;
              _isAnimatingClose = true;
              print(
                'onRefresh 成功执行完成，当前HeadView 状态 = ${statusText()}  _notifier.phase = ${_notifier.phase}',
              );
            });
          })
          .catchError((error, stackTrace) {
            if (!mounted) return;
            print('onRefresh 捕获错误: $error');
            setState(() {
              // Also close the header on error.
              _isHoldingHeader = false;
              _isAnimatingClose = true;
            });
          });
    } else {
      // 如果没有异步任务，添加一个定时器 让HeadView 暂留5s， 模拟刷新时HeadView暂留效果
      _hideHeaderTimer?.cancel();
      _hideHeaderTimer = Timer(const Duration(seconds: 5), () {
        if (!mounted) return;
        setState(() {
          _isHoldingHeader = false;
          _isAnimatingClose = true;
        });
      });
    }
  }

  void _handleScrollPhaseChange() {
    if (_isHoldingHeader || !mounted) {
      print(
        "正在执行刷新，无需要重复..._heldHeaderHeight = $_heldHeaderHeight  状态 = ${statusText()}",
      );

      return;
    }
    final refreshThreshold = widget.refreshThreshold ?? 100.0;

    bool canTriggerRefresh =
        _notifier.phase == ScrollPhase.ballisticUp &&
        _previousPhase == ScrollPhase.dragging &&
        !_isHoldingHeader &&
        _notifier.position.abs() > refreshThreshold;
    // print(
    //   "252-----------canTriggerRefresh = $canTriggerRefresh  _heldHeaderHeight = $_heldHeaderHeight  状态 = ${statusText()}'",
    // );
    if (canTriggerRefresh) {
      // Update the UI to show the "refreshing" state.
      setState(() {
        _heldHeaderHeight = -_notifier.position;
        if (_heldHeaderHeight > refreshThreshold) {
          _heldHeaderHeight = refreshThreshold;
        }
        _isHoldingHeader = true;
        _isAnimatingClose = false;
      });

      // 执行异步任务
      if (widget.onRefresh != null) {
        Future.sync(widget.onRefresh!)
            .then((_) {
              if (!mounted) return;
              setState(() {
                _isHoldingHeader = false;
                _isAnimatingClose = true;
                print(
                  'onRefresh 成功执行完成，当前HeadView 状态 = ${statusText()}  _notifier.phase = ${_notifier.phase}',
                );
              });
            })
            .catchError((error, stackTrace) {
              if (!mounted) return;
              print('onRefresh 捕获错误: $error');
              setState(() {
                // Also close the header on error.
                _isHoldingHeader = false;
                _isAnimatingClose = true;
              });
            });
      } else {
        // 如果没有异步任务，添加一个定时器 让HeadView 暂留5s， 模拟刷新时HeadView暂留效果
        _hideHeaderTimer?.cancel();
        _hideHeaderTimer = Timer(const Duration(seconds: 5), () {
          if (!mounted) return;
          setState(() {
            _isHoldingHeader = false;
            _isAnimatingClose = true;
          });
        });
      }
    }

    // If user starts dragging again while refreshing/closing, cancel the process.
    if (_notifier.phase == ScrollPhase.dragging) {
      if (_isHoldingHeader || _isAnimatingClose) {
        _hideHeaderTimer?.cancel();
        setState(() {
          _isHoldingHeader = false;
          _isAnimatingClose = false;
        });
      }
    }

    _previousPhase = _notifier.phase;
  }

  String statusText() {
    if (_isHoldingHeader) {
      return '模拟刷新中...';
    }
    if (_isAnimatingClose) {
      return '刷新完成';
    }
    switch (_notifier.phase) {
      case ScrollPhase.ballistic:
        return '回弹中';
      case ScrollPhase.ballisticUp:
        return '向上回弹中';
      case ScrollPhase.ballisticDown:
        return '向下回弹中';
      case ScrollPhase.settling:
        return '回弹结束';
      case ScrollPhase.idle:
        return '静止';
      case ScrollPhase.dragging:
        return _notifier.direction == ScrollDirection.down ? '下拉中' : '上推中';
    }
  }

  Widget _buildHeaderView() {
    if (widget.headView == null) {
      return Text(
        'Position: ${_notifier.position.toStringAsFixed(2)}\n'
        'Status: ${statusText()}',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 18),
      );
    }
    return widget.headView!;
  }

  ScrollBehaviorBuilder get _scrollBehaviorBuilder =>
      PullToRefreshListView.defaultScrollBehaviorBuilder;

  Widget _buildContentListView() {
    if (widget.contentView == null) {
      return ListView.builder(
        physics: NotifyingBouncingScrollPhysics(
          notifier: _notifier,
          parent: const AlwaysScrollableScrollPhysics(),
        ),
        itemCount: 50,
        itemBuilder: (_, i) => ListTile(title: Text('Item $i')),
      );
    }

    NotifyingBouncingScrollPhysics physics = NotifyingBouncingScrollPhysics(
      notifier: _notifier,
      parent: const AlwaysScrollableScrollPhysics(),
    );

    Widget child = ScrollConfiguration(
      behavior: _scrollBehaviorBuilder(physics),
      child: widget.contentView!,
    );
    return child;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _notifier,
          builder: (context, child) {
            double headViewHeight;

            if (_isHoldingHeader) {
              headViewHeight = _heldHeaderHeight;
            } else if (_isAnimatingClose) {
              // Target for the closing animation
              headViewHeight = 0;
            } else {
              // Normal drag behavior
              final scrollValue = _notifier.position;
              headViewHeight = 0;
              if (scrollValue < 0) {
                headViewHeight = -scrollValue;
              }
              if (headViewHeight > (widget.refreshThreshold ?? 100.0)) {
                headViewHeight = widget.refreshThreshold ?? 100.0;
              }
            }
            if (headViewHeight < 0) {
              headViewHeight = 0;
            }
            // By using AnimatedContainer and dynamically changing the duration,
            // we get animation only when we want it.
            return AnimatedContainer(
              duration: _isAnimatingClose
                  ? const Duration(milliseconds: 300) // Animate when closing
                  : Duration.zero, // No animation during drag
              curve: Curves.easeOut,
              height: headViewHeight,
              onEnd: () {
                // Reset the flag after the animation is done
                if (_isAnimatingClose) {
                  setState(() {
                    _isAnimatingClose = false;
                  });
                }
              },
              color: Colors.yellow,
              alignment: Alignment.center,
              child: _buildHeaderView(),
            );
          },
        ),
        Expanded(
          // child: ListView.builder(
          //   physics: NotifyingBouncingScrollPhysics(
          //     notifier: _notifier,
          //     parent: const AlwaysScrollableScrollPhysics(),
          //   ),
          //   itemCount: 50,
          //   itemBuilder: (_, i) => ListTile(title: Text('Item $i')),
          // ),
          child: _buildContentListView(),
        ),
      ],
    );
  }
}
