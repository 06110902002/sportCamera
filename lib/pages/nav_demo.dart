/// Author: Rambo.Liu
/// Date: 2026/1/16 14:42
/// @Copyright by JYXC Since 2023
/// Description: TODO
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage(),
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(child: Text("主页内容")),
      // ========== 核心：用Stack包裹，导航栏和相机按钮 布局分离，视觉重叠 ==========
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none, // 允许子组件超出范围，无裁切
        children: [
          // ========== 1. 底部导航栏【高度永久锁死，永不变化】 ==========
          BottomNavigationBar(
            type: BottomNavigationBarType.fixed, // 5项均分宽度，必加
            backgroundColor: Colors.white,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.black,
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            iconSize: 22, // 其他图标尺寸，固定值
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
              BottomNavigationBarItem(icon: Icon(Icons.photo_library), label: '相册'),
              // 中间项：空组件，高度=默认高度，彻底锁死导航栏高度【重中之重】
              BottomNavigationBarItem(icon: SizedBox.shrink(), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.cut), label: '剪辑'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
            ],
          ),

          // ========== 2. 相机按钮【独立布局，绝对居中，和导航栏无任何关联】 ==========
          Positioned(
            left: 0,
            right: 0,
            bottom: 32, // 垂直居中关键值，完美和其他图标对齐，永不偏移
            child: GestureDetector(
              // 相机按钮点击事件
              onTap: () {
                print("相机按钮点击");
              },
              child: const CircleAvatar(
                radius: 26, // ✅ 随便改！20/22/24/26/28，导航栏高度完全不变！
                backgroundColor: Colors.yellow,
                child: Icon(Icons.camera_alt, color: Colors.black, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
