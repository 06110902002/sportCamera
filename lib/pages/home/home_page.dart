/// Author: Rambo.Liu
/// Date: 2025/12/25 11:20
/// @Copyright by JYXC Since 2023
/// Description: 首页只做框架约束，具体的业务由对应页面实现

import 'package:flutter/material.dart';
import 'package:sport_camera/pages/home/shop_page.dart';
import 'package:sport_camera/pages/home/tutorial_page.dart';
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
  late int curSelectIdx;
  late bool isPined;

  @override
  void initState() {
    super.initState();
    isPined = false;
    HomePage.tabController =
        TabController(length: _tabs.length, vsync: this);
    curSelectIdx = HomePage.tabController.index;
    /// 监听一级 tab 变化
    HomePage.tabController.addListener(() {
      final index = HomePage.tabController.index;
      curSelectIdx = index;
      print("38-----------index = $curSelectIdx");
      if (!HomePage.tabController.indexIsChanging) {
        setState(() {
        });
      }
      /// 只有在「推荐页」才禁用一级滑动
      HomePage.allowMainScroll.value = index != 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: curSelectIdx == 2, //页面置于教程时，将body 部分放在appBar 下方
      appBar: _buildTabBarView(_tabs),
      body: ValueListenableBuilder<bool>(
        valueListenable: HomePage.allowMainScroll,
        builder: (_, allowScroll, __) {
          return TabBarView(
            controller: HomePage.tabController,
            physics: allowScroll
                ? const PageScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            children:  [
              ShopPage(),
              RecommendPage(),
              TutorialPage(onScrollPinedChanged: (pined)=>{
                setState(() {
                  isPined = pined;
                })
              }),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildTabBarView(List<String> titles) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: curSelectIdx == 2 && !isPined ? Colors.transparent:Colors.white,
      elevation: 0,
      titleSpacing: 0,
      title: Row(
        children: [
          // 左侧：消息按钮
          IconButton(
            icon: const Icon(Icons.mail_outline, color: Colors.black),
            onPressed: () {
              // TODO: 消息点击事件
            },
          ),

          // 中间：真正居中的 TabBar
          Expanded(
            child: Center(
              child: TabBar(
                controller: HomePage.tabController,
                isScrollable: true,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFFFFD400),
                indicatorWeight: 3,
                tabs: titles.map((e) => Tab(text: e)).toList(),
              ),
            ),
          ),

          // 右侧：占位，保证视觉居中
          const SizedBox(width: 48),
        ],
      ),
    );
  }

}








