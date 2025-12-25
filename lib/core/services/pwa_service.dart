import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'package:flutter/foundation.dart';

/// PWA服务
/// 处理Progressive Web App相关功能
class PWAService {

  PWAService._();
  static PWAService? _instance;
  static PWAService get instance => _instance ??= PWAService._();

  final StreamController<bool> _installPromptController =
      StreamController<bool>.broadcast();
  final StreamController<String> _notificationController =
      StreamController<String>.broadcast();
  final StreamController<bool> _onlineStatusController =
      StreamController<bool>.broadcast();
  final StreamController<Map<String, dynamic>> _syncController =
      StreamController<Map<String, dynamic>>.broadcast();

  bool _isInitialized = false;
  bool _isInstallPromptAvailable = false;
  bool _isOnline = true;
  html.ServiceWorkerRegistration? _swRegistration;

  /// 安装提示可用状态流
  Stream<bool> get installPromptAvailable => _installPromptController.stream;

  /// 通知事件流
  Stream<String> get notifications => _notificationController.stream;

  /// 在线状态流
  Stream<bool> get onlineStatus => _onlineStatusController.stream;

  /// 同步事件流
  Stream<Map<String, dynamic>> get syncEvents => _syncController.stream;

  /// 是否可以显示安装提示
  bool get isInstallPromptAvailable => _isInstallPromptAvailable;

  /// 是否在线
  bool get isOnline => _isOnline;

  /// 是否已安装为PWA
  bool get isInstalled => _checkIfInstalled();

  /// 初始化PWA服务
  Future<void> initialize() async {
    if (_isInitialized || !kIsWeb) return;

    try {
      // 注册Service Worker
      await _registerServiceWorker();

      // 设置PWA事件监听器
      _setupPWAListeners();

      // 设置在线状态监听
      _setupOnlineStatusListener();

      // 设置通知权限
      await _setupNotifications();

      // 设置后台同步
      _setupBackgroundSync();

      _isInitialized = true;
      print('PWAService initialized successfully');
    } catch (e) {
      print('Error initializing PWAService: $e');
    }
  }

  /// 注册Service Worker
  Future<void> _registerServiceWorker() async {
    if (!kIsWeb) return;

    try {
      if (html.window.navigator.serviceWorker != null) {
        _swRegistration = await html.window.navigator.serviceWorker!.register(
          '/sw.js',
        );
        print('Service Worker registered successfully');

        // 监听Service Worker更新
        _swRegistration!.addEventListener('updatefound', (event) {
          print('Service Worker update found');
          _handleServiceWorkerUpdate();
        });

        // 监听Service Worker消息
        html.window.navigator.serviceWorker!.addEventListener('message', _handleServiceWorkerMessage);
      }
    } catch (e) {
      print('Failed to register Service Worker: $e');
    }
  }

  /// 设置PWA监听器
  void _setupPWAListeners() {
    if (!kIsWeb) return;

    // 监听安装提示事件
    html.window.addEventListener('beforeinstallprompt', (event) {
      event.preventDefault();
      _isInstallPromptAvailable = true;
      _installPromptController.add(true);
      print('PWA install prompt available');
    });

    // 监听应用安装事件
    html.window.addEventListener('appinstalled', (event) {
      _isInstallPromptAvailable = false;
      _installPromptController.add(false);
      print('PWA installed successfully');
    });
  }

  /// 设置在线状态监听
  void _setupOnlineStatusListener() {
    if (!kIsWeb) return;

    _isOnline = html.window.navigator.onLine ?? true;

    html.window.addEventListener('online', (event) {
      _isOnline = true;
      _onlineStatusController.add(true);
      print('App went online');
      _handleOnlineStatusChange(true);
    });

    html.window.addEventListener('offline', (event) {
      _isOnline = false;
      _onlineStatusController.add(false);
      print('App went offline');
      _handleOnlineStatusChange(false);
    });
  }

  /// 设置通知功能
  Future<void> _setupNotifications() async {
    if (!kIsWeb) return;

    try {
      if (html.Notification.supported) {
        final permission = html.Notification.permission;
        if (permission == 'default') {
          // 不主动请求权限，等用户需要时再请求
          print('Notification permission not requested yet');
        } else if (permission == 'granted') {
          print('Notification permission already granted');
        } else {
          print('Notification permission denied');
        }
      }
    } catch (e) {
      print('Error setting up notifications: $e');
    }
  }

  /// 设置后台同步
  void _setupBackgroundSync() {
    if (!kIsWeb || _swRegistration == null) return;

    try {
      // 注册后台同步
      _swRegistration!.sync?.register('background-sync');
      print('Background sync registered');
    } catch (e) {
      print('Failed to register background sync: $e');
    }
  }

  /// 处理Service Worker更新
  void _handleServiceWorkerUpdate() {
    // 可以在这里通知用户有新版本可用
    _notificationController.add('update_available');
  }

  /// 处理Service Worker消息
  void _handleServiceWorkerMessage(html.MessageEvent event) {
    final data = event.data;
    if (data is Map) {
      final type = data['type'];
      switch (type) {
        case 'BACKGROUND_SYNC_COMPLETE':
          _syncController.add({
            'type': 'sync_complete',
            'timestamp': data['timestamp'],
          });
        default:
          print('Unknown Service Worker message: $type');
      }
    }
  }

  /// 处理在线状态变化
  void _handleOnlineStatusChange(bool isOnline) {
    if (isOnline) {
      // 在线时触发数据同步
      _triggerBackgroundSync();
    }
  }

  /// 显示安装提示
  Future<bool> showInstallPrompt() async {
    if (!kIsWeb || !_isInstallPromptAvailable) return false;

    try {
      // 调用JavaScript函数显示安装提示
      final result = js.context.callMethod('installPWA');
      return result == true;
    } catch (e) {
      print('Error showing install prompt: $e');
      return false;
    }
  }

  /// 检查是否已安装为PWA
  bool _checkIfInstalled() {
    if (!kIsWeb) return false;

    try {
      // 检查是否在standalone模式下运行
      final mediaQuery = html.window.matchMedia('(display-mode: standalone)');
      return mediaQuery.matches;
    } catch (e) {
      return false;
    }
  }

  /// 请求通知权限
  Future<bool> requestNotificationPermission() async {
    if (!kIsWeb || !html.Notification.supported) return false;

    try {
      final permission = await html.Notification.requestPermission();
      return permission == 'granted';
    } catch (e) {
      print('Error requesting notification permission: $e');
      return false;
    }
  }

  /// 显示通知
  Future<bool> showNotification({
    required String title,
    String? body,
    String? icon,
    String? tag,
    List<Map<String, String>>? actions,
  }) async {
    if (!kIsWeb || !html.Notification.supported) return false;

    try {
      // 检查权限
      if (html.Notification.permission != 'granted') {
        final granted = await requestNotificationPermission();
        if (!granted) return false;
      }

      // 如果有Service Worker，使用Service Worker显示通知
      if (_swRegistration != null) {
        await _swRegistration!.showNotification(title, {
          'body': body,
          'icon': icon ?? '/icons/Icon-192.png',
          'badge': '/icons/Icon-192.png',
          'tag': tag ?? 'prvin-notification',
          'requireInteraction': false,
          'actions':
              actions ??
              [
                {'action': 'view', 'title': '查看'},
                {'action': 'dismiss', 'title': '忽略'},
              ],
        });
      } else {
        // 降级到普通通知
        final notification = html.Notification(
          title,
          body: body,
          icon: icon ?? '/icons/Icon-192.png',
          tag: tag,
        );

        // 设置点击事件
        notification.onClick.listen((event) {
          html.window.focus();
          notification.close();
        });

        // 自动关闭
        Timer(const Duration(seconds: 5), notification.close);
      }

      return true;
    } catch (e) {
      print('Error showing notification: $e');
      return false;
    }
  }

  /// 触发后台同步
  Future<void> _triggerBackgroundSync() async {
    if (!kIsWeb || _swRegistration == null) return;

    try {
      await _swRegistration!.sync?.register('background-sync');
      print('Background sync triggered');
    } catch (e) {
      print('Failed to trigger background sync: $e');
    }
  }

  /// 缓存指定的URLs
  Future<bool> cacheUrls(List<String> urls) async {
    if (!kIsWeb || _swRegistration == null) return false;

    try {
      final messageChannel = html.MessageChannel();
      final port1 = messageChannel.port1;
      final port2 = messageChannel.port2;

      final completer = Completer<bool>();

      port1.onMessage.listen((event) {
        final data = event.data;
        if (data is Map && data['type'] == 'URLS_CACHED') {
          completer.complete(data['success'] == true);
        }
      });

      _swRegistration!.active?.postMessage(
        {'type': 'CACHE_URLS', 'urls': urls},
        [port2],
      );

      return await completer.future.timeout(const Duration(seconds: 10));
    } catch (e) {
      print('Error caching URLs: $e');
      return false;
    }
  }

  /// 清理缓存
  Future<bool> clearCache() async {
    if (!kIsWeb || _swRegistration == null) return false;

    try {
      final messageChannel = html.MessageChannel();
      final port1 = messageChannel.port1;
      final port2 = messageChannel.port2;

      final completer = Completer<bool>();

      port1.onMessage.listen((event) {
        final data = event.data;
        if (data is Map && data['type'] == 'CACHE_CLEARED') {
          completer.complete(data['success'] == true);
        }
      });

      _swRegistration!.active?.postMessage({'type': 'CLEAR_CACHE'}, [port2]);

      return await completer.future.timeout(const Duration(seconds: 10));
    } catch (e) {
      print('Error clearing cache: $e');
      return false;
    }
  }

  /// 获取缓存版本
  Future<String?> getCacheVersion() async {
    if (!kIsWeb || _swRegistration == null) return null;

    try {
      final messageChannel = html.MessageChannel();
      final port1 = messageChannel.port1;
      final port2 = messageChannel.port2;

      final completer = Completer<String?>();

      port1.onMessage.listen((event) {
        final data = event.data;
        if (data is Map && data['type'] == 'VERSION') {
          completer.complete(data['version']);
        }
      });

      _swRegistration!.active?.postMessage({'type': 'GET_VERSION'}, [port2]);

      return await completer.future.timeout(const Duration(seconds: 5));
    } catch (e) {
      print('Error getting cache version: $e');
      return null;
    }
  }

  /// 更新Service Worker
  Future<void> updateServiceWorker() async {
    if (!kIsWeb || _swRegistration == null) return;

    try {
      await _swRegistration!.update();
      print('Service Worker update triggered');
    } catch (e) {
      print('Error updating Service Worker: $e');
    }
  }

  /// 跳过等待并激活新的Service Worker
  void skipWaiting() {
    if (!kIsWeb || _swRegistration == null) return;

    try {
      _swRegistration!.installing?.postMessage({'type': 'SKIP_WAITING'});
    } catch (e) {
      print('Error skipping waiting: $e');
    }
  }

  /// 释放资源
  void dispose() {
    _installPromptController.close();
    _notificationController.close();
    _onlineStatusController.close();
    _syncController.close();
  }
}
