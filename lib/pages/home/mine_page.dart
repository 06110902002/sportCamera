import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sport_camera/provider/auth_model.dart';

/// Author: Rambo.Liu
/// Date: 2026/1/19 19:24
/// @Copyright by JYXC Since 2023
/// Description: 首页我的页面

typedef OnClickCallback = void Function();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: '個人主頁',
      home: ProfilePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with TickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  bool _isAppBarCollapsed = false;

  // 1. Add state variable for the background image file
  File? _backgroundImageFile;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    const double expandedHeight = 280.0;
    const double collapsedToolbarHeight = kToolbarHeight;
    if (!_scrollController.hasClients) return;
    final bool isCollapsed = _scrollController.offset > (expandedHeight - collapsedToolbarHeight - 20);
    if (isCollapsed != _isAppBarCollapsed) {
      setState(() {
        _isAppBarCollapsed = isCollapsed;
      });
    }
  }

  // 2. Modified method to show an action sheet for image source selection
  Future<void> _pickAndSetBackgroundImage() async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            child: const Text('拍摄'),
            onPressed: () {
              Navigator.pop(context);
              _getImage(ImageSource.camera);
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('从相册选择'),
            onPressed: () {
              Navigator.pop(context);
              _getImage(ImageSource.gallery);
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('取消'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  // Helper method to get the image from a given source
  Future<void> _getImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      setState(() {
        _backgroundImageFile = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const double expandedHeight = 280.0;
    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar(
                expandedHeight: expandedHeight,
                pinned: true,
                backgroundColor: _isAppBarCollapsed ? Colors.white : Colors.transparent,
                surfaceTintColor: Colors.transparent,
                //当有其他内容从 SliverAppBar 的“下方”滚过时，SliverAppBar 会自动添加一个阴影，来在视觉上和下方滚动的内容分离开
                // 这个属性可以解决
                scrolledUnderElevation: 0.0, // This is the fix
                leading: BackButton(
                  color: _isAppBarCollapsed ? Colors.black : Colors.white,
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: _buildAction(
                      "更换背景",
                      Icons.image,
                      click: _pickAndSetBackgroundImage,
                      color: _isAppBarCollapsed ? Colors.black : Colors.white,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: _buildAction(
                      "退出登录",
                      Icons.logout,
                      click: () {
                        context.read<AuthModel>().logout();
                      },
                      color: _isAppBarCollapsed ? Colors.black : Colors.white,
                    ),
                  )
                ],
                title: _isAppBarCollapsed
                    ? const Text('個人中心', style: TextStyle(color: Colors.black, fontSize: 18))
                    : null,
                centerTitle: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // 4. Conditionally display the background image
                      _backgroundImageFile == null
                          ? Image.network(
                              'https://picsum.photos/300/200?random=1',
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              _backgroundImageFile!,
                              fit: BoxFit.cover,
                            ),
                      Container(color: Colors.black.withOpacity(0.2)),
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircleAvatar(
                              radius: 48,
                              backgroundImage: NetworkImage('https://picsum.photos/200'),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              '劉胡來',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '分享生活点滴',
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildAction('关注', Icons.add, click: () => debugPrint('关注')),
                                const SizedBox(width: 24),
                                _buildAction('私信', Icons.message, click: () => debugPrint('私信')),
                                const SizedBox(width: 24),
                                _buildAction('更多', Icons.more_horiz, click: () => debugPrint('更多')),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _ProfileHeaderDelegate(tabController: _tabController),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: const <Widget>[
            WorksTabPage(),
            PrivateTabPage(),
            LikedTabPage(),
          ],
        ),
      ),
    );
  }

  Widget _buildAction(String label, IconData icon, {Color color = Colors.white, OnClickCallback? click}) {
    return GestureDetector(
      onTap: () {
        click?.call();
      },
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            if (label.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(label, style: TextStyle(color: color, fontSize: 12)),
            ]
          ],
        ),
      ),
    );
  }
}

class WorksTabPage extends StatelessWidget {
  const WorksTabPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: const PageStorageKey<String>('作品'),
      slivers: <Widget>[
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(child: Text('作品 $index')),
              ),
              childCount: 30,
            ),
          ),
        ),
      ],
    );
  }
}

class PrivateTabPage extends StatelessWidget {
  const PrivateTabPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: const PageStorageKey<String>('私密'),
      slivers: <Widget>[
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        const SliverFillRemaining(
          child: Center(child: Text('这里是私密内容')),
        ),
      ],
    );
  }
}

class LikedTabPage extends StatelessWidget {
  const LikedTabPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: const PageStorageKey<String>('喜欢'),
      slivers: <Widget>[
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        const SliverFillRemaining(
          child: Center(child: Text('这里是喜欢的内容')),
        ),
      ],
    );
  }
}

// 5. 大幅简化Delegate，只负责显示TabBar
class _ProfileHeaderDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;

  _ProfileHeaderDelegate({required this.tabController});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: Colors.white,
      child: TabBar(
        controller: tabController,
        tabs: const [
          Tab(text: '作品'),
          Tab(text: '私密'),
          Tab(text: '喜欢'),
        ],
        indicatorColor: Colors.black,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey,
        indicatorWeight: 2,
        indicatorSize: TabBarIndicatorSize.label,
      ),
    );
  }

  @override
  double get minExtent => kTextTabBarHeight;

  @override
  double get maxExtent => kTextTabBarHeight;

  @override
  bool shouldRebuild(covariant _ProfileHeaderDelegate oldDelegate) {
    return oldDelegate.tabController != tabController;
  }
}
