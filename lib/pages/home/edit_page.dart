/*
/// Author: Rambo.Liu
/// Date: 2026/1/12 20:07
/// @Copyright by JYXC Since 2023
/// Description: TODO
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// =======================
/// App
/// =======================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

/// =======================
/// Home Page
/// =======================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin {
  late TabController _mainTabController;

  final PageController _aiPageController = PageController();
  final PageController _themePageController = PageController();

  final ScrollController _subTabScrollController =
  ScrollController();

  final List<String> aiTabs = ["推荐", "炫酷特效", "延时", "定格", "分身","转场","创意拍摄"];
  final List<String> themeTabs = ["推荐", "AI特效", "最新", "元旦"];

  int aiIndex = 0;
  int themeIndex = 0;

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 2, vsync: this);

    /// 一级 Tab 切换时，二级 Tab 联动
    _mainTabController.addListener(() {
      if (_mainTabController.indexIsChanging) {
        setState(() {
          aiIndex = 0;
          themeIndex = 0;
        });
        _scrollSubTabToCenter(0);
      }
    });
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    _aiPageController.dispose();
    _themePageController.dispose();
    _subTabScrollController.dispose();
    super.dispose();
  }

  /// 二级 Tab 点击
  void _onSubTabTap(int index) {
    final isAi = _mainTabController.index == 0;

    if (isAi) {
      _aiPageController.jumpToPage(index);
      aiIndex = index;
    } else {
      _themePageController.jumpToPage(index);
      themeIndex = index;
    }

    setState(() {});
    _scrollSubTabToCenter(index);
  }

  /// PageView 滑动同步二级 Tab
  void _onPageChanged(int index) {
    final isAi = _mainTabController.index == 0;

    setState(() {
      if (isAi) {
        aiIndex = index;
      } else {
        themeIndex = index;
      }
    });

    _scrollSubTabToCenter(index);
  }

  /// 二级 Tab 自动居中
  void _scrollSubTabToCenter(int index) {
    const itemWidth = 80.0;
    final screenWidth = MediaQuery.of(context).size.width;

    final offset =
        index * itemWidth - screenWidth / 2 + itemWidth / 2;

    _subTabScrollController.animateTo(
      offset.clamp(
        0,
        _subTabScrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          const SliverAppBar(
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.white,
          ),

          /// 第一行 + 第二行
          SliverToBoxAdapter(
            child: Column(
              children: const [
                _FirstRow(),
                SizedBox(height: 16),
                _SecondRow(),
                SizedBox(height: 16),
              ],
            ),
          ),

          /// ⭐ 一级 + 二级 Tab 一起吸顶
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabHeaderDelegate(
              mainTabController: _mainTabController,
              aiTabs: aiTabs,
              themeTabs: themeTabs,
              aiIndex: aiIndex,
              themeIndex: themeIndex,
              scrollController: _subTabScrollController,
              onSubTabTap: _onSubTabTap,
            ),
          ),
        ],

        /// 一级内容
        body: TabBarView(
          controller: _mainTabController,
          children: [
            _AiPage(
              controller: _aiPageController,
              tabs: aiTabs,
              onPageChanged: _onPageChanged,
            ),
            _ThemePage(
              controller: _themePageController,
              tabs: themeTabs,
              onPageChanged: _onPageChanged,
            ),
          ],
        ),
      ),
    );
  }
}

const double kSecondTabBarHeight = 60.0;


/// =======================
/// Sliver Header（一级 + 二级 Tab）
/// =======================
class _TabHeaderDelegate extends SliverPersistentHeaderDelegate {
  final TabController mainTabController;
  final List<String> aiTabs;
  final List<String> themeTabs;
  final int aiIndex;
  final int themeIndex;
  final ScrollController scrollController;
  final ValueChanged<int> onSubTabTap;

  _TabHeaderDelegate({
    required this.mainTabController,
    required this.aiTabs,
    required this.themeTabs,
    required this.aiIndex,
    required this.themeIndex,
    required this.scrollController,
    required this.onSubTabTap,
  });

  @override
  double get minExtent => kTextTabBarHeight + kSecondTabBarHeight;

  @override
  double get maxExtent => kTextTabBarHeight + kSecondTabBarHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    final isAi = mainTabController.index == 0;
    final tabs = isAi ? aiTabs : themeTabs;
    final current = isAi ? aiIndex : themeIndex;

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          TabBar(
            controller: mainTabController,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: "AI 创意库"),
              Tab(text: "主题模板"),
            ],
          ),
          _SubTabBar(
            tabs: tabs,
            current: current,
            controller: scrollController,
            onTap: onSubTabTap,
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _TabHeaderDelegate oldDelegate) =>
      true;
}

/// =======================
/// 二级 TabBar
/// =======================
class _SubTabBar extends StatelessWidget {
  final List<String> tabs;
  final int current;
  final ScrollController controller;
  final ValueChanged<int> onTap;

  const _SubTabBar({
    required this.tabs,
    required this.current,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kSecondTabBarHeight,
      child: ListView.builder(
        controller: controller,
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        itemBuilder: (_, i) {
          final selected = i == current;
          return GestureDetector(
            onTap: () => onTap(i),
            child: Container(
              width: 80,
              color: Colors.orange,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    tabs[i],
                    style: TextStyle(
                      color:
                      selected ? Colors.black : Colors.grey,
                      fontWeight:
                      selected ? FontWeight.bold : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: selected ? 24 : 0,
                    height: 3,
                    decoration: BoxDecoration(
                      color: Colors.yellow,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// =======================
/// AI Page（二级内容）
/// =======================
class _AiPage extends StatelessWidget {
  final PageController controller;
  final List<String> tabs;
  final ValueChanged<int> onPageChanged;

  const _AiPage({
    required this.controller,
    required this.tabs,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller,
      itemCount: tabs.length,
      onPageChanged: onPageChanged,
      itemBuilder: (_, page) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 20,
          itemBuilder: (_, i) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 160, color: Colors.grey[300]),
                const SizedBox(height: 8),
                Text("AI-${tabs[page]}-$i"),
                const SizedBox(height: 16),
              ],
            );
          },
        );
      },
    );
  }
}

/// =======================
/// Theme Page（二级内容）
/// =======================
class _ThemePage extends StatelessWidget {
  final PageController controller;
  final List<String> tabs;
  final ValueChanged<int> onPageChanged;

  const _ThemePage({
    required this.controller,
    required this.tabs,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller,
      itemCount: tabs.length,
      onPageChanged: onPageChanged,
      itemBuilder: (_, page) {
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 20,
          gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemBuilder: (_, i) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child:
                    Container(color: Colors.grey[300])),
                const SizedBox(height: 8),
                Text("主题-${tabs[page]}-$i"),
              ],
            );
          },
        );
      },
    );
  }
}

/// =======================
/// 第一 / 第二行组件
/// =======================
class _FirstRow extends StatelessWidget {
  const _FirstRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          ElevatedButton(
            onPressed: () {},
            child: const Text("投递活动"),
          ),
          const Spacer(),
          const Text("AI 任务", style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class _SecondRow extends StatelessWidget {
  const _SecondRow();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final leftWidth = (width - 16 * 3) / 2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: leftWidth,
            height: 100,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.yellow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text("一键成片"),
          ),
          const SizedBox(width: 16),
          SizedBox(
            height: 100,
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: const [
                _SmallBtn("开始创作"),
                _SmallBtn("草稿箱"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallBtn extends StatelessWidget {
  final String text;
  const _SmallBtn(this.text);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 42,
      child: ElevatedButton(
        onPressed: () {},
        child: Text(text),
      ),
    );
  }
}




*/

import 'package:flutter/material.dart';
import 'package:sport_camera/widget/theme_templete.dart';

import '../../widget/ai_templete.dart';

// void main() => runApp(const MyApp());
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: EditPage(),
//     );
//   }
// }

class EditPage extends StatefulWidget {
  const EditPage({super.key});
  @override
  State<EditPage> createState() => _HomePageState();
}

class _HomePageState extends State<EditPage> with TickerProviderStateMixin {
  late TabController _mainController;

  final Map<int, TabController> _subControllers = {};
  final Map<int, PageController> _subPageControllers = {};
  final Map<int, int> _subTabIndexRecord = {};

  final aiTabs = ['推荐', '炫酷特效', '延时', '定格', '分身', '转场', '创意拍摄'];
  final themeTabs = ['推荐', 'AI特效', '最新', '元旦'];

  @override
  void initState() {
    super.initState();

    _mainController = TabController(length: 2, vsync: this);

    // 初始化一级tab对应的二级tab
    _subControllers[0] = TabController(length: aiTabs.length, vsync: this);
    _subControllers[1] = TabController(length: themeTabs.length, vsync: this);

    _subPageControllers[0] = PageController();
    _subPageControllers[1] = PageController();

    _subTabIndexRecord[0] = 0;
    _subTabIndexRecord[1] = 0;

    _mainController.addListener(() {
      // We only want to act when the tab switch animation is finished.
      if (_mainController.indexIsChanging) {
        return; // Do nothing while animating.
      }

      // Now the animation is complete and we are on the new tab.
      final mainTabIndex = _mainController.index;
      final targetSubTabIndex = _subTabIndexRecord[mainTabIndex] ?? 0;
      final subController = _subControllers[mainTabIndex]!;
      final idx = _subTabIndexRecord[_mainController.index] ?? 0;
      final subPageController = _subPageControllers[_mainController.index]!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (subPageController.hasClients) {
          subPageController.jumpToPage(idx);
        }
      });
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    for (var c in _subControllers.values) {
      c.dispose();
    }
    for (var p in _subPageControllers.values) {
      p.dispose();
    }
    super.dispose();
  }

  TabController get currentSubController =>
      _subControllers[_mainController.index]!;
  PageController get currentSubPageController =>
      _subPageControllers[_mainController.index]!;

  List<String> get currentSubTabs =>
      _mainController.index == 0 ? aiTabs : themeTabs;

  @override
  Widget build(BuildContext context) {
    // 按钮样式
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.grey[200],
      foregroundColor: Colors.black,
      alignment: Alignment.centerLeft,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ), // 高度约 56
      minimumSize: const Size(double.infinity, 56),
    );
    // 使用AnimatedBuilder来监听TabController的变化
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        // 当Tab切换时，此builder会重新运行，
        // 从而让`currentSubController`获取到正确的值。
        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (_, __) => [
              //添加 SliverAppBar 可以用来控制 SliverPersistentHeader吸顶在屏幕的位置
              const SliverAppBar(
                toolbarHeight: 4.0,
                pinned: true,
                elevation: 0,
                backgroundColor: Colors.white,
              ),
              SliverToBoxAdapter(
                child: Container(
                  height: 60,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 投稿活动
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.book, size: 16, color: Colors.orange),
                            SizedBox(width: 4),
                            Text('投稿活动', style: TextStyle(fontSize: 14)),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                      // AI任务
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.star, size: 18, color: Colors.purple),
                          SizedBox(width: 4),
                          Text(
                            'AI任务',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  height: 128,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 左侧：一键成片
                      Expanded(
                        child: Container(
                          height: 128, // = 56 + 16 + 56
                          decoration: BoxDecoration(
                            color: Colors.yellow,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.auto_awesome,
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 8),
                              Text(
                                '一键成片',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // 右侧：开始创作 + 草稿箱
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () {},
                              style: buttonStyle,
                              child: const Text(
                                '开始创作',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {},
                              style: buttonStyle,

                              child: const Text(
                                '草稿箱',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              //占位
              SliverToBoxAdapter(
                child: Container(color: Colors.white, height: 20),
              ),

              SliverPersistentHeader(
                pinned: true,
                delegate: _CombinedTabHeader(
                  mainController: _mainController,
                  // 这里的`currentSubController`将永远是正确的
                  subController: currentSubController,
                  aiTabs: aiTabs,
                  themeTabs: themeTabs,
                ),
              ),
            ],
            body: TabBarView(
              controller: _mainController,
              children: [
                SecondLevelPage(
                  mainController: _mainController,
                  tabs: aiTabs,
                  tabController: _subControllers[0]!,
                  pageController: _subPageControllers[0]!,
                  onTabChanged: (idx) => _subTabIndexRecord[0] = idx,
                ),
                SecondLevelPage(
                  mainController: _mainController,
                  tabs: themeTabs,
                  tabController: _subControllers[1]!,
                  pageController: _subPageControllers[1]!,
                  onTabChanged: (idx) => _subTabIndexRecord[1] = idx,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CombinedTabHeader extends SliverPersistentHeaderDelegate {
  final TabController mainController;
  final TabController subController;
  final List<String> aiTabs;
  final List<String> themeTabs;
  final double kTopBarH = 60.0;
  final double kSubBarH = 60.0;

  _CombinedTabHeader({
    required this.mainController,
    required this.subController,
    required this.aiTabs,
    required this.themeTabs,
  });

  @override
  double get minExtent => kTopBarH + kSubBarH;
  @override
  double get maxExtent => kTopBarH + kSubBarH;

  Color _iconColor(int index) {
    return mainController.index == index ? Colors.purple : Colors.grey;
  }

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    final subTabs = mainController.index == 0 ? aiTabs : themeTabs;
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(
            height: kTopBarH,
            child: Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
                // 1. 让 TabBar 变为可滚动的，这样 Tab 的宽度会根据内容自适应
                isScrollable: true,
                //tabAlignment 属性在M2中无效,仅在m3 中生效
                //tabAlignment: TabAlignment.start,
                controller: mainController,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                dividerColor: Colors.transparent,
                tabs: [
                  Tab(
                    child: Row(
                      children: [
                        Icon(Icons.air, size: 12, color: _iconColor(0)),
                        SizedBox(width: 4),
                        Text("AI 创意库"),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      children: [
                        Icon(
                          Icons.holiday_village_outlined,
                          size: 12,
                          color: _iconColor(1),
                        ),
                        SizedBox(width: 4),
                        Text("主题模板"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(
            height: kSubBarH,
            child: Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
                isScrollable: true,
                //tabAlignment: TabAlignment.start,
                controller: subController,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                dividerColor: Colors.transparent,
                tabs: subTabs.map((e) => Tab(text: e)).toList(),
                indicatorColor: Colors.blue,
                indicatorWeight: 3,
                labelPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _CombinedTabHeader oldDelegate) => true;
}

class SecondLevelPage extends StatefulWidget {
  //一级 TabController
  final TabController mainController;
  final List<String> tabs;
  final TabController tabController;
  final PageController pageController;
  final ValueChanged<int> onTabChanged;

  const SecondLevelPage({
    super.key,
    required this.mainController,
    required this.tabs,
    required this.tabController,
    required this.pageController,
    required this.onTabChanged,
  });

  @override
  State<SecondLevelPage> createState() => _SecondLevelPageState();
}

class _SecondLevelPageState extends State<SecondLevelPage> {
  // This flag is true for the entire duration of a user-initiated scroll,
  // including the coasting animation after a fling.
  bool _isUserScrolling = false;

  @override
  void initState() {
    super.initState();
    widget.tabController.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    widget.tabController.removeListener(_handleTabSelection);
    super.dispose();
  }

  void _handleTabSelection() {
    // This function handles tab clicks from the user.
    // It should NOT run if the tab is changing because of a PageView swipe.
    // The `!_isUserScrolling` guard is the key to breaking the feedback loop.
    if (widget.tabController.indexIsChanging && !_isUserScrolling) {
      widget.pageController.animateToPage(
        widget.tabController.index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    int mainTabIndex = widget.mainController.index;
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // A user drag will trigger a ScrollStartNotification with non-null dragDetails.
        if (notification is ScrollStartNotification &&
            notification.dragDetails != null) {
          _isUserScrolling = true;
        }
        // The ScrollEndNotification is triggered when a scroll activity concludes.
        else if (notification is ScrollEndNotification) {
          _isUserScrolling = false;
        }
        // Let the notification bubble up.
        return false;
      },
      child: PageView.builder(
        controller: widget.pageController,
        itemCount: widget.tabs.length,
        onPageChanged: (index) {
          // This callback fires whenever the page changes.
          // We update the tab controller, but only if the user is the one scrolling.
          if (_isUserScrolling) {
            widget.tabController.animateTo(index);
          }
          // Always keep the parent's record of the index updated for state restoration.
          widget.onTabChanged(index);
        },
        itemBuilder: (_, index) {
          final title = widget.tabs[index];
          if (mainTabIndex == 0) {
            // return ListView.builder(
            //   padding: EdgeInsetsGeometry.fromLTRB(0, 16, 0,0),
            //   itemCount: 20,
            //   itemBuilder: (_, i) => Container(
            //     height: 80,
            //     margin: const EdgeInsets.all(10),
            //     color: Colors.blue.shade50,
            //     alignment: Alignment.center,
            //     child: Text('$title - item $i'),
            //   ),
            // );
            return AiTemplete(
              mainTabIdx: mainTabIndex,
              subTabIdx: widget.tabController.index,
            );
          } else {
            return ThemeTemplete(
              mainTabIdx: mainTabIndex,
              subTabIdx: widget.tabController.index,
            );
          }
        },
      ),
    );
  }
}
