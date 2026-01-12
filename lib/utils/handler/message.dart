import 'dart:ui';

import 'package:flutter/material.dart';

import 'dart_handler.dart';

/// Author: Rambo.Liu
/// Date: 2026/1/12 14:03
/// @Copyright by JYXC Since 2023
/// Description: 消息相关类

/// 消息优先级
enum MessagePriority { low, normal, high, urgent }

extension MessagePriorityExtension on MessagePriority {
  Color get color {
    switch (this) {
      case MessagePriority.low:
        return Colors.grey;
      case MessagePriority.normal:
        return Colors.blue;
      case MessagePriority.high:
        return Colors.orange;
      case MessagePriority.urgent:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (this) {
      case MessagePriority.low:
        return Icons.low_priority;
      case MessagePriority.normal:
        return Icons.schedule;
      case MessagePriority.high:
        return Icons.priority_high;
      case MessagePriority.urgent:
        return Icons.warning;
    }
  }

  String get displayName {
    switch (this) {
      case MessagePriority.low:
        return '低';
      case MessagePriority.normal:
        return '普通';
      case MessagePriority.high:
        return '高';
      case MessagePriority.urgent:
        return '紧急';
    }
  }

  int get weight {
    switch (this) {
      case MessagePriority.low:
        return 1;
      case MessagePriority.normal:
        return 2;
      case MessagePriority.high:
        return 3;
      case MessagePriority.urgent:
        return 4;
    }
  }
}

/// 消息状态
enum MessageState {
  pending, // 等待中
  ready, // 准备就绪
  processing, // 处理中
  completed, // 已完成
  cancelled, // 已取消
}


/// 消息基类
abstract class Message {
  final String id;
  final MessagePriority priority;
  final DateTime timestamp;
  final Map<String, dynamic>? extra;
  MessageState _state = MessageState.pending;

  Message({
    required this.id,
    this.priority = MessagePriority.normal,
    DateTime? timestamp,
    this.extra,
  }) : timestamp = timestamp ?? DateTime.now();

  MessageState get state => _state;

  bool get isReadyForExecution => _state == MessageState.ready;

  void markReady() {
    if (_state == MessageState.pending) {
      _state = MessageState.ready;
    }
  }

  void markProcessing() {
    _state = MessageState.processing;
  }

  void markCompleted() {
    _state = MessageState.completed;
  }

  void markCancelled() {
    _state = MessageState.cancelled;
  }

  Future<void> execute();

  @override
  String toString() {
    return 'Message(id: $id, priority: $priority, state: $_state)';
  }
}

/// 普通任务消息
class TaskMessage extends Message {
  final Future<void> Function() task;
  final String description;

  TaskMessage({
    required String id,
    required this.task,
    required this.description,
    MessagePriority priority = MessagePriority.normal,
    DateTime? timestamp,
    Map<String, dynamic>? extra,
  }) : super(id: id, priority: priority, timestamp: timestamp, extra: extra);

  @override
  Future<void> execute() async {
    markProcessing();
    await task();
    markCompleted();
  }
}

/// 延迟消息
class DelayedMessage extends TaskMessage {
  final Duration delay;

  DelayedMessage({
    required String id,
    required Future<void> Function() task,
    required String description,
    required this.delay,
    MessagePriority priority = MessagePriority.normal,
    Map<String, dynamic>? extra,
  }) : super(
    id: id,
    task: task,
    description: description,
    priority: priority,
    extra: extra,
  );
}
