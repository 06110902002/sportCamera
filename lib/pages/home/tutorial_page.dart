/// Author: Rambo.Liu
/// Date: 2025/12/26 13:54
/// @Copyright by JYXC Since 2023
/// Description: TODO

import 'package:flutter/material.dart';

// ---------------------- 回调参数模型（兼容所有Dart版本） ----------------------
class FilterCheckboxChangedData<T> {
  final T value; // 唯一标识
  final bool isSelected; // 选中状态

  FilterCheckboxChangedData({
    required this.value,
    required this.isSelected,
  });
}

// ---------------------- 可复用筛选复选框组件（修复回调参数） ----------------------
class FilterCheckbox<T> extends StatefulWidget {
  /// 【核心】唯一标识（非展示用，用于状态管理，支持任意类型：String/int/枚举等）
  final T value;
  /// 展示文本（可动态获取，如网络/多语言）
  final String label;
  /// 初始选中状态
  final bool initialValue;
  /// 选中状态变化回调（兼容所有Dart版本）
  final ValueChanged<FilterCheckboxChangedData<T>>? onChanged;
  /// 自定义样式（可选）
  final Color selectedBgColor;
  final Color selectedTextColor;
  final Color unselectedBgColor;
  final Color unselectedTextColor;
  final double borderRadius;
  final double fontSize;
  final EdgeInsets padding;

  const FilterCheckbox({
    super.key,
    required this.value, // 必传：唯一标识
    required this.label, // 必传：展示文本
    this.initialValue = false,
    this.onChanged,
    this.selectedBgColor = Colors.white,
    this.selectedTextColor = Colors.black,
    this.unselectedBgColor = const Color(0xFF4A4A4A),
    this.unselectedTextColor = Colors.white,
    this.borderRadius = 8.0,
    this.fontSize = 12.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  });

  @override
  State<FilterCheckbox<T>> createState() => _FilterCheckboxState<T>();
}

class _FilterCheckboxState<T> extends State<FilterCheckbox<T>> {
  late bool _isSelected;

  @override
  void initState() {
    super.initState();
    _isSelected = widget.initialValue;
  }

  // 切换选中状态
  void _toggleSelected() {
    setState(() {
      _isSelected = !_isSelected;
    });
    // 修复：使用自定义模型传递参数，替代元组
    if (widget.onChanged != null) {
      widget.onChanged!(
        FilterCheckboxChangedData<T>(
          value: widget.value,
          isSelected: _isSelected,
        ),
      );
    }
  }
  // 【核心修复】重写此方法以同步父组件的状态变化
  @override
  void didUpdateWidget(FilterCheckbox<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当父组件传递的 initialValue 与子组件当前的 _isSelected 状态不一致时
    if (widget.initialValue != _isSelected) {
      // 更新子组件的内部状态以匹配父组件
      setState(() {
        _isSelected = widget.initialValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _toggleSelected,
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: Container(
        padding: widget.padding,
        decoration: BoxDecoration(
          color: _isSelected ? widget.selectedBgColor : widget.unselectedBgColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: Text(
          widget.label,
          style: TextStyle(
            color: _isSelected ? widget.selectedTextColor : widget.unselectedTextColor,
            fontSize: widget.fontSize,
            fontWeight: _isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// ---------------------- 模拟网络请求的筛选数据模型 ----------------------
class FilterOption {
  final int id; // 唯一标识（后端返回，固定）
  final String name; // 展示文本（动态，如多语言/不同环境文案）

  FilterOption({required this.id, required this.name});
}

// ---------------------- 相册页面主逻辑（修复回调调用） ----------------------
class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> with TickerProviderStateMixin {
  bool _isFilterPanelVisible = false;
  double _panelHeight = 0;
  late TabController _tabController;

  // 筛选条件状态管理：用【唯一标识（int）】作为key，而非展示文本
  final Map<int, bool> _filterStates = {};
  // 模拟网络请求获取的筛选选项列表（文本动态）
  List<FilterOption> _filterOptions = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // 模拟网络请求加载筛选条件
    _loadFilterOptionsFromNetwork();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 模拟网络请求：获取动态筛选条件（文本可变化，唯一标识固定）
  void _loadFilterOptionsFromNetwork() {
    setState(() {
      _filterOptions = [
        FilterOption(id: 1, name: "视频文件"),
        FilterOption(id: 2, name: "照片文件"),
        FilterOption(id: 3, name: "实况文件"),
        FilterOption(id: 4, name: "全景"),
        FilterOption(id: 5, name: "平面"),
        FilterOption(id: 6, name: "已收藏"),
        FilterOption(id: 7, name: "已标记"),
      ];
      // 初始化状态：用唯一标识（id）作为key
      for (var option in _filterOptions) {
        _filterStates[option.id] = false;
      }
    });
  }

  void _toggleFilterPanel() {
    setState(() {
      _isFilterPanelVisible = !_isFilterPanelVisible;
      _panelHeight = _isFilterPanelVisible ? 320 : 0;
    });
  }

  void _closeFilterPanel() {
    if (_isFilterPanelVisible) {
      setState(() {
        _isFilterPanelVisible = false;
        _panelHeight = 0;
      });
    }
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
    return _getSelectedFilterIds()
        .map((id) => _filterOptions.firstWhere((opt) => opt.id == id).name)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("相机文件"),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, size: 24),
            onPressed: _toggleFilterPanel,
            tooltip: "筛选",
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "首页"),
          BottomNavigationBarItem(icon: Icon(Icons.album), label: "相册"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "设置"),
        ],
        currentIndex: 1,
        onTap: (index) {},
      ),
      body: Stack(
        children: [
          // 页面主体
          Column(
            children: [
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.blue,
                  tabs: const [
                    Tab(text: "全部"),
                    Tab(text: "收藏"),
                    Tab(text: "视频"),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    Center(child: Text("全部内容区域\n（可滚动/可交互）")),
                    Center(child: Text("收藏内容区域")),
                    Center(child: Text("视频内容区域")),
                  ],
                ),
              ),
            ],
          ),

          // 全屏遮罩
          if (_isFilterPanelVisible)
            GestureDetector(
              onTap: _closeFilterPanel,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.transparent,
              ),
            ),

          // 筛选面板
          _buildFilterPanel(),
        ],
      ),
    );
  }

  Widget _buildFilterPanel() {
    const tabBarHeight = 56.0;

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
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
        ),
        child: _isFilterPanelVisible ? _buildFilterContent() : null,
      ),
    );
  }

  Widget _buildFilterContent() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 文件类型（动态渲染网络获取的选项）
            const Text("文件类型", style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.2)),
            const SizedBox(height: 6),
            Wrap(spacing: 8, runSpacing: 8, children: [
              // 动态生成：用唯一标识（id），而非文本
              for (var opt in _filterOptions.where((o) => o.id <= 3))
                FilterCheckbox<int>(
                  value: opt.id, // 唯一标识（固定）
                  label: opt.name, // 动态展示文本（可来自网络）
                  initialValue: _filterStates[opt.id] ?? false,
                  onChanged: (data) {
                    // 修复：通过自定义模型的属性访问，不再报错
                    setState(() {
                      _filterStates[data.value] = data.isSelected;
                    });
                  },
                ),
            ]),

            // 2. 视角类型
            const SizedBox(height: 14),
            const Text("视角类型", style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.2)),
            const SizedBox(height: 6),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (var opt in _filterOptions.where((o) => o.id >=4 && o.id <=5))
                FilterCheckbox<int>(
                  value: opt.id,
                  label: opt.name,
                  initialValue: _filterStates[opt.id] ?? false,
                  onChanged: (data) {
                    setState(() {
                      _filterStates[data.value] = data.isSelected;
                    });
                  },
                ),
            ]),

            // 3. 收藏与标记
            const SizedBox(height: 14),
            const Text("收藏与标记", style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.2)),
            const SizedBox(height: 6),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (var opt in _filterOptions.where((o) => o.id >=6 && o.id <=7))
                FilterCheckbox<int>(
                  value: opt.id,
                  label: opt.name,
                  initialValue: _filterStates[opt.id] ?? false,
                  onChanged: (data) {
                    setState(() {
                      _filterStates[data.value] = data.isSelected;
                    });
                  },
                ),
            ]),

            // 4. 操作按钮
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetAllFilters,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey,
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text("确认"),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}