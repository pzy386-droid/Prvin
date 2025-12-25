import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

/// Web平台服务
/// 提供Web平台特有的功能和优化
class WebPlatformService {

  WebPlatformService._();
  static WebPlatformService? _instance;
  static WebPlatformService get instance =>
      _instance ??= WebPlatformService._();

  final StreamController<bool> _pwaInstallAvailableController =
      StreamController<bool>.broadcast();
  final StreamController<String> _keyboardShortcutController =
      StreamController<String>.broadcast();
  final StreamController<bool> _onlineStatusController =
      StreamController<bool>.broadcast();

  bool _isInitialized = false;
  bool _isPWAInstallAvailable = false;
  bool _isOnline = true;

  /// PWA安装可用状态流
  Stream<bool> get pwaInstallAvailable => _pwaInstallAvailableController.stream;

  /// 键盘快捷键事件流
  Stream<String> get keyboardShortcuts => _keyboardShortcutController.stream;

  /// 在线状态流
  Stream<bool> get onlineStatus => _onlineStatusController.stream;

  /// 是否为PWA安装可用
  bool get isPWAInstallAvailable => _isPWAInstallAvailable;

  /// 是否在线
  bool get isOnline => _isOnline;

  /// 初始化Web平台服务
  Future<void> initialize() async {
    if (_isInitialized || !kIsWeb) return;

    try {
      // 监听PWA安装提示事件
      _setupPWAInstallListener();

      // 监听键盘快捷键
      _setupKeyboardShortcuts();

      // 监听在线状态变化
      _setupOnlineStatusListener();

      // 设置页面可见性变化监听
      _setupVisibilityChangeListener();

      // 设置页面标题和元数据
      _updatePageMetadata();

      _isInitialized = true;
      print('WebPlatformService initialized successfully');
    } catch (e) {
      print('Error initializing WebPlatformService: $e');
    }
  }

  /// 设置PWA安装监听器
  void _setupPWAInstallListener() {
    if (!kIsWeb) return;

    // 监听PWA安装可用事件
    html.window.addEventListener('pwa-install-available', (event) {
      _isPWAInstallAvailable = true;
      _pwaInstallAvailableController.add(true);
    });
  }

  /// 设置键盘快捷键监听
  void _setupKeyboardShortcuts() {
    if (!kIsWeb) return;

    // 监听自定义键盘快捷键事件
    html.window.addEventListener('quick-task-shortcut', (event) {
      _keyboardShortcutController.add('quick-task');
    });

    html.window.addEventListener('language-toggle-shortcut', (event) {
      _keyboardShortcutController.add('language-toggle');
    });

    html.window.addEventListener('pomodoro-shortcut', (event) {
      _keyboardShortcutController.add('pomodoro');
    });
  }

  /// 设置在线状态监听
  void _setupOnlineStatusListener() {
    if (!kIsWeb) return;

    // 监听在线状态变化
    html.window.addEventListener('online', (event) {
      _isOnline = true;
      _onlineStatusController.add(true);
    });

    html.window.addEventListener('offline', (event) {
      _isOnline = false;
      _onlineStatusController.add(false);
    });

    // 初始化在线状态
    _isOnline = html.window.navigator.onLine ?? true;
  }

  /// 设置页面可见性变化监听
  void _setupVisibilityChangeListener() {
    if (!kIsWeb) return;

    html.document.addEventListener('visibilitychange', (event) {
      final isVisible = !html.document.hidden!;
      if (isVisible) {
        // 页面变为可见时，可以执行一些操作
        _handlePageVisible();
      } else {
        // 页面变为隐藏时，可以执行一些操作
        _handlePageHidden();
      }
    });
  }

  /// 页面变为可见时的处理
  void _handlePageVisible() {
    // 可以在这里触发数据同步或刷新
    print('Page became visible');
  }

  /// 页面变为隐藏时的处理
  void _handlePageHidden() {
    // 可以在这里保存状态或暂停某些操作
    print('Page became hidden');
  }

  /// 更新页面元数据
  void _updatePageMetadata() {
    if (!kIsWeb) return;

    try {
      // 更新页面标题
      html.document.title = 'Prvin AI智能日历 - 现代化日程管理应用';

      // 更新meta描述
      final metaDescription = html.document.querySelector(
        'meta[name="description"]',
      );
      if (metaDescription != null) {
        metaDescription.setAttribute(
          'content',
          'Prvin AI智能日历 - 集成AI功能的现代化日程管理应用，支持任务管理、番茄钟专注、一键语言切换等功能',
        );
      }
    } catch (e) {
      print('Error updating page metadata: $e');
    }
  }

  /// 提示安装PWA
  Future<bool> promptPWAInstall() async {
    if (!kIsWeb || !_isPWAInstallAvailable) return false;

    try {
      // 调用JavaScript函数来显示安装提示
      final result = html.window.callMethod('installPWA');
      return result == true;
    } catch (e) {
      print('Error prompting PWA install: $e');
      return false;
    }
  }

  /// 检查是否已安装PWA
  bool isPWAInstalled() {
    if (!kIsWeb) return false;

    try {
      // 检查是否在standalone模式下运行
      final mediaQuery = html.window.matchMedia('(display-mode: standalone)');
      return mediaQuery.matches;
    } catch (e) {
      print('Error checking PWA install status: $e');
      return false;
    }
  }

  /// 复制文本到剪贴板
  Future<bool> copyToClipboard(String text) async {
    if (!kIsWeb) return false;

    try {
      await html.window.navigator.clipboard?.writeText(text);
      return true;
    } catch (e) {
      // 降级到旧的方法
      try {
        final textArea = html.TextAreaElement();
        textArea.value = text;
        html.document.body?.append(textArea);
        textArea.select();
        html.document.execCommand('copy');
        textArea.remove();
        return true;
      } catch (e2) {
        print('Error copying to clipboard: $e2');
        return false;
      }
    }
  }

  /// 从剪贴板读取文本
  Future<String?> readFromClipboard() async {
    if (!kIsWeb) return null;

    try {
      return await html.window.navigator.clipboard?.readText();
    } catch (e) {
      print('Error reading from clipboard: $e');
      return null;
    }
  }

  /// 显示浏览器通知
  Future<bool> showNotification({
    required String title,
    String? body,
    String? icon,
    String? tag,
  }) async {
    if (!kIsWeb) return false;

    try {
      // 请求通知权限
      final permission = await html.Notification.requestPermission();
      if (permission != 'granted') return false;

      // 显示通知
      final notification = html.Notification(
        title,
        body: body,
        icon: icon,
        tag: tag,
      );

      // 设置点击事件
      notification.onClick.listen((event) {
        html.window.focus();
        notification.close();
      });

      // 自动关闭通知
      Timer(const Duration(seconds: 5), notification.close);

      return true;
    } catch (e) {
      print('Error showing notification: $e');
      return false;
    }
  }

  /// 获取设备信息
  Map<String, dynamic> getDeviceInfo() {
    if (!kIsWeb) return {};

    try {
      final navigator = html.window.navigator;
      return {
        'userAgent': navigator.userAgent,
        'platform': navigator.platform,
        'language': navigator.language,
        'languages': navigator.languages,
        'cookieEnabled': navigator.cookieEnabled,
        'onLine': navigator.onLine,
        'hardwareConcurrency': navigator.hardwareConcurrency,
        'maxTouchPoints': navigator.maxTouchPoints,
      };
    } catch (e) {
      print('Error getting device info: $e');
      return {};
    }
  }

  /// 获取屏幕信息
  Map<String, dynamic> getScreenInfo() {
    if (!kIsWeb) return {};

    try {
      final screen = html.window.screen;
      return {
        'width': screen?.width,
        'height': screen?.height,
        'availWidth': screen?.availWidth,
        'availHeight': screen?.availHeight,
        'colorDepth': screen?.colorDepth,
        'pixelDepth': screen?.pixelDepth,
      };
    } catch (e) {
      print('Error getting screen info: $e');
      return {};
    }
  }

  /// 设置页面标题
  void setPageTitle(String title) {
    if (!kIsWeb) return;

    try {
      html.document.title = title;
    } catch (e) {
      print('Error setting page title: $e');
    }
  }

  /// 设置页面favicon
  void setPageFavicon(String iconUrl) {
    if (!kIsWeb) return;

    try {
      final link =
          html.document.querySelector('link[rel="icon"]') as html.LinkElement?;
      if (link != null) {
        link.href = iconUrl;
      }
    } catch (e) {
      print('Error setting page favicon: $e');
    }
  }

  /// 处理URL参数
  Map<String, String> getUrlParameters() {
    if (!kIsWeb) return {};

    try {
      final uri = Uri.parse(html.window.location.href);
      return uri.queryParameters;
    } catch (e) {
      print('Error getting URL parameters: $e');
      return {};
    }
  }

  /// 更新URL参数（不刷新页面）
  void updateUrlParameters(Map<String, String> parameters) {
    if (!kIsWeb) return;

    try {
      final uri = Uri.parse(html.window.location.href);
      final newUri = uri.replace(queryParameters: parameters);
      html.window.history.pushState(null, '', newUri.toString());
    } catch (e) {
      print('Error updating URL parameters: $e');
    }
  }

  /// 释放资源
  void dispose() {
    _pwaInstallAvailableController.close();
    _keyboardShortcutController.close();
    _onlineStatusController.close();
  }
}
