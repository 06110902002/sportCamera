import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sport_camera/pages/edit/edit_templete_detail.dart';

/// Author: Rambo.Liu
/// Date: 2026/1/15 14:33
/// @Copyright by JYXC Since 2023
/// Description: 剪辑页面的主题模板组件
class ThemeTemplete extends StatefulWidget {
  final int mainTabIdx;
  final int subTabIdx;

  const ThemeTemplete({
    super.key,
    required this.mainTabIdx,
    required this.subTabIdx,
  });

  @override
  State<ThemeTemplete> createState() => _GridStickyListPageState();
}

class _GridStickyListPageState extends State<ThemeTemplete> {
  /// 数据源 & 核心配置
  final List<GridItemModel> gridList = [];
  final int _loadPageSize = 10; // 每次请求固定加载10条
  bool _isLoading = false; // 加载锁 - 防止重复请求
  bool _hasNoMore = false; // 是否没有更多数据

  @override
  void initState() {
    super.initState();
    _loadMoreData(); // 初始化加载第一页
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// 核心加载方法 - ✅完全匹配你的2条加载规则【重中之重】
  Future<void> _loadMoreData() async {
    // 加载中/无更多 直接拦截，防止重复请求
    if (_isLoading || _hasNoMore) return;
    setState(() => _isLoading = true);

    try {
      // ========== 真实项目中 替换这部分为你的接口请求即可 ==========
      // 模拟网络请求延迟
      await Future.delayed(const Duration(milliseconds: 800));

      // 异步操作结束后，检查页面是否还存在，防止内存泄漏
      if (!mounted) return;

      // 模拟接口返回数据：核心规则实现
      List<GridItemModel> newDataList = [];
      int currentDataCount = gridList.length;
      // 计算本次应该加载的区间
      int endIndex = currentDataCount + _loadPageSize;
      // 模拟：总数据26条（演示 加载不足10条的场景，第3次加载只返回6条）
      const int totalDataCount = 26;
      if (endIndex > totalDataCount) {
        endIndex = totalDataCount;
      }
      // 生成模拟数据
      for (int i = currentDataCount; i < endIndex; i++) {
        newDataList.add(
          GridItemModel(
            imageUrl: i == 0
                ? "https://p3-flow-imagex-sign.byteimg.com/tos-cn-i-a9rns2rl98/1d78ee36d78c4c96ab2f54bd3438f2bf.png~tplv-a9rns2rl98-image.png?lk3s=8e244e95&rcl=20260115141902DF8596DB8F0F6D5C33F0&rrcfp=dafada99&x-expires=2084681942&x-signature=K%2FSyFqr%2BdppjVJAakd9Bj1PKnmg%3D"
                : "",
            title: i == 0
                ? "全员AI灵魂战车"
                : "测试标题 ${i + 1} mainTabIdx = ${widget.mainTabIdx} subTabIdx = ${widget.subTabIdx}",
            isTop: i == 0,
          ),
        );
      }
      // ==========================================================

      /// ✅ 加载规则核心判断【两条规则一次性实现】
      /// 规则1：本次加载的数据条数 < 10条 → 判定为无更多数据
      /// 规则2：首次加载就不足10条 → 底部直接显示无更多文案
      if (newDataList.length < _loadPageSize) {
        setState(() => _hasNoMore = true);
      }

      // 添加新数据到列表
      setState(() {
        gridList.addAll(newDataList);
        _isLoading = false;
      });
    } catch (e) {
      // 异常处理：加载失败关闭loading
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    //这里使用 滚动位置滚动，而不是使用ScrollController 是为了防止与edit_page.dart 文件 NestedScrollView 滚动冲突
    // 防止NestedScrollView滚动不生效，因为这里一旦设置了自己ScrollController,它就会忽略外部的滚动
    // 当将这个 _scrollController 赋值给 ThemeTemplete 内部的 CustomScrollView 时，
    // 就等于告诉它：“不要理会外部 NestedScrollView 的协调，你自己管理自己的滚动。”◦
    // 这导致 ThemeTemplete 的 CustomScrollView 创建了一个独立的、与外部隔绝的滚动世界。
    // 所有的滚动事件都被它自己的控制器“消费”掉了，
    // 所以外部的 headerSliverBuilder (您的那些Sliver头部) 完全感知不到内部的滚动，自然也就不会有折叠效果。
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // 监听滚动，触发加载更多
        if (notification is ScrollUpdateNotification &&
            notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 50 &&
            !_isLoading &&
            !_hasNoMore) {
          _loadMoreData();
        }
        return false; // 返回false，让通知继续向上传递，以驱动NestedScrollView
      },
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(), // 回弹滚动效果
        slivers: [
          // ========== 网格列表主体 - 样式/间距/圆角 完美还原 ==========
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 固定2列
                crossAxisSpacing: 10, // item左右间距10
                mainAxisSpacing: 10, // item上下间距10
                childAspectRatio:
                    17 / 24, // item宽高比完美还原,实际的情况需要与视觉商量好 使用统一的图片宽度比，这个值填视觉给的宽高比即可
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildGridItem(gridList[index]),
                childCount: gridList.length,
              ),
            ),
          ),

          // ========== 完美位置：网格最后一个元素正下方 + 整屏水平居中 ==========
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 25),
              alignment: Alignment.center, // 强制整屏居中，永不偏移
              child: _buildBottomStatusWidget(),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建单个网格Item - 带圆角+置顶标签+100%样式还原
  Widget _buildGridItem(GridItemModel item) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const EditTempleteDetail()));
      },
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8), // item圆角，可自定义大小
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  Expanded(
                    flex: 17,
                    child: item.imageUrl.isNotEmpty
                        ? Image.network(
                            item.imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildEmptyImage(),
                          )
                        : _buildEmptyImage(),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF333333),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 置顶标签 - 悬浮左上角 不被圆角裁剪
          if (item.isTop)
            Positioned(
              left: 6,
              top: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4D4F),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: const Text(
                  "置顶",
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 空图片占位布局
  Widget _buildEmptyImage() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF5F5F5),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        color: Color(0xFFCCCCCC),
        size: 28,
      ),
    );
  }

  /// 加载中/无更多 状态视图 - 整屏居中
  Widget _buildBottomStatusWidget() {
    if (_isLoading) {
      return const CircularProgressIndicator(
        color: Color(0xFFFF4D4F),
        strokeWidth: 2,
      );
    } else if (_hasNoMore) {
      return const Text(
        "没有更多数据了",
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFF999999),
          fontWeight: FontWeight.normal,
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}

/// 网格Item数据模型类
class GridItemModel {
  final String imageUrl;
  final String title;
  final bool isTop;

  GridItemModel({
    required this.imageUrl,
    required this.title,
    required this.isTop,
  });
}
