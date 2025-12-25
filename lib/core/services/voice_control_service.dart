import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 语音控制命令枚举
enum VoiceCommand {
  /// 切换语言
  toggleLanguage('切换语言', 'switch language'),

  /// 创建任务
  createTask('创建任务', 'create task'),

  /// 开始番茄钟
  startPomodoro('开始番茄钟', 'start pomodoro'),

  /// 停止番茄钟
  stopPomodoro('停止番茄钟', 'stop pomodoro'),

  /// 查看日历
  viewCalendar('查看日历', 'view calendar'),

  /// 返回主页
  goHome('返回主页', 'go home'),

  /// 帮助
  help('帮助', 'help');

  const VoiceCommand(this.chinesePhrase, this.englishPhrase);

  /// 中文语音命令
  final String chinesePhrase;

  /// 英文语音命令
  final String englishPhrase;

  /// 根据语言获取命令短语
  String getPhrase(String languageCode) {
    return languageCode == 'zh' ? chinesePhrase : englishPhrase;
  }

  /// 从文本识别命令
  static VoiceCommand? fromText(String text, String languageCode) {
    final normalizedText = text.toLowerCase().trim();

    for (final command in VoiceCommand.values) {
      final phrase = command.getPhrase(languageCode).toLowerCase();
      if (normalizedText.contains(phrase) || phrase.contains(normalizedText)) {
        return command;
      }
    }

    return null;
  }
}

/// 语音识别状态
enum VoiceRecognitionState {
  /// 未初始化
  uninitialized,

  /// 准备就绪
  ready,

  /// 正在监听
  listening,

  /// 处理中
  processing,

  /// 错误状态
  error,

  /// 不可用
  unavailable,
}

/// 语音识别结果
class VoiceRecognitionResult {
  const VoiceRecognitionResult({
    required this.text,
    required this.confidence,
    this.command,
    this.isPartial = false,
  });

  /// 识别的文本
  final String text;

  /// 置信度 (0.0 - 1.0)
  final double confidence;

  /// 识别的命令（如果有）
  final VoiceCommand? command;

  /// 是否为部分结果
  final bool isPartial;

  @override
  String toString() {
    return 'VoiceRecognitionResult(text: $text, confidence: $confidence, command: $command, isPartial: $isPartial)';
  }
}

/// 语音控制服务
///
/// 提供基础的语音识别和命令处理功能
/// 注意：这是一个基础实现，实际项目中需要集成具体的语音识别SDK
class VoiceControlService extends ChangeNotifier {

  VoiceControlService._();
  static VoiceControlService? _instance;

  /// 获取单例实例
  static VoiceControlService get instance {
    _instance ??= VoiceControlService._();
    return _instance!;
  }

  /// 当前状态
  VoiceRecognitionState _state = VoiceRecognitionState.uninitialized;
  VoiceRecognitionState get state => _state;

  /// 是否可用
  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  /// 当前语言代码
  String _currentLanguage = 'zh';
  String get currentLanguage => _currentLanguage;

  /// 语音识别结果流
  final StreamController<VoiceRecognitionResult> _resultController =
      StreamController<VoiceRecognitionResult>.broadcast();
  Stream<VoiceRecognitionResult> get resultStream => _resultController.stream;

  /// 命令执行回调
  final Map<VoiceCommand, VoidCallback> _commandCallbacks = {};

  /// 初始化语音控制服务
  Future<bool> initialize() async {
    try {
      _setState(VoiceRecognitionState.processing);

      // 检查平台支持
      if (!_isPlatformSupported()) {
        _setState(VoiceRecognitionState.unavailable);
        return false;
      }

      // 检查权限
      final hasPermission = await _checkPermissions();
      if (!hasPermission) {
        _setState(VoiceRecognitionState.unavailable);
        return false;
      }

      // 模拟初始化过程
      await Future.delayed(const Duration(milliseconds: 500));

      _isAvailable = true;
      _setState(VoiceRecognitionState.ready);

      debugPrint('VoiceControlService: Initialized successfully');
      return true;
    } catch (e) {
      debugPrint('VoiceControlService: Initialization failed: $e');
      _setState(VoiceRecognitionState.error);
      return false;
    }
  }

  /// 开始语音识别
  Future<bool> startListening() async {
    if (_state != VoiceRecognitionState.ready) {
      debugPrint('VoiceControlService: Cannot start listening, state: $_state');
      return false;
    }

    try {
      _setState(VoiceRecognitionState.listening);

      // 模拟语音识别过程
      _simulateVoiceRecognition();

      debugPrint('VoiceControlService: Started listening');
      return true;
    } catch (e) {
      debugPrint('VoiceControlService: Failed to start listening: $e');
      _setState(VoiceRecognitionState.error);
      return false;
    }
  }

  /// 停止语音识别
  Future<void> stopListening() async {
    if (_state != VoiceRecognitionState.listening) {
      return;
    }

    try {
      _setState(VoiceRecognitionState.ready);
      debugPrint('VoiceControlService: Stopped listening');
    } catch (e) {
      debugPrint('VoiceControlService: Failed to stop listening: $e');
      _setState(VoiceRecognitionState.error);
    }
  }

  /// 设置语言
  void setLanguage(String languageCode) {
    if (_currentLanguage != languageCode) {
      _currentLanguage = languageCode;
      debugPrint('VoiceControlService: Language set to $languageCode');
      notifyListeners();
    }
  }

  /// 注册命令回调
  void registerCommand(VoiceCommand command, VoidCallback callback) {
    _commandCallbacks[command] = callback;
    debugPrint('VoiceControlService: Registered callback for ${command.name}');
  }

  /// 注销命令回调
  void unregisterCommand(VoiceCommand command) {
    _commandCallbacks.remove(command);
    debugPrint(
      'VoiceControlService: Unregistered callback for ${command.name}',
    );
  }

  /// 执行命令
  void executeCommand(VoiceCommand command) {
    final callback = _commandCallbacks[command];
    if (callback != null) {
      debugPrint('VoiceControlService: Executing command: ${command.name}');
      callback();
    } else {
      debugPrint(
        'VoiceControlService: No callback registered for command: ${command.name}',
      );
    }
  }

  /// 处理语音识别结果
  void _handleRecognitionResult(String text, double confidence) {
    final command = VoiceCommand.fromText(text, _currentLanguage);

    final result = VoiceRecognitionResult(
      text: text,
      confidence: confidence,
      command: command,
    );

    _resultController.add(result);

    // 如果识别到命令且置信度足够高，执行命令
    if (command != null && confidence > 0.7) {
      executeCommand(command);
    }

    debugPrint('VoiceControlService: Recognition result: $result');
  }

  /// 模拟语音识别过程（实际项目中应该集成真实的语音识别SDK）
  void _simulateVoiceRecognition() {
    // 这里只是一个演示实现
    // 实际项目中应该集成如 speech_to_text 包或其他语音识别服务

    Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_state != VoiceRecognitionState.listening) {
        timer.cancel();
        return;
      }

      // 模拟随机识别结果
      const commands = VoiceCommand.values;
      final randomCommand =
          commands[DateTime.now().millisecond % commands.length];
      final phrase = randomCommand.getPhrase(_currentLanguage);

      // 模拟不同的置信度
      final confidence = 0.5 + (DateTime.now().millisecond % 50) / 100.0;

      // 只有在高置信度时才触发
      if (confidence > 0.8) {
        _handleRecognitionResult(phrase, confidence);
        timer.cancel();
        stopListening();
      }
    });
  }

  /// 检查平台支持
  bool _isPlatformSupported() {
    // 在实际项目中，这里应该检查具体的平台支持
    return !kIsWeb; // Web平台的语音识别支持有限
  }

  /// 检查权限
  Future<bool> _checkPermissions() async {
    try {
      // 在实际项目中，这里应该检查麦克风权限
      // 可以使用 permission_handler 包
      return true;
    } catch (e) {
      debugPrint('VoiceControlService: Permission check failed: $e');
      return false;
    }
  }

  /// 设置状态
  void _setState(VoiceRecognitionState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  /// 获取支持的命令列表
  List<VoiceCommand> getSupportedCommands() {
    return VoiceCommand.values;
  }

  /// 获取命令的语音短语
  String getCommandPhrase(VoiceCommand command) {
    return command.getPhrase(_currentLanguage);
  }

  /// 获取所有命令的语音短语
  Map<VoiceCommand, String> getAllCommandPhrases() {
    return Map.fromEntries(
      VoiceCommand.values.map(
        (command) => MapEntry(command, command.getPhrase(_currentLanguage)),
      ),
    );
  }

  /// 释放资源
  @override
  void dispose() {
    _resultController.close();
    _commandCallbacks.clear();
    super.dispose();
  }
}

/// 语音控制助手类
/// 提供便捷的语音控制功能集成
class VoiceControlHelper {
  /// 初始化语音控制
  static Future<bool> initialize() async {
    return VoiceControlService.instance.initialize();
  }

  /// 设置语言切换命令
  static void setupLanguageToggleCommand(VoidCallback onToggle) {
    VoiceControlService.instance.registerCommand(
      VoiceCommand.toggleLanguage,
      onToggle,
    );
  }

  /// 设置任务创建命令
  static void setupCreateTaskCommand(VoidCallback onCreate) {
    VoiceControlService.instance.registerCommand(
      VoiceCommand.createTask,
      onCreate,
    );
  }

  /// 设置番茄钟命令
  static void setupPomodoroCommands({
    required VoidCallback onStart,
    required VoidCallback onStop,
  }) {
    VoiceControlService.instance.registerCommand(
      VoiceCommand.startPomodoro,
      onStart,
    );
    VoiceControlService.instance.registerCommand(
      VoiceCommand.stopPomodoro,
      onStop,
    );
  }

  /// 设置导航命令
  static void setupNavigationCommands({
    required VoidCallback onViewCalendar,
    required VoidCallback onGoHome,
    required VoidCallback onHelp,
  }) {
    VoiceControlService.instance.registerCommand(
      VoiceCommand.viewCalendar,
      onViewCalendar,
    );
    VoiceControlService.instance.registerCommand(VoiceCommand.goHome, onGoHome);
    VoiceControlService.instance.registerCommand(VoiceCommand.help, onHelp);
  }

  /// 开始监听语音命令
  static Future<bool> startListening() async {
    return VoiceControlService.instance.startListening();
  }

  /// 停止监听语音命令
  static Future<void> stopListening() async {
    await VoiceControlService.instance.stopListening();
  }

  /// 检查语音控制是否可用
  static bool get isAvailable => VoiceControlService.instance.isAvailable;

  /// 获取当前状态
  static VoiceRecognitionState get state => VoiceControlService.instance.state;

  /// 监听识别结果
  static Stream<VoiceRecognitionResult> get resultStream =>
      VoiceControlService.instance.resultStream;

  /// 清理所有命令
  static void clearAllCommands() {
    for (final command in VoiceCommand.values) {
      VoiceControlService.instance.unregisterCommand(command);
    }
  }
}
