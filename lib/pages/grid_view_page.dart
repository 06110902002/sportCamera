import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sport_camera/widget/pull_refresh/pull_to_refresh_list_view.dart';

import '../utils/logger_util.dart';

typedef OnRefresh = Future<void> Function();

FutureOr<int> Function()? onRefresh2;

// 定义回调
OnRefresh onRefresh = () async {
  print('开始刷新');
  await Future.delayed(const Duration(seconds: 10));
  print('刷新完成');
  // 注意：async 函数默认不会抛出异常，需要手动 throw
};

// 使用 Future.sync 执行
void executeWithFutureSync() {
  Future<void> future = Future<void>.sync(() {
    return onRefresh(); // 返回 Future
  });

  future
      .then((_) {
    print('成功执行');
  })
      .catchError((error) {
    print('捕获错误: $error');
  });

  onRefresh2 = () async {
    print("this is onRefresh2  start");
    await Future.delayed(const Duration(seconds: 5));
    print("this is onRefresh2  finished");
    return 34;
  };

  Future<int> future2 = Future<int>.sync(onRefresh2!);
  future2
      .then((result) {
    print('onRefresh2 成功执行完成 result = $result');
  })
      .catchError((error) {
    print('onRefresh2 捕获错误: $error');
  });
}

void test() async {

  Future<void> future = Future<void>.sync(() {
     Future.delayed(const Duration(seconds: 2), () {
      print("51--------刷新完成");
      LoggerUtil.d("用户ID：${10086}，用户名：张三");
    });
  });

}

void main() {

 test();
 test();


  runApp(const MyApp2());
}

Widget buildHeadView(BuildContext context,
    ScrollPhase phase,
    bool isHolding,
    bool canRefresh,
    bool refreshCompleted,
    double dragOffset) {
  LoggerUtil.d("canRefresh = $canRefresh  dragOffset = $dragOffset");

  // State 1: Refreshing.
  if (isHolding) {
    return const Center(
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          color: Color(0xFFFF4D4F),
          strokeWidth: 2,
        ),
      ),
    );
  }

  // State 2: Completed.
  if(refreshCompleted) {
    return const Center(child: Text("刷新完成"));
  }

  // State 3: Dragging.
  // This block handles both "pulling" and "release to refresh" UI states.
  if(phase == ScrollPhase.dragging) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // This arrow animates its rotation based on the canRefresh state.
          AnimatedRotation(
            turns: canRefresh ? 0.5 : 0, // 0.5 turn = 180 degrees
            duration: const Duration(milliseconds: 250),
            child: const Icon(
              Icons.arrow_downward,
              color: Colors.grey,
              size: 24.0,
            ),
          ),
          const SizedBox(width: 8),
          // The text also changes based on the canRefresh state.
          Text(
            canRefresh ? "松手进行刷新" : "下拉进行刷新",
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
  return const SizedBox.shrink();
}

class MyApp2 extends StatefulWidget {
  const MyApp2({super.key});

  @override
  State<MyApp2> createState() => _MyApp2State();
}

class _MyApp2State extends State<MyApp2> {
  List<String> testDatas = ["湖南", "湖北", "山东", "山西", "河南"];
  // Add a refresh ID counter to the parent state.
  int _refreshId = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('PullToRefreshListView Demo'),
        ),
        body: PullToRefreshListView(
            headViewBuilder: buildHeadView,
          isOnStartRefresh: true,
            onRefresh: () async {
              // Increment the ID and capture it for this specific operation.
              final currentRefreshId = ++_refreshId;
              LoggerUtil.d("PullToRefreshListView start, operation ID: $currentRefreshId");

              await Future.delayed(const Duration(seconds: 5));

              // *** The Core Logic: The Filter ***
              // Before updating the state, check if this is still the latest operation.
              if (currentRefreshId == _refreshId) {
                print("Operation ID $currentRefreshId is current. Updating UI.");
                // This is the latest refresh task, so we can update the UI.
                setState(() {
                  testDatas.clear();
                  testDatas.add("广东");
                  testDatas.add("广西");
                  testDatas.add("河北");
                  testDatas.add("江苏");
                });
                LoggerUtil.d("PullToRefreshListView finished, testDatas length = ${testDatas.length}   operation ID: $currentRefreshId");
              } else {
                // This is an outdated task. Its result should be ignored.
                LoggerUtil.d("Ignoring result from outdated operation ID $currentRefreshId (latest is $_refreshId).");
              }
            },
            onLoadMore: () async {
              await Future.delayed(const Duration(seconds: 5));
              setState(() {
                testDatas.clear();
                testDatas.add("河南");
                testDatas.add("河北");
                testDatas.add("山西");
                testDatas.add("贵州");
                testDatas.add("广西");
                testDatas.add("海南");
              });
            },
            // contentView:  ListView.builder(
            //   itemCount: testDatas.length,
            //   itemBuilder: (_, i) => ListTile(title: Text(testDatas[i])),
            // )

          // slivers: [
          //   SliverList(
          //     delegate: SliverChildBuilderDelegate(
          //           (context, index) {
          //         return ListTile(title: Text(testDatas[index]));
          //       },
          //       childCount: testDatas.length,
          //     ),
          //   ),
          // ],

          // 使用 GridView 的新用法
          slivers: [
            SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  return _buildGridItem(index);
                },
                childCount: testDatas.length,
              ),
            ),
          ],
        ),
      )


    );
  }

  /// 构建单个网格Item - 带圆角+置顶标签+100%样式还原
  Widget _buildGridItem(int index) {
    return GestureDetector(
      onTap: () {

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
                    child:  Image.network(
                      "https://picsum.photos/300/200?random=1",
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
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
                        testDatas[index],
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
        ],
      ),
    );
  }
}
