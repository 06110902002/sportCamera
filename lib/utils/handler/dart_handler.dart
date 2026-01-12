import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sport_camera/utils/logger_util.dart';

import 'message.dart';

/// Author: Rambo.Liu
/// Date: 2026/1/12 13:55
/// @Copyright by JYXC Since 2023
/// Description: 类似Android Handler 的消息处理

/// Handler状态
enum HandlerState { idle, running, paused, stopped }

extension HandlerStateExtension on HandlerState {
  Color get color {
    switch (this) {
      case HandlerState.idle:
        return Colors.grey;
      case HandlerState.running:
        return Colors.green;
      case HandlerState.paused:
        return Colors.orange;
      case HandlerState.stopped:
        return Colors.red;
    }
  }

  String get displayName {
    switch (this) {
      case HandlerState.idle:
        return '空闲';
      case HandlerState.running:
        return '运行中';
      case HandlerState.paused:
        return '已暂停';
      case HandlerState.stopped:
        return '已停止';
    }
  }
}

/// 优化的消息队列实现
class _OptimizedMessageQueue {
  final List<Message> _messages = [];

  // 使用StreamController实现事件通知
  final StreamController<void> _notificationController =
  StreamController<void>.broadcast();
  bool _isNotifying = false;

  /// 添加消息到队列
  void add(Message message) {
    _messages.add(message);
    _sortMessages();

    // 如果有监听者，发送通知
    if (_notificationController.hasListener && !_isNotifying) {
      _isNotifying = true;
      _notificationController.add(null);
      _isNotifying = false;
    }
  }

  /// 排序消息
  void _sortMessages() {
    _messages.sort((a, b) {
      // 首先按状态排序：准备就绪的优先于等待中的
      if (a.isReadyForExecution && !b.isReadyForExecution) return -1;
      if (!a.isReadyForExecution && b.isReadyForExecution) return 1;

      // 都准备就绪或都等待中时，按优先级排序
      final priorityCompare = b.priority.weight.compareTo(a.priority.weight);
      if (priorityCompare != 0) return priorityCompare;

      // 同优先级按时间升序排序
      return a.timestamp.compareTo(b.timestamp);
    });
  }

  /// 检查是否有可执行消息
  bool hasExecutableMessage() {
    for (var message in _messages) {
      if (message.isReadyForExecution) {
        return true;
      }
    }
    return false;
  }

  /// 等待可执行消息（带超时）
  Future<bool> waitForMessage({
    Duration timeout = const Duration(seconds: 60),
  }) async {
    // 如果已经有可执行消息，直接返回
    if (hasExecutableMessage()) {
      return true;
    }

    // 等待通知
    try {
      await _notificationController.stream.first.timeout(timeout);
      return hasExecutableMessage();
    } on TimeoutException {
      return false;
    }
  }

  /// 获取下一个可执行的消息
  Message? getNextExecutableMessage() {
    for (var message in _messages) {
      if (message.isReadyForExecution) {
        return message;
      }
    }
    return null;
  }

  /// 移除消息
  bool remove(Message message) {
    final removed = _messages.remove(message);
    return removed;
  }

  /// 移除并返回下一个可执行的消息
  Message? removeNextExecutable() {
    final message = getNextExecutableMessage();
    if (message != null) {
      _messages.remove(message);
    }
    return message;
  }

  /// 清空队列
  void clear() {
    _messages.clear();
  }

  /// 获取队列长度
  int get length => _messages.length;

  /// 检查队列是否为空
  bool get isEmpty => _messages.isEmpty;

  /// 检查队列是否包含指定消息
  bool contains(Message message) {
    return _messages.contains(message);
  }

  /// 获取所有消息（用于显示）
  List<Message> getAllMessages() {
    return List.from(_messages);
  }

  /// 通知队列重新排序（当消息状态变化时调用）
  void notifyChanged() {
    _sortMessages();
    // 发送通知
    if (_notificationController.hasListener && !_isNotifying) {
      _isNotifying = true;
      _notificationController.add(null);
      _isNotifying = false;
    }
  }

  /// 销毁
  void dispose() {
    _notificationController.close();
  }
}

/// 优化的Handler消息队列
class DartHandler {
  // 消息队列
  final _OptimizedMessageQueue _messageQueue = _OptimizedMessageQueue();
  final Map<String, Message> _messageMap = {};
  final Map<String, Timer> _timerMap = {};

  // 处理任务
  Future<void>? _processingTask;
  bool _isProcessing = false;

  // 状态
  HandlerState _state = HandlerState.idle;

  // 停止标志
  bool _shouldStop = false;

  // 配置
  final bool _debugLogging;

  // 统计信息
  int _totalProcessed = 0;
  int _totalFailed = 0;
  int _totalCancelled = 0;
  final List<String> _logMessages = [];

  // 事件流
  final StreamController<void> _eventController =
  StreamController<void>.broadcast();

  DartHandler._({bool debugLogging = false}) : _debugLogging = debugLogging {
    _log('Handler初始化完成');
  }

  static DartHandler? _instance;

  static DartHandler getInstance({bool debugLogging = false}) {
    _instance ??= DartHandler._(debugLogging: debugLogging);
    return _instance!;
  }

  Stream<void> get events => _eventController.stream;

  HandlerState get state => _state;

  int get queueSize => _messageQueue.length;

  List<String> get logs => List.unmodifiable(_logMessages);

  Map<String, int> get statistics => {
    'totalProcessed': _totalProcessed,
    'totalFailed': _totalFailed,
    'totalCancelled': _totalCancelled,
    'pendingMessages': queueSize,
  };

  /// 启动
  Future<void> start() async {
    if (_state == HandlerState.running) {
      _log('Handler已经在运行中');
      return;
    }

    // if (_state == HandlerState.stopped) {
    //   throw Exception('Handler已停止，无法重新启动');
    // }

    _state = HandlerState.running;
    _shouldStop = false;
    _log('Handler启动');
    _eventController.add(null);

    // 启动异步处理循环
    _startProcessingLoop();
  }

  /// 暂停
  Future<void> pause() async {
    if (_state != HandlerState.running) return;

    _state = HandlerState.paused;
    _log('Handler已暂停');
    _eventController.add(null);
  }

  /// 恢复
  Future<void> resume() async {
    if (_state != HandlerState.paused) return;

    _state = HandlerState.running;
    _log('Handler已恢复');
    _eventController.add(null);

    // 如果处理循环没有运行，重新启动
    if (_processingTask == null) {
      _startProcessingLoop();
    }
  }

  /// 停止
  Future<void> stop() async {
    if (_state == HandlerState.stopped) return;

    _state = HandlerState.stopped;
    _shouldStop = true;
    _log('Handler正在停止...');

    // 取消所有定时器
    _cancelAllTimers();

    // 等待当前处理任务完成
    await _processingTask?.catchError((_) {});

    _log('Handler已停止');
    _eventController.add(null);
  }

  /// 发送普通任务
  Future<bool> sendTask({
    required String id,
    required Future<void> Function() task,
    required String description,
    MessagePriority priority = MessagePriority.normal,
    Map<String, dynamic>? extra,
  }) async {
    if (_state == HandlerState.stopped) {
      _log('Handler已停止，无法发送消息');
      return false;
    }

    if (_messageMap.containsKey(id)) {
      _log('消息ID重复: $id');
      return false;
    }

    final message = TaskMessage(
      id: id,
      task: task,
      description: description,
      priority: priority,
      extra: extra,
    );

    // 普通任务立即标记为可执行
    message.markReady();

    _messageQueue.add(message);
    _messageMap[id] = message;

    _log('消息已发送: $id (${priority.displayName}优先级)');
    _eventController.add(null);

    return true;
  }

  /// 发送延迟任务
  Future<bool> sendDelayedTask({
    required String id,
    required Future<void> Function() task,
    required String description,
    required Duration delay,
    MessagePriority priority = MessagePriority.normal,
    Map<String, dynamic>? extra,
  }) async {
    if (_state == HandlerState.stopped) return false;

    // if (_messageMap.containsKey(id)) {
    //   _log('消息ID重复: $id');
    //   return false;
    // }

    final message = DelayedMessage(
      id: id,
      task: task,
      description: description,
      delay: delay,
      priority: priority,
      extra: extra,
    );

    _messageQueue.add(message);
    _messageMap[id] = message;

    _log('延迟消息已发送: $id (${delay.inSeconds}秒后执行)');
    _eventController.add(null);

    // 设置延迟计时器
    _setupDelayedMessage(message);

    return true;
  }

  bool containsMessage(String id) {
    return _messageMap.containsKey(id);
  }

  void remove(String id) {
    final message = _messageMap[id];
    if (message == null) return;
    LoggerUtil.d("删除消息 $id 此时消息队列中还有 ${_messageQueue.length} 条消息");
    _messageQueue.remove(message);
    _messageMap.remove(id);

    // 取消定时器
    _timerMap[id]?.cancel();
    _timerMap.remove(id);
  }


  /// 取消消息
  Future<bool> cancelMessage(String id) async {
    final message = _messageMap[id];
    if (message == null) return false;

    _messageQueue.remove(message);
    _messageMap.remove(id);

    // 取消定时器
    _timerMap[id]?.cancel();
    _timerMap.remove(id);

    // 标记消息为已取消
    message.markCancelled();

    _totalCancelled++;
    _log('消息已取消: $id');
    _eventController.add(null);

    return true;
  }

  /// 取消所有消息
  Future<void> cancelAll() async {
    _log('取消所有消息');

    // 取消所有定时器
    _cancelAllTimers();

    // 取消所有消息
    for (var message in _messageMap.values) {
      message.markCancelled();
    }

    _messageQueue.clear();
    _messageMap.clear();

    _eventController.add(null);
  }

  /// 获取所有待处理消息
  List<Message> getPendingMessages() {
    return _messageQueue.getAllMessages();
  }

  /// 私有方法：启动处理循环
  void _startProcessingLoop() {
    if (_processingTask != null) return;

    _processingTask = _processingLoop();
  }

  /// 处理循环（混合方案：事件驱动+轻量轮询）
  Future<void> _processingLoop() async {
    _log('消息处理循环已启动');

    while (_state == HandlerState.running && !_shouldStop) {
      try {
        // 使用混合方案：
        // 1. 先检查是否有可执行消息
        // 2. 如果没有，等待一小段时间再检查
        if (_messageQueue.hasExecutableMessage()) {
          // 处理消息
          final message = _messageQueue.removeNextExecutable();
          if (message != null) {
            await _processSingleMessage(message);
          }
        } else {
          // 没有可执行消息，等待100ms再检查
          // 这比原来的100ms轮询要好，因为：
          // 1. 使用await让出CPU
          // 2. 100ms间隔足够小，响应迅速
          // 3. 避免了Completer的死锁问题
          await Future.delayed(const Duration(milliseconds: 100));
        }
      } catch (e) {
        _log('处理循环异常: $e');
        // 发生异常时暂停一下，防止快速循环出错
        await Future.delayed(const Duration(milliseconds: 1000));
      }
    }

    _log('消息处理循环已停止');
    _processingTask = null;
  }

  /// 处理单个消息
  Future<void> _processSingleMessage(Message message) async {
    _isProcessing = true;

    try {
      // 从映射表中移除
      _messageMap.remove(message.id);
      _timerMap.remove(message.id);

      _log('开始处理消息: ${message.id} (${message.priority.displayName}优先级)');

      await message.execute();

      _totalProcessed++;
      _log('消息处理完成: ${message.id}');

      _eventController.add(null);
    } catch (e) {
      _totalFailed++;
      _log('消息处理失败: $e');
      _eventController.add(null);
    } finally {
      _isProcessing = false;
    }
  }

  /// 设置延迟消息
  void _setupDelayedMessage(DelayedMessage message) {
    final timer = Timer(message.delay, () {
      if (message.state == MessageState.pending) {
        // 延迟时间到，标记消息为可执行状态
        message.markReady();
        _log('延迟消息准备就绪: ${message.id}');

        // 通知队列重新排序
        _messageQueue.notifyChanged();

        _eventController.add(null);
      }
    });

    _timerMap[message.id] = timer;
  }

  /// 取消所有定时器
  void _cancelAllTimers() {
    for (final timer in _timerMap.values) {
      timer.cancel();
    }
    _timerMap.clear();
    _log('所有定时器已取消');
  }

  /// 日志
  void _log(String message) {
    final timestamp = DateTime.now().toString().substring(11, 23);
    final logEntry = '[$timestamp] $message';

    if (_debugLogging) {
      debugPrint(logEntry);
    }

    _logMessages.add(logEntry);
    if (_logMessages.length > 50) {
      _logMessages.removeAt(0);
    }
  }

  /// 销毁
  Future<void> dispose() async {
    await stop();
    await _eventController.close();
    _messageQueue.dispose();
    _instance = null;
  }
}
