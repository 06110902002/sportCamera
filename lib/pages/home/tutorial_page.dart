import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sport_camera/pages/search_page.dart';

import 'home_page.dart';
import 'model/feed_item.dart';

// Sliver 是否已经吸顶回调器
typedef OnScrollPinedChanged = void Function(bool isPined);

class TutorialPage extends StatefulWidget {
  final OnScrollPinedChanged? onScrollPinedChanged;

  const TutorialPage({super.key, this.onScrollPinedChanged});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

const double bannerHeight = 240.0;

class _TutorialPageState extends State<TutorialPage>
    with TickerProviderStateMixin {
  //列表滚动监听器
  final ScrollController _scrollController = ScrollController();
  // 用于跟踪吸顶状态，避免重复回调
  bool _isPinned = false;

  // --- State moved from delegate to here ---
  String _dropdownValue = "X4 Air";
  final TextEditingController _searchController = TextEditingController();
  // -----------------------------------------

  //基础入门 tabbar
  late TabController _basicTabController;
  final List<String> _basicTabs = ["新手入门", "配件使用", "云服务"];
  final List<String> _tutorials = [
    '从开箱到创作，快速上手第一步',
    '从开机到成片，零基础秒懂！',
    '拍好人像与日常，参数设置指南',
  ];

  //核心功能探索 tabbar
  late TabController _coreTabController;
  final List<String> _coreTabs = ["拍摄玩法", "剪辑使用"];

  final List<FeedItem> _feedList = [
    FeedItem(
      imageUrl: 'https://picsum.photos/id/20/800/300',
      title: '女友出片秘籍，拍照从此不翻车',
      author: '@饼子Vibes',
    ),
    FeedItem(
      imageUrl: 'https://picsum.photos/id/10/800/300',
      title: '新年出大片｜最佳骑行视角',
      author: '@乔乔行记',
    ),
    FeedItem(
      imageUrl: 'https://picsum.photos/id/30/800/300',
      title: '拍出新意｜跨年创意骑行视角',
      author: '@蜗牛卷素材',
    ),
    FeedItem(
      imageUrl: 'https://picsum.photos/id/21/800/300',
      title: 'ND滤镜速成摩托大片',
      author: '@虹小橙',
    ),
    FeedItem(
      imageUrl: 'https://picsum.photos/id/40/800/300',
      title: '子弹延时\n解锁冬日美景',
      author: '@星小橙',
    ),
    FeedItem(
      imageUrl: 'https://picsum.photos/id/60/800/300',
      title: '元旦聚餐\n轻松出片',
      author: '@饼子Vibes',
    ),
  ];
  //剪辑使用
  final List<FeedItem> _editFeedList = [
    FeedItem(
      imageUrl: 'https://picsum.photos/id/40/800/300',
      title: '子弹延时\n解锁冬日美景',
      author: '@星小橙',
    ),
    FeedItem(
      imageUrl: 'https://picsum.photos/id/60/800/300',
      title: '元旦聚餐\n轻松出片',
      author: '@饼子Vibes',
    ),
  ];
  late int coreCurSelectIdx;

  @override
  void initState() {
    super.initState();
    // No need to add a listener to the scroll controller for this logic
    _basicTabController = TabController(
      length: _basicTabs.length,
      vsync: this,
      initialIndex: 0,
    );

    _coreTabController = TabController(
      length: _coreTabs.length,
      vsync: this,
      initialIndex: 0,
    );
    coreCurSelectIdx = _coreTabController.index;
    _coreTabController.addListener(() {
      coreCurSelectIdx = _coreTabController.index;
      print("116-----------index = $coreCurSelectIdx");
      if (!_coreTabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose(); // Dispose the controller
    _basicTabController.dispose();
    _coreTabController.dispose();
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
            const SliverToBoxAdapter(child: TutorialBanner()),

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
            // 2. 基础入门区域
            SliverToBoxAdapter(child: _buildBasicSection()),
            // 3. 核心功能探索区域（网格布局）
            SliverToBoxAdapter(child: _buildCoreSection()),

            // 内容列表
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return Container(
                  height: 120,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
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
              }, childCount: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicSection() {
    return NotificationListener<OverscrollNotification>(
      onNotification: _basicTabHandleOverscroll,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "基础入门",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text("更多 >", style: TextStyle(color: Colors.grey[500])),
              ],
            ),
          ),
          _buildBasicTabBar(context),
          SizedBox(
            height: 200,
            child: TabBarView(
              controller: _basicTabController,
              children: _basicTabs.map((e) => _buildBasicContent(e)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// 基础入门tabbar
  Widget _buildBasicTabBar(BuildContext context) {
    return Container(
      height: 30,
      //margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: TabBar(
              controller: _basicTabController,
              isScrollable: true,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600, // 选中加粗
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(25.0), // 圆角半径
                color: Colors.yellow, // 选中标签背景颜色
              ), // Box 设置为空可以隐藏底部横线
              // indicator: const UnderlineTabIndicator(
              //   borderSide: BorderSide(
              //     width: 3,
              //     color: Color(0xFFFFD400), // Insta360 黄
              //   ),
              //   insets: EdgeInsets.symmetric(horizontal: 18), // ⭐ 短线关键
              // ),
              indicatorSize: TabBarIndicatorSize.label,
              tabs: _basicTabs
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Tab(text: e),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// 基础入门内容示例
  Widget _buildBasicContent(String recommend) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListView.separated(
          physics: const NeverScrollableScrollPhysics(), // 阻止ListView自身滚动
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: _tutorials.length,
          itemBuilder: (_, i) {
            return ListTile(
              onTap: () => {print('点击教程：${_tutorials[i]}')},
              leading: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Icon(
                  Icons.play_arrow,
                  size: 16,
                  color: Colors.blue[600],
                ),
              ),
              title: Text(
                _tutorials[i],
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey[300],
              indent: 56, // 与标题对齐
              endIndent: 16,
            );
          },
        ),
      ),
    );
  }

  /// 基础tabbar 越界 → 主动切一级
  bool _basicTabHandleOverscroll(OverscrollNotification n) {
    final isFirst = _basicTabController.index == 0;
    final isLast = _basicTabController.index == _basicTabs.length - 1;

    if (n.overscroll < 0 && isFirst) {
      HomePage.tabController.animateTo(1); // 推荐
    }
    return false;
  }

  ///构建核心操作手册
  Widget _buildCoreSection() {
    final currentList = coreCurSelectIdx == 0 ? _feedList : _editFeedList;
    int grid_rows = (currentList.length / 2).ceil();
    double sigle_row_h = 154.0;
    return NotificationListener<OverscrollNotification>(
      onNotification: _careTabHandleOverscroll,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "核心功能探索",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text("更多 >", style: TextStyle(color: Colors.grey[500])),
              ],
            ),
          ),
          _buildCoreTabBar(context),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            //动态设置grid 的高度，达到自适应，外层添加动画，感受高度变化的过程
            height: sigle_row_h * grid_rows,
            //tabbarView 不会透传父布局约束
            child: TabBarView(
              controller: _coreTabController,
              children: [
                _buildCoreContent(_feedList),
                _buildCoreContent(_editFeedList),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 核心tabbar
  Widget _buildCoreTabBar(BuildContext context) {
    return Container(
      height: 44,
      //margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: TabBar(
              controller: _coreTabController,
              isScrollable: true,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600, // 选中加粗
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(25.0), // 圆角半径
                color: Colors.yellow, // 选中标签背景颜色
              ), // Box 设置为空可以隐藏底部横线
              indicatorSize: TabBarIndicatorSize.label,
              tabs: _coreTabs
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Tab(text: e),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// 核心内容示例
  Widget _buildCoreContent(List<FeedItem> items) {
    return GridView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(12), // Add padding around the grid
      physics: const NeverScrollableScrollPhysics(), // 阻止自身滚动
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2列
        crossAxisSpacing: 10, // 列间距
        mainAxisSpacing: 10, // 行间距
        //在我们之前的 GridView 例子中，GridView 会根据 crossAxisCount（2 列）和 childAspectRatio（0.75）计算出每一个网格项（我们的 _FeedCard）的可用空间。
        // 假设屏幕宽度是 400，那么每个卡片的宽度大约是 (400 - 间距) / 2，高度则由宽度乘以 0.75 得出。
        // 这个计算出的尺寸就是父容器（GridView的网格单元）施加给子组件（_FeedCard）的最大宽度和高度
        childAspectRatio: 1.25, // 宽高比
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _FeedCard(item: item);
      },
    );
  }

  /// 核心tabbar 越界 → 主动切一级
  bool _careTabHandleOverscroll(OverscrollNotification n) {
    final isFirst = _coreTabController.index == 0;
    final isLast = _coreTabController.index == _coreTabs.length - 1;

    if (n.overscroll < 0 && isFirst) {
      HomePage.tabController.animateTo(1); // 推荐
    }
    return false;
  }
}

class _FeedCard extends StatelessWidget {
  final FeedItem item;

  const _FeedCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias, // Clip content to rounded corners
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8), // Add rounded corners
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  item.imageUrl,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  left: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '影石Insta360',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.author,
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text(
              item.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
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
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
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
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: const Color(0xFFF6F7F9),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          // 设备选择下拉菜单
          DropdownButton<String>(
            value: dropdownValue,
            items: ["X4 Air", "X3", "One X3"].map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            onChanged: onDropdownChanged,
            underline: const SizedBox.shrink(), // 隐藏下拉线
            icon: Icon(
              Icons.arrow_drop_down,
              size: 20,
              color: Colors.grey[600],
            ),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: searchController,
              readOnly: true, // 设置为只读，防止弹出键盘
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchPage()),
                );
              },
              decoration: InputDecoration(
                hintText: '搜索教程',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(
                  Icons.search,
                  size: 20,
                  color: Colors.grey[500],
                ),
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
