import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Author: Rambo.Liu
/// Date: 2025/12/29 10:20
/// @Copyright by JYXC Since 2023
/// Description: 带有选择状态的按钮
class CheckBoxButtonChangedData<T> {
  
  final T value; // 唯一标识
  final bool isSelected; // 选中状态

  CheckBoxButtonChangedData({
    required this.value,
    required this.isSelected,
  });
}

class CheckBoxButton<T> extends StatefulWidget {
  /// 【核心】唯一标识（非展示用，用于状态管理，支持任意类型：String/int/枚举等）
  final T value;
  /// 展示文本（可动态获取，如网络/多语言）
  final String label;
  /// 初始选中状态
  final bool initialValue;
  /// 选中状态变化回调（兼容所有Dart版本）
  final ValueChanged<CheckBoxButtonChangedData<T>>? onChanged;
  /// 自定义样式（可选）
  final Color selectedBgColor;
  final Color selectedTextColor;
  final Color unselectedBgColor;
  final Color unselectedTextColor;
  final double borderRadius;
  final double fontSize;
  final EdgeInsets padding;
  final double height;

  const CheckBoxButton({
    super.key,
    required this.value, // 必传：唯一标识
    required this.label, // 必传：展示文本
    this.initialValue = false,
    this.onChanged,
    this.selectedBgColor = Colors.white,
    this.selectedTextColor = Colors.black,
    this.unselectedBgColor = const Color(0xFF4A4A4A),
    this.unselectedTextColor = Colors.white,
    this.borderRadius = 8.0,
    this.fontSize = 12.0,
    this.height = 35.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  });

  @override
  State<CheckBoxButton<T>> createState() => _CheckBoxButtonState<T>();
}

class _CheckBoxButtonState<T> extends State<CheckBoxButton<T>> {
  late bool _isSelected;

  @override
  void initState() {
    super.initState();
    _isSelected = widget.initialValue;
  }

  // 切换选中状态
  void _toggleSelected() {
    setState(() {
      _isSelected = !_isSelected;
    });
    // 修复：使用自定义模型传递参数，替代元组
    if (widget.onChanged != null) {
      widget.onChanged!(
        CheckBoxButtonChangedData<T>(
          value: widget.value,
          isSelected: _isSelected,
        ),
      );
    }
  }
  // 子组件中监听父组件传递过来的属性变化，防止父组件调用setState时，子组件未同步刷新UI
  // 组件状态更新但子组件未同步
  // 【核心修复】重写此方法以同步父组件的状态变化
  @override
  void didUpdateWidget(CheckBoxButton<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当父组件传递的 initialValue 与子组件当前的 _isSelected 状态不一致时
    if (widget.initialValue != _isSelected) {
      // 更新子组件的内部状态以匹配父组件
      setState(() {
        _isSelected = widget.initialValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _toggleSelected,
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: Container(
        height: widget.height,
        padding: widget.padding,
        decoration: BoxDecoration(
          color: _isSelected ? widget.selectedBgColor : widget.unselectedBgColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        // Use a Column for vertical centering without horizontal expansion.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // This centers the text vertically.
          children: [
            Text(
              widget.label,
              style: TextStyle(
                color: _isSelected ? widget.selectedTextColor : widget.unselectedTextColor,
                fontSize: widget.fontSize,
                fontWeight: _isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
