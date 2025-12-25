import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

/// Web路由服务
/// 处理Web平台的路由和导航功能
class WebRouterService {

  WebRouterService._();
  static WebRouterService? _instance;
  static WebRouterService get instance => _instance ??= WebRouterService._();

  final StreamController<String> _routeController =
      StreamController<String>.broadcast();
  final StreamController<Map<String, String>> _parametersController =
      StreamController<Map<String, String>>.broadcast();

  bool _isInitialized = false;
  String _currentRoute = '/';
  Map<String, String> _currentParameters = {};

  /// 路由变化流
  Stream<String> get routeChanges => _routeController.stream;

  /// 参数变化流
  Stream<Map<String, String>> get parameterChanges =>
      _parametersController.stream;

  /// 当前路由
  String get currentRoute => _currentRoute;

  /// 当前参数
  Map<String, String> get currentParameters => _currentParameters;

  /// 初始化Web路由服务
  Future<void> initialize() async {
    if (_isInitialized || !kIsWeb) return;

    try {
      // 监听浏览器历史变化
      _setupHistoryListener();

      // 解析初始URL
      _parseCurrentUrl();

      // 处理PWA快捷方式
      _handlePWAShortcuts();

      _isInitialized = true;
      print('WebRouterService initialized successfully');
    } catch (e) {
      print('Error initializing WebRouterService: $e');
    }
  }

  /// 设置历史监听器
  void _setupHistoryListener() {
    if (!kIsWeb) return;

    html.window.addEventListener('popstate', (event) {
      _parseCurrentUrl();
    });
  }

  /// 解析当前URL
  void _parseCurrentUrl() {
    if (!kIsWeb) return;

    try {
      final uri = Uri.parse(html.window.location.href);
      final newRoute = uri.path.isEmpty ? '/' : uri.path;
      final newParameters = uri.queryParameters;

      if (newRoute != _currentRoute) {
        _currentRoute = newRoute;
        _routeController.add(_currentRoute);
      }

      if (!_mapsEqual(_currentParameters, newParameters)) {
        _currentParameters = Map.from(newParameters);
        _parametersController.add(_currentParameters);
      }
    } catch (e) {
      print('Error parsing current URL: $e');
    }
  }

  /// 处理PWA快捷方式
  void _handlePWAShortcuts() {
    if (!kIsWeb) return;

    final action = _currentParameters['action'];
    if (action != null) {
      // 延迟处理，确保应用已完全加载
      Timer(const Duration(milliseconds: 500), () {
        _handleShortcutAction(action);
      });
    }
  }

  /// 处理快捷方式动作
  void _handleShortcutAction(String action) {
    switch (action) {
      case 'create-task':
        // 触发快速创建任务
        _routeController.add('/create-task');
      case 'pomodoro':
        // 触发番茄钟
        _routeController.add('/pomodoro');
      case 'today':
        // 显示今日任务
        _routeController.add('/today');
      default:
        print('Unknown shortcut action: $action');
    }
  }

  /// 导航到指定路由
  void navigateTo(String route, {Map<String, String>? parameters}) {
    if (!kIsWeb) return;

    try {
      final uri = Uri(path: route, queryParameters: parameters);
      html.window.history.pushState(null, '', uri.toString());
      _parseCurrentUrl();
    } catch (e) {
      print('Error navigating to route: $e');
    }
  }

  /// 替换当前路由
  void replaceTo(String route, {Map<String, String>? parameters}) {
    if (!kIsWeb) return;

    try {
      final uri = Uri(path: route, queryParameters: parameters);
      html.window.history.replaceState(null, '', uri.toString());
      _parseCurrentUrl();
    } catch (e) {
      print('Error replacing route: $e');
    }
  }

  /// 返回上一页
  void goBack() {
    if (!kIsWeb) return;

    try {
      html.window.history.back();
    } catch (e) {
      print('Error going back: $e');
    }
  }

  /// 前进到下一页
  void goForward() {
    if (!kIsWeb) return;

    try {
      html.window.history.forward();
    } catch (e) {
      print('Error going forward: $e');
    }
  }

  /// 更新当前页面的参数
  void updateParameters(Map<String, String> parameters) {
    if (!kIsWeb) return;

    try {
      final uri = Uri(path: _currentRoute, queryParameters: parameters);
      html.window.history.replaceState(null, '', uri.toString());
      _parseCurrentUrl();
    } catch (e) {
      print('Error updating parameters: $e');
    }
  }

  /// 获取路由对应的页面标题
  String getPageTitle(String route) {
    switch (route) {
      case '/':
        return 'Prvin AI智能日历 - 主页';
      case '/create-task':
        return 'Prvin AI智能日历 - 创建任务';
      case '/pomodoro':
        return 'Prvin AI智能日历 - 番茄钟专注';
      case '/today':
        return 'Prvin AI智能日历 - 今日任务';
      case '/calendar':
        return 'Prvin AI智能日历 - 日历视图';
      case '/tasks':
        return 'Prvin AI智能日历 - 任务管理';
      case '/analytics':
        return 'Prvin AI智能日历 - 数据分析';
      case '/settings':
        return 'Prvin AI智能日历 - 设置';
      default:
        return 'Prvin AI智能日历';
    }
  }

  /// 更新页面标题
  void updatePageTitle(String route) {
    if (!kIsWeb) return;

    try {
      final title = getPageTitle(route);
      html.document.title = title;
    } catch (e) {
      print('Error updating page title: $e');
    }
  }

  /// 设置页面元数据
  void setPageMetadata({
    String? title,
    String? description,
    String? keywords,
    String? ogTitle,
    String? ogDescription,
    String? ogImage,
  }) {
    if (!kIsWeb) return;

    try {
      // 设置标题
      if (title != null) {
        html.document.title = title;
      }

      // 设置描述
      if (description != null) {
        _updateMetaTag('name', 'description', description);
      }

      // 设置关键词
      if (keywords != null) {
        _updateMetaTag('name', 'keywords', keywords);
      }

      // 设置Open Graph标题
      if (ogTitle != null) {
        _updateMetaTag('property', 'og:title', ogTitle);
      }

      // 设置Open Graph描述
      if (ogDescription != null) {
        _updateMetaTag('property', 'og:description', ogDescription);
      }

      // 设置Open Graph图片
      if (ogImage != null) {
        _updateMetaTag('property', 'og:image', ogImage);
      }
    } catch (e) {
      print('Error setting page metadata: $e');
    }
  }

  /// 更新meta标签
  void _updateMetaTag(String attribute, String value, String content) {
    try {
      final meta = html.document.querySelector('meta[$attribute="$value"]');
      if (meta != null) {
        meta.setAttribute('content', content);
      } else {
        final newMeta = html.MetaElement();
        newMeta.setAttribute(attribute, value);
        newMeta.setAttribute('content', content);
        html.document.head?.append(newMeta);
      }
    } catch (e) {
      print('Error updating meta tag: $e');
    }
  }

  /// 检查两个Map是否相等
  bool _mapsEqual(Map<String, String> map1, Map<String, String> map2) {
    if (map1.length != map2.length) return false;

    for (final key in map1.keys) {
      if (map1[key] != map2[key]) return false;
    }

    return true;
  }

  /// 获取当前URL的完整信息
  Map<String, dynamic> getCurrentUrlInfo() {
    if (!kIsWeb) return {};

    try {
      final location = html.window.location;
      return {
        'href': location.href,
        'protocol': location.protocol,
        'host': location.host,
        'hostname': location.hostname,
        'port': location.port,
        'pathname': location.pathname,
        'search': location.search,
        'hash': location.hash,
        'origin': location.origin,
      };
    } catch (e) {
      print('Error getting current URL info: $e');
      return {};
    }
  }

  /// 检查是否支持历史API
  bool isHistoryApiSupported() {
    if (!kIsWeb) return false;

    try {
      return html.window.history != null;
    } catch (e) {
      return false;
    }
  }

  /// 释放资源
  void dispose() {
    _routeController.close();
    _parametersController.close();
  }
}
