import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sport_camera/pages/home/model/device_type.dart';
import 'package:sport_camera/pages/home/recommend_tab_page.dart';

import 'home_page.dart';
import 'model/recommend_type.dart';

/// Author: Rambo.Liu
/// Date: 2025/12/25 11:33
/// @Copyright by JYXC Since 2023
/// Description: TODO

class RecommendPage extends StatefulWidget {
  const RecommendPage({super.key});

  @override
  State<RecommendPage> createState() => _RecommendPageState();
}

class _RecommendPageState extends State<RecommendPage>
    with SingleTickerProviderStateMixin {
  late TabController _subTabController;
  String _selectedDevice = 'X系列'; // State for selected device

  final List<RecommendType> _tabs = [
    RecommendType('收藏', RecommendId.like),
    RecommendType('关注', RecommendId.like),
    RecommendType('推荐', RecommendId.like),
    RecommendType('日常', RecommendId.like),
    RecommendType('旅行', RecommendId.like),
    RecommendType('摩托车', RecommendId.like),
  ];

  @override
  void initState() {
    super.initState();

    _subTabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: 2,
    );
  }

  @override
  void dispose() {
    _subTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topOffset = MediaQuery.of(context).padding.top;
    return NotificationListener<OverscrollNotification>(
      onNotification: _handleOverscroll,
      child: Column(
        children: [
          SizedBox(height: topOffset),
          _buildTopBar(context),
          Expanded(
            child: TabBarView(
              controller: _subTabController,
              children: _tabs.map((e) => _buildContent(e)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// 二级顶部栏
  Widget _buildTopBar(BuildContext context) {
    return Container(
      height: 44,
      color: Colors.white,
      child: Row(
        children: [
          _buildDeviceSelector(context),
          Expanded(
            child: TabBar(
              controller: _subTabController,
              isScrollable: true,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600, // 选中加粗
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(
                  width: 3,
                  color: Color(0xFFFFD400), // Insta360 黄
                ),
                insets: EdgeInsets.symmetric(horizontal: 18), // ⭐ 短线关键
              ),
              indicatorSize: TabBarIndicatorSize.label,
              tabs: _tabs
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Tab(text: e.name),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceSelector(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDeviceSelector(context),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            const Icon(Icons.camera_alt_outlined, size: 20),
            const SizedBox(width: 6),
            Text(
              _selectedDevice, // Use state variable
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  void _showDeviceSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (_) {
        return _DeviceSelectorSheet(
          selected: _selectedDevice,
          onSelected: (value) {
            setState(() {
              _selectedDevice = value;
            });
            Navigator.pop(context);
          },
        );
      },
    );
  }

  /// 内容示例
  Widget _buildContent(RecommendType recommend) {
    // return ListView.builder(
    //   padding: const EdgeInsets.all(12),
    //   itemCount: 20,
    //   itemBuilder: (_, i) {
    //     return Container(
    //       height: 120,
    //       margin: const EdgeInsets.only(bottom: 12),
    //       decoration: BoxDecoration(
    //         color: Colors.grey.shade300,
    //         borderRadius: BorderRadius.circular(12),
    //       ),
    //       alignment: Alignment.center,
    //       child: Text('${recommend.name} - item $i'),
    //     );
    //   },
    // );
    return RecommendTabPage(category: recommend.name);
  }

  /// 二级越界 → 主动切一级
  bool _handleOverscroll(OverscrollNotification n) {
    final isFirst = _subTabController.index == 0;
    final isLast = _subTabController.index == _tabs.length - 1;

    if (n.overscroll < 0 && isFirst) {
      HomePage.tabController.animateTo(0); // 商城
    }
    if (n.overscroll > 0 && isLast) {
      HomePage.tabController.animateTo(2); // 教程
    }
    return false;
  }
}

class _DeviceSelectorSheet extends StatefulWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const _DeviceSelectorSheet({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  @override
  State<_DeviceSelectorSheet> createState() => _DeviceSelectorSheetState();
}

class _DeviceSelectorSheetState extends State<_DeviceSelectorSheet> {
  late List<DeviceType> _deviceTypes;

  @override
  void initState() {
    super.initState();
    // In a real app, this list would likely come from a view model or other state management solution.
    final deviceNames = ['X系列', 'GO系列', 'ACE系列'];
    _deviceTypes = deviceNames
        .map((name) => DeviceType(name, name == widget.selected))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部标题栏
          Row(
            children: [
              const Expanded(
                child: Center(
                  child: Text(
                    '选择机型',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _deviceTypes.length,
              itemBuilder: (BuildContext context, int index) {
                final item = _deviceTypes[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _deviceTypes = _deviceTypes.map((device) {
                        return DeviceType(
                          device.name,
                          device.name == item.name,
                        );
                      }).toList();
                    });
                    widget.onSelected(item.name);
                  },
                  child: Container(
                    height: 48,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: item.isSelect
                          ? Colors.grey.shade500
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: TextStyle(
                              fontSize: 14,
                              color: item.isSelect
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                        if (item.isSelect)
                          const Icon(
                            Icons.check,
                            size: 20,
                            color: Colors.white,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
