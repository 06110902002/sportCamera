import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sport_camera/pages/base_page.dart';
import 'package:sport_camera/pages/login_fail.dart';
import 'package:sport_camera/provider/auth_model.dart';
import 'package:sport_camera/utils/logger_util.dart';
import 'package:sport_camera/widget/verification_code_button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Insta360 登录',
      theme: ThemeData(
        useMaterial3: false, // 或 true，保持统一
        primarySwatch: Colors.blue,
        primaryColor: Colors.blue, // 主要颜色
        scaffoldBackgroundColor: Colors.white, // 页面背景
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue, // AppBar背景
          foregroundColor: Colors.black, // AppBar文字/图标颜色
          elevation: 4, // 阴影高度
        ),
      ),
      // 关键：使用在 base_page.dart 中定义的全局 routeObserver
      navigatorObservers: [routeObserver],
      home: const LoginScreen(),
    );
  }
}

// 1. 让 LoginScreen 继承新的 BasePage
class LoginScreen extends BasePage<AuthModel> {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

// 2. _LoginScreenState 继承新的 BasePageState
class _LoginScreenState extends BasePageState<LoginScreen, AuthModel> {
  final _phoneNumberController = TextEditingController();
  final _verifyCodeController = TextEditingController();

  bool _isAgreed = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _phoneNumberController.addListener(() => setState(() {}));
    _verifyCodeController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _verifyCodeController.dispose();
    super.dispose();
  }

  // 3. 重写基类提供的生命周期方法
  @override
  void onDidPushNext() {
    LoggerUtil.d("LoginPage: Navigated to another page.");
  }

  @override
  void onDidPopNext() {
    LoggerUtil.d("LoginPage: Returned to this page.");
    // 页面重新可见时，重建UI以确保显示正确的状态
    setState(() {});
  }

  bool get _canLogin =>
      _phoneNumberController.text.isNotEmpty &&
      _verifyCodeController.text.length == 6;

  void _onLoginTap() async {
    if (_canLogin) {
      setState(() {
        _isLoading = true;
      });
      // 直接使用基类提供的 `model`
      final success = await model.login();
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      if (!success) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginFailPage()),
        );
      }
    }
  }

  void _sendVerificationCode() {
    // Here you can add the logic to actually send a verification code.
    // For now, we just show a snackbar.
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('验证码已发送')));
  }

  // 4. 实现 buildContent 方法来构建UI
  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => LoggerUtil.d("back"),
        ),
        actions: [
          Row(
            children: const [
              Text('中国'),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward),
            ],
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(''),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Insta360账号登录',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(
                hintText: '请输入手机号码或邮箱',
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _verifyCodeController,
                      decoration: const InputDecoration(
                        hintText: '请输入验证码',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: InputBorder.none,
                        counter: SizedBox.shrink(),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                    ),
                  ),
                  const SizedBox(width: 8),
                  VerificationCodeButton(
                    onSendCode: _sendVerificationCode,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _onLoginTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _canLogin ? Colors.blue : Colors.grey[300],
                  foregroundColor: _canLogin ? Colors.white : Colors.grey[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text('登录'),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                '未注册的手机号/邮箱将自动注册',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 100, height: 1, color: Colors.grey[300]),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '更多登录方式',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
                Container(width: 100, height: 1, color: Colors.grey[300]),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 140,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Center(child: Text('密码登录')),
                ),
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Icon(Icons.chat, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: const [
                          BoxShadow(color: Colors.grey, blurRadius: 2),
                        ],
                      ),
                      child: const Icon(Icons.facebook, color: Colors.red),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Icon(Icons.facebook, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: Text('还没有账号？', style: TextStyle(color: Colors.grey[500])),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('跳转到注册页面')));
                },
                child: const Text('注册', style: TextStyle(color: Colors.blue)),
              ),
            ),
            const SizedBox(height: 100),
            Row(
              children: [
                Transform.scale(
                  scale: 0.9,
                  child: Checkbox(
                    value: _isAgreed,
                    onChanged: (value) {
                      setState(() {
                        _isAgreed = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '已阅读并同意 ',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    '用户服务协议',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                const Text('、', style: TextStyle(color: Colors.grey)),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    '隐私政策',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
