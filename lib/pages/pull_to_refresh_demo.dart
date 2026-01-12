/// Author: Rambo.Liu
/// Date: 2026/1/5 19:43
/// @Copyright by JYXC Since 2023
/// Description: TODO

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

void main() {
  runApp(const MaterialApp(home: RefreshDemoPage()));
}

class RefreshDemoPage extends StatefulWidget {
  const RefreshDemoPage({super.key});

  @override
  State<RefreshDemoPage> createState() => _RefreshDemoPageState();
}

class _RefreshDemoPageState extends State<RefreshDemoPage> {
  List<String> items = ["1", "2", "3", "4"];
  RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    items.add((items.length + 1).toString());
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Pull To Refresh')),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: CustomHeader(
          builder: (BuildContext context, RefreshStatus? mode) {
            Widget body;
            if (mode == RefreshStatus.idle) {
              body = Text("下拉刷新");
            } else if (mode == RefreshStatus.refreshing) {
              body = CupertinoActivityIndicator();
            } else if (mode == RefreshStatus.failed) {
              body = Text("加载失败！点击重试！");
            } else if (mode == RefreshStatus.canRefresh) {
              body = Text("松手,加载更多!");
            } else {
              body = Text("没有更多数据了!");
            }
            return Container(height: 55.0, child: Center(child: body));
          },
        ),
        footer: CustomFooter(
          builder: (BuildContext context, LoadStatus? mode) {
            Widget body;
            if (mode == LoadStatus.idle) {
              body = Text("上拉加载");
            } else if (mode == LoadStatus.loading) {
              body = CupertinoActivityIndicator();
            } else if (mode == LoadStatus.failed) {
              body = Text("加载失败！点击重试！");
            } else if (mode == LoadStatus.canLoading) {
              body = Text("松手,加载更多!");
            } else {
              body = Text("没有更多数据了!");
            }
            return Container(height: 55.0, child: Center(child: body));
          },
        ),
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: ListView.builder(
          itemBuilder: (c, i) => Card(child: Center(child: Text(items[i]))),
          itemExtent: 50.0,
          itemCount: items.length,
        ),
      ),
    );
  }

  // 1.5.0后,应该没有必要加这一行了
  // @override
  // void dispose() {
  // TODO: implement dispose
  //   _refreshController.dispose();
  //    super.dispose();
  //  }
}
