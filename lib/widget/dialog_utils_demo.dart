/// Author: Rambo.Liu
/// Date: 2026/1/19 10:12
/// @Copyright by JYXC Since 2023
/// Description: TODO
import 'package:flutter/material.dart';

import 'common_popup_template.dart';




void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "通用弹窗模板",
      debugShowCheckedModeBanner: false,
      home: TaskCenterPage(),
    );
  }
}

class TaskCenterPage extends StatefulWidget {
  const TaskCenterPage({super.key});

  @override
  State<TaskCenterPage> createState() => _TaskCenterPageState();
}

class _TaskCenterPageState extends State<TaskCenterPage> {
  late CommonPopupTemplate _activityPopup;
  late CommonPopupTemplate _tipsPopup;
  late CommonPopupTemplate _formPopup; // 第三个按钮的表单弹窗

  @override
  void initState() {
    super.initState();
    _initAllPopups();
    // 进入页面自动显示活动弹窗
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _activityPopup.show();
    });
  }

  void _initAllPopups() {
    // 1. 活动弹窗
    _activityPopup = CommonPopupTemplate(
      context: context,
      contentWidget: LeicaChallengePopup(
        onSubmit: () {
          _activityPopup.dismiss();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("跳转至投稿页面")));
        },
      ),
      onClose: () => debugPrint("活动弹窗关闭"),
    );

    // 2. 提示弹窗
    _tipsPopup = CommonPopupTemplate(
      context: context,
      popupWidth: 280,
      maskOpacity: 0.5,
      contentWidget: Column(mainAxisSize: MainAxisSize.min,children: [
        const SizedBox(height:24),
        const Icon(Icons.check_circle,color:Colors.green,size:48),
        const SizedBox(height:16),
        const Text("任务完成！",style: TextStyle(fontSize:18,fontWeight:FontWeight.bold)),
        const SizedBox(height:8),
        const Padding(padding: EdgeInsets.symmetric(horizontal:20),child: Text("恭喜你完成影像投稿任务，获得50积分奖励",textAlign:TextAlign.center,style: TextStyle(fontSize:14,color:Color(0xFF666666)))),
        const SizedBox(height:24),
        Padding(padding: EdgeInsets.symmetric(horizontal:30),child: ElevatedButton(
          onPressed: ()=>_tipsPopup.dismiss(),
          style: ElevatedButton.styleFrom(backgroundColor:Colors.green,minimumSize: const Size(double.infinity,44)),
          child: const Text("确定",style: TextStyle(color:Colors.white)),
        )),
        const SizedBox(height:20),
      ]),
      onClose: (){},
    );

    // 3. 表单弹窗【核心修复：去掉expands，修改maxLines，彻底解决所有报错】
    _formPopup = CommonPopupTemplate(
      context: context,
      popupWidth: 320,
      barrierDismissible: true,
      contentWidget: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height:20),
          const Text("填写任务备注",style: TextStyle(fontSize:18,fontWeight:FontWeight.bold)),
          const SizedBox(height:16),
          // ✅✅ 修复TextField配置：去掉expands，设置maxLines=5 实现多行输入，无任何报错
          Padding(
            padding: const EdgeInsets.symmetric(horizontal:20),
            child: TextField(
              maxLines: 5, // 推荐写法，支持多行输入，高度自适应
              decoration: InputDecoration(
                hintText: "请输入备注信息（可选）",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal:16, vertical:12),
              ),
            ),
          ),
          const SizedBox(height:20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal:20),
            child: Row(children: [
              Expanded(child: TextButton(
                onPressed: ()=>_formPopup.dismiss(),
                child: const Text("取消",style: TextStyle(color:Color(0xFF666666))),
              )),
              const SizedBox(width:10),
              Expanded(child: ElevatedButton(
                onPressed: (){
                  _formPopup.dismiss();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("备注已保存")));
                },
                style: ElevatedButton.styleFrom(backgroundColor:Colors.black),
                child: const Text("保存",style: TextStyle(color:Colors.white)),
              )),
            ]),
          ),
          const SizedBox(height:20),
        ],
      ),
      onClose: (){},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("任务中心"), backgroundColor: Colors.white, foregroundColor: Colors.black),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(children: [
          Expanded(child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                title: const Text("任务1：完成影像投稿，获得积分奖励"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: ()=>_activityPopup.show(),
              ),
              const Divider(),
              ListTile(
                title: const Text("任务2：查看任务奖励提示"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: ()=>_tipsPopup.show(),
              ),
              const Divider(),
              ListTile(
                title: const Text("任务3：填写任务备注"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: ()=>_formPopup.show(), // 点击这个按钮 绝对无报错！
              ),
            ],
          )),
        ]),
      ),
    );
  }
}
