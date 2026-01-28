import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 1. 将 RouteObserver 定义在全局，方便在 MaterialApp 中引用
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

/// 2. 基类变为 StatefulWidget
/// 让页面可以拥有自己的 State，以便处理复杂的生命周期
abstract class BasePage<V extends ChangeNotifier> extends StatefulWidget {
  const BasePage({super.key});
}

/// 3. 提供一个通用的 BasePageState
/// 它混入了 RouteAware，并封装了所有相关的生命周期逻辑
abstract class BasePageState<Page extends BasePage<V>, V extends ChangeNotifier>
    extends State<Page> with RouteAware {
  /// ChangeNotifier 模型，将通过 Consumer 自动注入
  /// 子类可以直接使用 `model` 访问
  late V model;

  /// 子类需要实现此方法来构建页面 UI
  Widget buildContent(BuildContext context);

  /// 当导航到新页面，当前页面不再可见时调用
  void onDidPushNext() {
    // 默认实现为空，子类可以按需重写
  }

  /// 当从其他页面返回，当前页面再次可见时调用
  void onDidPopNext() {
    // 默认实现为空，子类可以按需重写
  }

  @override
  Widget build(BuildContext context) {
    // 使用 Consumer 来获取 Provider 提供的 Model
    return Consumer<V>(
      builder: (context, value, child) {
        model = value; // 将获取到的 Model 赋值给 state 的属性
        return buildContent(context);
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 订阅路由变化
    final route = ModalRoute.of(context);
    if (route != null) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    // 取消订阅
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  // 将 RouteAware 的事件转发给子类可重写的方法
  @override
  void didPushNext() {
    onDidPushNext();
  }

  @override
  void didPopNext() {
    onDidPopNext();
  }
}
