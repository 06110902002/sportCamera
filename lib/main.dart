import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sport_camera/pages/clip_page.dart';
import 'package:sport_camera/pages/home/edit_page.dart';
import 'package:sport_camera/widget/common_popup_template.dart';
import 'package:sport_camera/widget/red_point.dart';
import 'pages/home/home_page.dart';
import 'pages/album_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
      ),
      home: const MainTabPage(),
    );
  }
}

class MainTabPage extends StatefulWidget {
  const MainTabPage({super.key});

  @override
  State<MainTabPage> createState() => _MainTabPageState();
}

class _MainTabPageState extends State<MainTabPage> {
  int _currentIndex = 0;
  int _myPageNotificationCount = 3;
  late CommonPopupTemplate _activityPopup;


  late final List<Widget> _pages = [
    const HomePage(),
    const AlbumPage(
      topTabs: ['相机文件', '已下载'],
      subTabs: ['回忆', '全部', '收藏', '视频', '照片', '实况'],
    ),
    ClipPage(), // 相机
    const EditPage(), // 剪辑
    const Placeholder(), // 我的
  ];

  @override
  void initState() {
    super.initState();
    _iniActivityPopups();
    // 进入页面自动显示活动弹窗
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _activityPopup.show();
    });
  }
  void _iniActivityPopups() {
    // 1. 活动弹窗
    _activityPopup = CommonPopupTemplate(
      context: context,
      contentWidget: LeicaChallengePopup(
        onSubmit: () {
          _activityPopup.dismiss();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("跳转至投稿页面")));
        },
      ),
      onClose: () => debugPrint("活动弹窗关闭"),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _activityPopup.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        children: [
          BottomNavigationBar(
            backgroundColor: _currentIndex == 1 ? Colors.black : null,
            currentIndex: _currentIndex,
            type: BottomNavigationBarType.fixed, //根据BottomNavigationBarItem 个数均分宽度，必加
            selectedItemColor: Colors.orange,
            unselectedItemColor: _currentIndex == 1 ? Colors.white70 : Colors.grey,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: [
              const BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
              const BottomNavigationBarItem(icon: Icon(Icons.photo_library), label: '相册'),
              // 中间项：空组件 占位用，高度=默认高度，彻底锁死导航栏高度【重中之重】
              BottomNavigationBarItem(icon: SizedBox.shrink(), label: ''),
              const BottomNavigationBarItem(icon: Icon(Icons.cut), label: '剪辑'),
              BottomNavigationBarItem(
                icon: RedPoint(
                  notificationCount: _myPageNotificationCount,
                  isSelected: _currentIndex == 4,
                ),
                label: '我的',
              ),
            ],
          ),

          //将这个组件移到和占位的组件位置处 就可以，解决调整自身大小，不影响BottomNavigationBar 高度的问题了
          // 因为BottomNavigationBar 是根据BottomNavigationBarItem 高度进行自适应的，所以一旦BottomNavigationBar
          // 高度发生变化，势必会影响BottomNavigationBar的高度，这个方案可以完美解决
          Positioned(
            left: 0,
            right: 0,
            bottom: Platform.isIOS ? 42 : 25, // 由于各平台底部导航栏高度不一致，此处需要特殊处理
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _currentIndex = 2;
                });
              },
              child: const CircleAvatar(
                radius: 22,
                backgroundColor: Colors.yellow,
                child: Icon(Icons.camera_alt, color: Colors.black, size: 22),
              ),
            ),
          ),
        ]
      )
    );
  }
}
