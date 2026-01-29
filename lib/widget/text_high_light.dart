import 'package:flutter/cupertino.dart';

/// Author: Rambo.Liu
/// Date: 2026/1/28 17:02
/// @Copyright by ZYQL Since 2025
/// Description: 文本高亮组件
class TextHighlight extends StatefulWidget {
  final TextStyle _ordinaryStyle; //普通的样式
  final TextStyle _highlightStyle; //高亮的样式
  final String _content; //文本内容
  final String _searchContent; //搜索的内容

  const TextHighlight(this._content, this._searchContent, this._ordinaryStyle,
      this._highlightStyle,
      {super.key});

  @override
  State<TextHighlight> createState() => _TextHighlightState();
}

class _TextHighlightState extends State<TextHighlight> {
  late TextSpan _textSpan;

  @override
  void initState() {
    super.initState();
    _updateTextSpan();
  }

  /// 当组件发生变化时才更新文本逻辑，提升性能
  @override
  void didUpdateWidget(TextHighlight oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget._content != oldWidget._content ||
        widget._searchContent != oldWidget._searchContent ||
        widget._ordinaryStyle != oldWidget._ordinaryStyle ||
        widget._highlightStyle != oldWidget._highlightStyle) {
      // No need to call setState, as didUpdateWidget is called before build.
      _updateTextSpan();
    }
  }

  void _updateTextSpan() {
    //搜索内容为空
    if (widget._searchContent.isEmpty) {
      _textSpan = TextSpan(text: widget._content, style: widget._ordinaryStyle);
      return;
    }
    List<TextSpan> richList = [];
    int start = 0;
    int end;

    //遍历，进行多处高亮
    while ((end = widget._content.indexOf(widget._searchContent, start)) != -1) {
      // Add non-highlighted part
      if (end > start) {
        richList.add(TextSpan(
            text: widget._content.substring(start, end), style: widget._ordinaryStyle));
      }
      //高亮内容
      richList.add(TextSpan(text: widget._searchContent, style: widget._highlightStyle));
      //赋值索引
      start = end + widget._searchContent.length;
    }
    
    // Add remaining part
    if (start < widget._content.length) {
      richList.add(TextSpan(
          text: widget._content.substring(start, widget._content.length),
          style: widget._ordinaryStyle));
    }

    _textSpan = TextSpan(children: richList);
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: _textSpan,
    );
  }
}
