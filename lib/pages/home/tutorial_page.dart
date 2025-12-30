import 'dart:async';
import 'package:flutter/material.dart';

// Sliver 是否已经吸顶回调器
typedef OnScrollPinedChanged = void Function(bool isPined);

class TutorialPage extends StatefulWidget {
  final OnScrollPinedChanged? onScrollPinedChanged;

  const TutorialPage({super.key, this.onScrollPinedChanged});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

const double bannerHeight = 240.0;

class _TutorialPageState extends State<TutorialPage> {
  //列表滚动监听器
  final ScrollController _scrollController = ScrollController();
  // 用于跟踪吸顶状态，避免重复回调
  bool _isPinned = false;

  // --- State moved from delegate to here ---
  String _dropdownValue = "X4 Air";
  final TextEditingController _searchController = TextEditingController();
  // -----------------------------------------

  @override
  void initState() {
    super.initState();
    // No need to add a listener to the scroll controller for this logic
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose(); // Dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topOffset = MediaQuery.of(context).padding.top;
    return NotificationListener<ScrollUpdateNotification>(
        onNotification: (notification) {
          // 计算当前是否应该吸顶
          //在状态发生变化（即从“未吸顶”变为“已吸顶”，或反之）的那一刻，才触发一次回调,提升性能
          final bool shouldBePinned = _scrollController.offset >= bannerHeight;
          // 仅当吸顶状态发生变化时才触发回调
          if (shouldBePinned != _isPinned) {
            _isPinned = shouldBePinned;
            widget.onScrollPinedChanged?.call(_isPinned);
            print('吸顶状态改变: $_isPinned');
          }
          return false;
        },
        child: Container(
          color: const Color(0xFFF6F7F9),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // 这个占位 Sliver 的高度就等于您希望预留出的空间（即 AppBar + 状态栏的高度）。
              SliverPersistentHeader(
                pinned: true,
                delegate: _DummyHeaderDelegate(height: topOffset),
              ),

              // 顶部 Banner
              SliverToBoxAdapter(
                child: TutorialBanner(),
              ),

              // 吸顶搜索栏 (This will now stick below the dummy header)
              SliverPersistentHeader(
                pinned: true,
                delegate: _SearchBarDelegate(
                  dropdownValue: _dropdownValue,
                  searchController: _searchController,
                  onDropdownChanged: (newValue) {
                    if (newValue != null) {
                      setState(() {
                        _dropdownValue = newValue;
                      });
                    }
                  },
                ),
              ),

              // 内容列表
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    return Container(
                      height: 120,
                      margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '教程内容 Item $index',
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  },
                  childCount: 20,
                ),
              ),
            ],
          ),
        ));
  }
}

// This delegate creates the invisible placeholder with the correct height.
class _DummyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;

  _DummyHeaderDelegate({required this.height});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(height: height);
  }

  @override
  bool shouldRebuild(covariant _DummyHeaderDelegate oldDelegate) {
    return oldDelegate.height != height;
  }
}

/* ============================================================
 * 搜索栏（吸顶）
 * ============================================================ */

class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final String dropdownValue;
  final TextEditingController searchController;
  final ValueChanged<String?> onDropdownChanged;

  _SearchBarDelegate({
    required this.dropdownValue,
    required this.searchController,
    required this.onDropdownChanged,
  });

  @override
  double get minExtent => 64;

  @override
  double get maxExtent => 64;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFFF6F7F9),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          // 设备选择下拉菜单
          DropdownButton<String>(
            value: dropdownValue,
            items: ["X4 Air", "X3", "One X3"].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: onDropdownChanged,
            underline: const SizedBox.shrink(), // 隐藏下拉线
            icon: Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey[600]),
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: '搜索教程',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey[500]),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                ),
              ),
            ),
          ),
          // 收藏按钮
          IconButton(
            icon: const Icon(Icons.star_border),
            onPressed: () {
              debugPrint('点击收藏');
            },
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _SearchBarDelegate oldDelegate) {
    // Rebuild only when the state that affects this delegate changes.
    return dropdownValue != oldDelegate.dropdownValue ||
        searchController != oldDelegate.searchController ||
        onDropdownChanged != oldDelegate.onDropdownChanged;
  }
}

/* ============================================================
 * Banner（PageView 真分页 + 无限轮播）
 * ============================================================ */

class TutorialBanner extends StatefulWidget {
  const TutorialBanner({super.key});

  @override
  State<TutorialBanner> createState() => _TutorialBannerState();
}

class _TutorialBannerState extends State<TutorialBanner> {
  late final PageController _pageController;
  Timer? _timer;

  static const int _realCount = 3;
  static const int _initialPage = 1000;

  int _currentIndex = 0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.86,
      initialPage: _initialPage,
    );
    _startAuto();
  }

  void _startAuto() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_pageController.hasClients || _isDragging) return;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _stopAuto() {
    _timer?.cancel();
    _timer = null;
  }

  void _resumeAutoLater() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) _startAuto();
    });
  }

  int _mapIndex(int page) => page % _realCount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: bannerHeight,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification &&
                  notification.dragDetails != null) {
                _isDragging = true;
                _stopAuto();
              } else if (notification is ScrollEndNotification) {
                _isDragging = false;
                _resumeAutoLater();
              }
              return false;
            },
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (page) {
                setState(() {
                  _currentIndex = _mapIndex(page);
                });
              },
              itemBuilder: (context, page) {
                final index = _mapIndex(page);
                return _BannerItem(index: index);
              },
            ),
          ),

          // 指示点
          Positioned(
            bottom: 12,
            child: Row(
              children: List.generate(_realCount, (i) {
                final active = i == _currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 12 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: active
                        ? Colors.black
                        : Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _stopAuto();
    _pageController.dispose();
    super.dispose();
  }
}

/* ============================================================
 * 单个 Banner Item
 * ============================================================ */

class _BannerItem extends StatelessWidget {
  final int index;

  const _BannerItem({required this.index});

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFFB3D9F2),
      const Color(0xFFDCE8F7),
      const Color(0xFFEAF1FA),
    ];

    return GestureDetector(
      onTap: () {
        debugPrint('点击 Banner index = $index');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: colors[index],
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(20),
          child: const Text(
            'Insta360 教程\n素材画面调节指南',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}