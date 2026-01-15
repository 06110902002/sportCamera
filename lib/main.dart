import 'package:flutter/material.dart';
import 'package:sport_camera/pages/clip_page.dart';
import 'package:sport_camera/pages/home/edit_page.dart';
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
      // theme: ThemeData(
      //   useMaterial3: false,
      // ),
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

  late final List<Widget> _pages = [
    const HomePage(),
    const AlbumPage(
      topTabs: ['相机文件', '已下载'],
      subTabs: ['回忆', '全部', '收藏', '视频', '照片', '实况'],
    )
    ,
     ClipPage(), // 相机
    const EditPage(), // 剪辑
    const Placeholder(), // 我的
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
          BottomNavigationBarItem(icon: Icon(Icons.photo), label: '相册'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: '相机'),
          BottomNavigationBarItem(icon: Icon(Icons.cut), label: '剪辑'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
        ],
      ),
    );
  }
}
