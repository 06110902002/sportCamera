/// Author: Rambo.Liu
/// Date: 2025/12/25 11:21
/// @Copyright by JYXC Since 2023
/// Description: TODO
import 'package:flutter/material.dart';

import 'package:sport_camera/pages/home/model/album_data.dart';

import '../widget/check_box_button.dart';

class FilterType {
  final int id; // 唯一标识（后端返回，固定）
  final String name; // 展示文本（动态，如多语言/不同环境文案）

  FilterType({required this.id, required this.name});
}

class AlbumPage extends StatefulWidget {
  const AlbumPage({super.key, required this.topTabs, required this.subTabs});

  /// 顶部一级 Tab（如：相机文件 / 已下载）
  final List<String> topTabs;

  /// 二级 Tab（如：回忆 / 全部 / 收藏 / 视频 / 照片 / 实况）
  final List<String> subTabs;

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> with TickerProviderStateMixin {
  late TabController _topTabController;
  late TabController _subTabController;
  late List<AlbumData> _albumDataList;
  static final double topBarH = 48;
  static final double subBarH = 44;
  // 筛选条件状态管理：用【唯一标识（int）】作为key，而非展示文本
  final Map<int, bool> _filterStates = {};
  // 模拟网络请求获取的筛选选项列表（文本动态）
  Map<int, String> _filterOptions = {};

  @override
  void initState() {
    super.initState();
    _topTabController = TabController(
      length: widget.topTabs.length,
      vsync: this,
      initialIndex: 1,
    );
    // Add a listener to rebuild the UI when the top tab changes.
    _topTabController.addListener(() {
      if (!_topTabController.indexIsChanging) {
        _closeFilterPanel();
        setState(() {});
      }
    });

    _subTabController = TabController(
      length: widget.subTabs.length,
      vsync: this,
      initialIndex: 1,
    );

    // Rebuild when sub-tab changes to update content.
    _subTabController.addListener(() {
      if (!_subTabController.indexIsChanging) {
        _closeFilterPanel();
        setState(() {});
      }
    });

    // Sample Data
    _albumDataList = [
      //相机-回忆文件
      AlbumData(
        albumType: AlbumType.camera,
        secondType: AlbumSecondType.memory,
        title: "相机-回忆-1",
        imageUrl: "assets/imgs/seu.jpg",
      ),
      AlbumData(
        albumType: AlbumType.camera,
        secondType: AlbumSecondType.memory,
        title: "相机-回忆-2",
        imageUrl: "assets/imgs/seu.jpg",
      ),
      //相机-照片文件
      AlbumData(
        albumType: AlbumType.camera,
        secondType: AlbumSecondType.photo,
        title: "相机-照片-1",
        imageUrl: "assets/imgs/seu.jpg",
      ),
      //相机-实况照片文件
      AlbumData(
        albumType: AlbumType.camera,
        secondType: AlbumSecondType.livePhoto,
        title: "相机-实况-1",
        imageUrl: "assets/imgs/seu.jpg",
      ),
      //相机-全部
      AlbumData(
        albumType: AlbumType.camera,
        secondType: AlbumSecondType.all,
        title: "相机-全部-1",
        imageUrl: "assets/imgs/seu.jpg",
      ),
      AlbumData(
        albumType: AlbumType.camera,
        secondType: AlbumSecondType.all,
        title: "相机-全部-2",
        imageUrl: "assets/imgs/seu.jpg",
      ),
      AlbumData(
        albumType: AlbumType.camera,
        secondType: AlbumSecondType.all,
        title: "相机-全部-3",
        imageUrl: "assets/imgs/seu.jpg",
      ),
      AlbumData(
        albumType: AlbumType.camera,
        secondType: AlbumSecondType.all,
        title: "相机-全部-4",
        imageUrl: "assets/imgs/seu.jpg",
      ),
      AlbumData(
        albumType: AlbumType.camera,
        secondType: AlbumSecondType.all,
        title: "相机-全部-5",
        imageUrl: "assets/imgs/seu.jpg",
      ),
      AlbumData(
        albumType: AlbumType.camera,
        secondType: AlbumSecondType.all,
        title: "相机-全部-6",
        imageUrl: "assets/imgs/seu.jpg",
      ),
      //已下载-回忆
      AlbumData(
        albumType: AlbumType.download,
        secondType: AlbumSecondType.memory,
        title: "下载-回忆-1",
        imageUrl: "assets/imgs/seu.jpg",
      ),
      //已下载-all
      AlbumData(
        albumType: AlbumType.download,
        secondType: AlbumSecondType.all,
        title: "下载-全部-1",
        imageUrl: "assets/imgs/tianmao.jpg",
      ),
      AlbumData(
        albumType: AlbumType.download,
        secondType: AlbumSecondType.all,
        title: "下载-全部-2",
        imageUrl: "assets/imgs/tianmao.jpg",
      ),
    ];

    //初始化过滤标签
    _initFilterConfig();
  }

  void _initFilterConfig() {
    setState(() {
      _filterOptions[AlbumSecondType.all.value] = "全部";
      _filterOptions[AlbumSecondType.video.value] = "视频文件";
      _filterOptions[AlbumSecondType.photo.value] = "照片文件";
      _filterOptions[AlbumSecondType.livePhoto.value] = "实况文件";
      _filterOptions[AlbumSecondType.panoramic.value] = "全景";
      _filterOptions[AlbumSecondType.plat.value] = "平面";
      _filterOptions[AlbumSecondType.mark.value] = "标记";
      _filterOptions[AlbumSecondType.like.value] = "收藏";

      // 初始化状态：用唯一标识（id）作为key
      _filterOptions.forEach((key, value) {
        _filterStates[key] = false;
      });
    });
  }

  // 控制筛选面板显示/隐藏
  bool _isFilterPanelVisible = false;
  // 面板动画高度（0=隐藏，320=显示）
  double _panelHeight = 0;
  // 切换筛选面板显示/隐藏（带动画）
  void _toggleFilterPanel() {
    setState(() {
      _isFilterPanelVisible = !_isFilterPanelVisible;
      // 面板显示时高度设为320（可根据UI需求调整）
      _panelHeight = _isFilterPanelVisible ? 320 : 0;
    });
  }

  void _closeFilterPanel() {
    _resetAllFilters();
    if (_isFilterPanelVisible) {
      setState(() {
        _isFilterPanelVisible = false;
        _panelHeight = 0;
      });
    }
  }

  @override
  void dispose() {
    _topTabController.dispose();
    _subTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isFilterPanelVisible ? Color(0xFF2C2C2C) : Colors.black,
      // body: SafeArea(
      //   bottom: false,
      //   child: Column(
      //     children: [
      //       _buildTopTabBar(),
      //       _buildSubTabBar(),
      //       Expanded(child: _buildContent()),
      //     ],
      //   ),
      // ),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                _buildTopTabBar(),
                _buildSubTabBar(),
                Expanded(child: _buildContent()),
              ],
            ),

            // 外部点击遮罩
            if (_isFilterPanelVisible)
              GestureDetector(
                onTap: _closeFilterPanel,
                child: Container(
                  color: Colors.grey,
                  margin: EdgeInsets.only(top: topBarH + subBarH + 320),
                ),
              ),
            // 浮动筛选面板
            _buildFilterPanel(),
          ],
        ),
      ),
    );
  }

  /// ===============================
  /// 顶部：一级 TabBar（可滚动）+ 右侧按钮
  /// ===============================
  Widget _buildTopTabBar() {
    return Container(
      height: topBarH,
      //color: Colors.yellow,
      //padding: const EdgeInsets.only(left: 12),
      child: Row(
        children: [
          Expanded(
            child: TabBar(
              //padding: const EdgeInsets.only(left: 12),
              controller: _topTabController,
              isScrollable: true,
              indicator: const BoxDecoration(),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              tabs: widget.topTabs.map((e) => Tab(text: e)).toList(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.swap_vert, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.check_circle_outline, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  /// ===============================
  /// 二级 TabBar
  /// ===============================
  Widget _buildSubTabBar() {
    return Container(
      height: subBarH,
      //color: Colors.yellow,
      //padding: const EdgeInsets.only(left: 12),
      child: Row(
        children: [
          Expanded(
            child: TabBar(
              controller: _subTabController,
              isScrollable: true,
              indicatorColor: const Color(0xFFFFD400),
              indicatorWeight: 2,
              indicatorSize: TabBarIndicatorSize.label,
              indicatorPadding: const EdgeInsets.symmetric(horizontal: 7),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              tabs: widget.subTabs.map((e) => Tab(text: e)).toList(),
            ),
          ),
          const SizedBox(width: 20),
          IconButton(
            icon: const Icon(Icons.swap_vert, color: Colors.white),
            onPressed: () {
              _toggleFilterPanel();
            },
          ),
        ],
      ),
    );
  }

  /// ===============================
  /// 内容区（与二级 TabBar 联动）
  /// ===============================
  Widget _buildContent() {
    // This is the correct place to build the TabBarView's children.
    // It will be rebuilt whenever setState is called.
    return TabBarView(
      controller: _subTabController,
      physics: const BouncingScrollPhysics(),
      children: widget.subTabs.asMap().entries.map((entry) {
        final subIndex = entry.key;
        final topIndex = _topTabController.index;

        final filteredList = _albumDataList.where((data) {
          return data.albumType.value == topIndex &&
              data.secondType.value == subIndex;
        }).toList();

        return _buildContentList(filteredList);
      }).toList(),
    );
  }

  /// Builds a GridView for the given list of data.
  Widget _buildContentList(List<AlbumData> selectDataList) {
    if (selectDataList.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: selectDataList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (_, index) {
        final item = selectDataList[index];
        return _buildAlbumItem(
          title: item.title,
          imgUrl: item.imageUrl ?? "", // Use a fallback for safety
        );
      },
    );
  }

  /// Builds a single item for the GridView.
  Widget _buildAlbumItem({required String title, required String imgUrl}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Container(
            clipBehavior: Clip.antiAlias, // To respect the border radius
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(12),
            ),
            child: imgUrl.isNotEmpty
                ? Image.asset(
                    imgUrl,
                    fit: BoxFit.cover,
                    // Show an error icon if the asset is not found
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.error, color: Colors.grey),
                      );
                    },
                  )
                : const Center(
                    child: Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// 构建筛菜单面板（定位到TabBar下方，覆盖在内容上方）
  Widget _buildFilterPanel() {
    double tabBarHeight = topBarH + subBarH;
    return Positioned(
      top: tabBarHeight,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        height: _panelHeight,
        decoration: const BoxDecoration(
          color: Color(0xFF2C2C2C),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),

        child: _isFilterPanelVisible ? _buildFilterContent() : null,
      ),
    );
  }

  // 重置所有筛选条件：操作唯一标识，与文本无关
  void _resetAllFilters() {
    setState(() {
      _filterStates.forEach((key, value) {
        _filterStates[key] = false;
      });
    });
  }

  // 获取选中的筛选条件：返回唯一标识列表，而非文本
  List<int> _getSelectedFilterIds() {
    return _filterStates.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }

  // 根据唯一标识匹配动态文本（用于展示选中结果）
  List<String> _getSelectedFilterLabels() {
    List<int> ids = _getSelectedFilterIds();
    List<String> names = [];
    for (int id in ids) {
      if (_filterOptions.containsKey(id)) {
        names.add(_filterOptions[id]!);
      }
    }
    return names;
  }

  Widget _buildFilterContent() {
    int curSubIdx = _subTabController.index;
    return SingleChildScrollView(
      // 取消滚动条（可选）
      physics: const ClampingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          // 关键：设置mainAxisSize为min，避免Column占满父容器导致溢出
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 文件类型筛选
            const Text(
              "文件类型",
              style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.2),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // 动态生成：用唯一标识（id），而非文本
                if (curSubIdx == AlbumSecondType.all.value ||
                    curSubIdx == AlbumSecondType.like.value)
                  for (var enrty in _filterOptions.entries)
                    if (enrty.key == AlbumSecondType.video.value ||
                        enrty.key == AlbumSecondType.photo.value ||
                        enrty.key == AlbumSecondType.livePhoto.value)
                      CheckBoxButton<int>(
                        value: enrty.key,
                        label: enrty.value, // 动态展示文本（可来自网络）
                        initialValue: _filterStates[enrty.key] ?? false,
                        onChanged: (data) {
                          setState(() {
                            _filterStates[data.value] = data.isSelected;
                          });
                        },
                      ),

                if (curSubIdx == AlbumSecondType.video.value ||
                    curSubIdx == AlbumSecondType.photo.value ||
                    curSubIdx == AlbumSecondType.livePhoto.value)
                  CheckBoxButton<int>(
                    value: curSubIdx,
                    label: _filterOptions[curSubIdx]!,
                    initialValue: _filterStates[curSubIdx] ?? false,
                    onChanged: (data) {
                      setState(() {
                        _filterStates[data.value] = data.isSelected;
                      });
                    },
                  ),
              ],
            ),

            // 2. 视角类型筛选
            const SizedBox(height: 14),
            const Text(
              "视角类型",
              style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.2),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var enrty in _filterOptions.entries)
                  if (enrty.key == AlbumSecondType.panoramic.value ||
                      enrty.key == AlbumSecondType.plat.value)
                    CheckBoxButton<int>(
                      value: enrty.key,
                      label: enrty.value,
                      initialValue: _filterStates[enrty.key] ?? false,
                      onChanged: (data) {
                        setState(() {
                          _filterStates[data.value] = data.isSelected;
                        });
                      },
                    ),
              ],
            ),

            // 3. 收藏与标记筛选
            const SizedBox(height: 14),
            const Text(
              "收藏与标记",
              style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.2),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var enrty in _filterOptions.entries)
                  if (enrty.key == AlbumSecondType.like.value ||
                      enrty.key == AlbumSecondType.mark.value)
                    CheckBoxButton<int>(
                      value: enrty.key,
                      label: enrty.value,
                      initialValue: _filterStates[enrty.key] ?? false,
                      onChanged: (data) {
                        setState(() {
                          _filterStates[data.value] = data.isSelected;
                        });
                      },
                    ),
              ],
            ),

            // 4. 底部操作按钮
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // 重置筛选逻辑
                      _resetAllFilters();
                      //_closeFilterPanel();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey,
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text("重置"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // 业务逻辑：传唯一标识（id）给后端，而非文本
                      print("选中的筛选条件ID：${_getSelectedFilterIds()}");
                      // 仅展示用：根据ID匹配动态文本
                      print("选中的筛选条件文本：${_getSelectedFilterLabels()}");
                      _closeFilterPanel();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text("确认"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 通用筛选按钮（微调尺寸，减少高度占用）
  Widget _buildFilterBtn(String text) {
    return ElevatedButton(
      onPressed: () {
        setState(() {});
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4A4A4A),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        minimumSize: const Size(70, 30),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }

  /// ===============================
  /// 空状态（占位）
  /// ===============================
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 12),
          Text('还没有内容', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
