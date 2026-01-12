/// Author: Rambo.Liu
/// Date: 2026/1/6 15:18
/// @Copyright by JYXC Since 2023
/// Description: TODO
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import 'RefreshStatus.dart';

class CustomRefreshIndicator extends StatefulWidget {
  // 子组件（通常是列表）
  final Widget child;
  // 刷新回调函数
  final Future<void> Function() onRefresh;
  // 自定义配置
  final RefreshConfig config;
  // 自定义刷新指示器（支持外部定制UI）
  final Widget Function(double pullProgress, RefreshStatus status) indicatorBuilder;

  const CustomRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.config = const RefreshConfig(),
    this.indicatorBuilder = _CustomRefreshIndicatorState.defaultIndicatorBuilder,
  });

  @override
  State<CustomRefreshIndicator> createState() => _CustomRefreshIndicatorState();
}

class _CustomRefreshIndicatorState extends State<CustomRefreshIndicator> with SingleTickerProviderStateMixin {
  // 当前刷新状态
  RefreshStatus _status = RefreshStatus.idle;
  // 下拉偏移量
  double _pullOffset = 0.0;
  // 动画控制器（控制回弹和刷新动画）
  late AnimationController _animationController;
  // 偏移量动画
  late Animation<double> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    // 初始化动画控制器
    _animationController = AnimationController(
      vsync: this,
      duration: widget.config.bounceDuration,
    );
    // 监听动画值变化，更新偏移量
    _offsetAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    )..addListener(() {
      setState(() {
        _pullOffset = _offsetAnimation.value;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // 处理滚动通知
  bool _handleScrollNotification(ScrollNotification notification) {
    // 仅处理列表在顶部时的下拉
    if (notification is ScrollStartNotification && _status == RefreshStatus.idle) {
      setState(() {
        _status = RefreshStatus.pulling;
      });
    }

    // 监听滚动更新，计算下拉偏移量
    if (notification is ScrollUpdateNotification && _status == RefreshStatus.pulling) {
      // 仅处理向下滚动且列表已到顶部的情况
      if (notification.scrollDelta! < 0 && notification.metrics.extentBefore == 0) {
        setState(() {
          // 阻尼系数，避免下拉过快（提升交互体验）
          _pullOffset += notification.scrollDelta! * -0.5;
          // 限制最大偏移量
          _pullOffset = _pullOffset.clamp(0.0, widget.config.triggerDistance * 2);
        });
      }
    }

    // 处理滚动结束
    if (notification is ScrollEndNotification && _status == RefreshStatus.pulling) {
      _handlePullEnd();
    }

    return false;
  }

  // 处理下拉结束逻辑
  void _handlePullEnd() {
    if (_pullOffset >= widget.config.triggerDistance) {
      // 触发刷新
      _startRefresh();
    } else {
      // 未触发刷新，回弹至初始位置
      _resetPullOffset();
    }
  }

  // 开始刷新
  Future<void> _startRefresh() async {
    setState(() {
      _status = RefreshStatus.refreshing;
      // 刷新时将偏移量固定到指示器高度
      _pullOffset = widget.config.indicatorHeight;
    });

    try {
      // 执行刷新回调
      await widget.onRefresh();
      setState(() {
        _status = RefreshStatus.completed;
      });
    } catch (e) {
      // 捕获异常，避免组件崩溃
      debugPrint("刷新失败：$e");
      setState(() {
        _status = RefreshStatus.completed;
      });
    } finally {
      // 刷新完成后回弹
      await Future.delayed(widget.config.refreshDuration);
      _resetPullOffset();
    }
  }

  // 重置偏移量（回弹）
  void _resetPullOffset() {
    _offsetAnimation = Tween<double>(
      begin: _pullOffset,
      end: 0.0,
    ).animate(_animationController);
    _animationController.reset();
    _animationController.forward().whenComplete(() {
      setState(() {
        _status = RefreshStatus.idle;
        _pullOffset = 0.0;
      });
    });
  }

  // 默认指示器构建函数
  static Widget defaultIndicatorBuilder(double pullProgress, RefreshStatus status) {
    final progress = pullProgress.clamp(0.0, 1.0);
    return Center(
      child: Container(
        height: 60,
        alignment: Alignment.center,
        child: status == RefreshStatus.refreshing
            ? const CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        )
            : Icon(
          Icons.arrow_downward,
          color: Colors.blue,
          size: 24 + progress * 8,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 计算下拉进度（0-1）
    final pullProgress = (_pullOffset / widget.config.triggerDistance).clamp(0.0, 1.0);

    return Stack(
      children: [
        // 刷新指示器（根据偏移量定位）
        Positioned(
          top: _pullOffset - widget.config.indicatorHeight,
          left: 0,
          right: 0,
          child: widget.indicatorBuilder(pullProgress, _status),
        ),
        // 列表内容（通过Transform实现下拉位移）
        Transform.translate(
          offset: Offset(0, _pullOffset),
          child: NotificationListener<ScrollNotification>(
            onNotification: _handleScrollNotification,
            child: widget.child,
          ),
        ),
      ],
    );
  }
}

