/// Author: Rambo.Liu
/// Date: 2026/1/19 10:26
/// @Copyright by JYXC Since 2023
/// Description: 通用弹窗，内容由外部定义
import 'package:flutter/material.dart';

class CommonPopupTemplate {
  late OverlayEntry _overlayEntry;
  final BuildContext context;

  // 可配置参数
  final Widget? titleWidget;
  final Widget contentWidget;
  final Widget? actionWidget;
  final double maskOpacity;
  //点击弹窗内容外，是否可关闭
  final bool barrierDismissible;
  final double popupWidth;
  final VoidCallback onClose;

  CommonPopupTemplate({
    required this.context,
    required this.contentWidget,
    required this.onClose,
    this.titleWidget,
    this.actionWidget,
    this.maskOpacity = 0.6,
    this.barrierDismissible = false,
    this.popupWidth = 310,
  }) {
    _overlayEntry = _createOverlayEntry();
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: () {
          if (barrierDismissible) {
            _dismiss();
            onClose();
          }
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black.withOpacity(maskOpacity),
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: () {}, // 阻止内容区点击穿透
            child: Material(
              // ✅✅ 核心修复1：加Material包裹 解决 No Material widget found 报错
              color: Colors.transparent, // 透明背景，不影响蒙层效果
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min, // ✅ 防溢出：自适应高度，不撑满屏幕
                children: [
                  Container(
                    width: popupWidth,
                    constraints: BoxConstraints(
                      maxHeight:
                          MediaQuery.of(context).size.height *
                          0.8, // ✅ 防溢出：最大高度80%屏幕
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      // ✅ 防溢出：内容超出自动滚动
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (titleWidget != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: titleWidget,
                            ),
                          contentWidget,
                          if (actionWidget != null) actionWidget!,
                        ],
                      ),
                    ),
                  ),
                  // 底部关闭按钮
                  GestureDetector(
                    onTap: () {
                      _dismiss();
                      onClose();
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      margin: const EdgeInsets.only(top: 20, bottom: 20),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void show() {
    Overlay.of(context).insert(_overlayEntry);
  }

  void _dismiss() {
    if (_overlayEntry.mounted) _overlayEntry.remove();
  }

  void dismiss() => _dismiss();
}

// 影石徕卡活动弹窗-快捷复用组件
class LeicaChallengePopup extends StatelessWidget {
  final VoidCallback onSubmit;
  const LeicaChallengePopup({super.key, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Column(
            children: [
              SizedBox(height: 18),
              Text(
                "影石徕卡\n全球影像挑战赛",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "2025.11.18 - 2026.2.28",
                style: TextStyle(fontSize: 12, color: Color(0xFF999999)),
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          height: 210,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: NetworkImage(
                "https://media.giphy.com/media/3o7TKsQ8UQ4l4LhG2c/giphy.gif"
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 22, 30, 20),
          child: SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.black),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: const Text(
                "立即投稿",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
