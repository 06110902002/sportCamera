/// Author: Rambo.Liu
/// Date: 2025/12/25 11:20
/// @Copyright by JYXC Since 2023
/// Description: 首页只做框架约束，具体的业务由对应页面实现

import 'package:flutter/material.dart';
import 'package:sport_camera/pages/home/shop_page.dart';
import 'recommend_page.dart';

class HomePage extends StatefulWidget {
  static late TabController tabController;

  /// 是否允许一级 TabBarView 横向滑动
  static final ValueNotifier<bool> allowMainScroll =
  ValueNotifier<bool>(true);

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final List<String> _tabs = ['商城', '推荐', '教程'];

  @override
  void initState() {
    super.initState();
    HomePage.tabController =
        TabController(length: _tabs.length, vsync: this);

    /// 监听一级 tab 变化
    HomePage.tabController.addListener(() {
      final index = HomePage.tabController.index;

      /// 只有在「推荐页」才禁用一级滑动
      HomePage.allowMainScroll.value = index != 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TabBar(
          controller: HomePage.tabController,
          isScrollable: true,
          tabs: _tabs.map((e) => Tab(text: e)).toList(),
        ),
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: HomePage.allowMainScroll,
        builder: (_, allowScroll, __) {
          return TabBarView(
            controller: HomePage.tabController,
            physics: allowScroll
                ? const PageScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            children: const [
              ShopPage(),
              RecommendPage(),
              Center(child: Text('教程页面')),
            ],
          );
        },
      ),
    );
  }
}







