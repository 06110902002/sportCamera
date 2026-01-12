import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'CustomRefreshIndicator.dart';
import 'RefreshStatus.dart';

/// Author: Rambo.Liu
/// Date: 2026/1/6 15:20
/// @Copyright by JYXC Since 2023
/// Description: TODO
///
///

void main() {
  runApp(const MaterialApp(home: RefreshDemoPage()));
}

class RefreshDemoPage extends StatefulWidget {
  const RefreshDemoPage({super.key});

  @override
  State<RefreshDemoPage> createState() => _RefreshDemoPageState();
}

class _RefreshDemoPageState extends State<RefreshDemoPage> {
  List<String> _dataList = List.generate(5, (index) => "列表项 $index");

  // 模拟异步刷新数据
  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _dataList = List.generate(6, (index) => "刷新后的列表项 $index");
    });
  }

  // 自定义刷新指示器
  Widget _customIndicatorBuilder(double progress, RefreshStatus status) {
    return Container(
      height: 80,
      color: Colors.yellow,
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (status == RefreshStatus.refreshing)
            const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            )
          else
            Icon(
              Icons.refresh,
              color: Colors.red,
              size: 24 + progress * 8,
            ),
          const SizedBox(height: 4),
          Text(
            status == RefreshStatus.pulling
                ? progress < 1 ? "下拉刷新" : "松开刷新"
                : status == RefreshStatus.refreshing
                ? "正在刷新..."
                : "刷新完成",
            style: const TextStyle(fontSize: 12, color: Colors.red),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("自定义下拉刷新")),
      body: CustomRefreshIndicator(
        onRefresh: _onRefresh,
        config: const RefreshConfig(
          triggerDistance: 80,
          indicatorHeight: 80,
        ),
        indicatorBuilder: _customIndicatorBuilder,
        child: ListView.builder(
          itemCount: _dataList.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(_dataList[index]),
            );
          },
        ),
      ),
    );
  }
}
