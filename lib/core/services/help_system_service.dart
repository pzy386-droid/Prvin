import 'dart:async';

import 'package:flutter/material.dart';
import 'package:prvin/core/localization/localization_exports.dart';

/// 帮助系统服务
/// 提供应用内引导教程和上下文相关的帮助提示
class HelpSystemService {
  static final HelpSystemService _instance = HelpSystemService._internal();
  factory HelpSystemService() => _instance;
  HelpSystemService._internal();

  static HelpSystemService get instance => _instance;

  final StreamController<HelpEvent> _helpEventController =
      StreamController<HelpEvent>.broadcast();

  /// 帮助事件流
  Stream<HelpEvent> get helpEvents => _helpEventController.stream;

  /// 当前显示的帮助提示
  HelpTip? _currentTip;

  /// 用户是否已完成首次引导
  bool _hasCompletedOnboarding = false;

  /// 获取用户是否已完成首次引导
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;

  /// 帮助提示显示状态
  bool _isShowingTip = false;

  /// 初始化帮助系统
  Future<void> initialize() async {
    // 从本地存储读取用户引导状态
    // 这里可以集成SharedPreferences
    _hasCompletedOnboarding = false; // 暂时设为false用于演示
  }

  /// 显示首次使用引导
  void showOnboarding(BuildContext context) {
    if (_hasCompletedOnboarding) return;

    _helpEventController.add(
      HelpEvent.showOnboarding(steps: _getOnboardingSteps(context)),
    );
  }

  /// 显示上下文相关的帮助提示
  void showContextualHelp(
    BuildContext context,
    HelpContext helpContext, {
    Widget? targetWidget,
    Offset? position,
  }) {
    if (_isShowingTip) return;

    final tip = _getContextualTip(context, helpContext);
    if (tip != null) {
      _currentTip = tip;
      _isShowingTip = true;

      _helpEventController.add(
        HelpEvent.showTip(
          tip: tip,
          targetWidget: targetWidget,
          position: position,
        ),
      );
    }
  }

  /// 隐藏当前帮助提示
  void hideCurrentTip() {
    if (_currentTip != null) {
      _helpEventController.add(HelpEvent.hideTip(_currentTip!));
      _currentTip = null;
      _isShowingTip = false;
    }
  }

  /// 显示帮助页面
  void showHelpPage(BuildContext context, HelpPageType pageType) {
    _helpEventController.add(HelpEvent.showHelpPage(pageType: pageType));
  }

  /// 搜索帮助内容
  List<HelpSearchResult> searchHelp(String query, BuildContext context) {
    final results = <HelpSearchResult>[];
    final lowercaseQuery = query.toLowerCase();

    // 搜索帮助主题
    for (final topic in _getAllHelpTopics(context)) {
      if (topic.title.toLowerCase().contains(lowercaseQuery) ||
          topic.content.toLowerCase().contains(lowercaseQuery) ||
          topic.keywords.any((k) => k.toLowerCase().contains(lowercaseQuery))) {
        results.add(
          HelpSearchResult(
            topic: topic,
            relevanceScore: _calculateRelevance(topic, lowercaseQuery),
          ),
        );
      }
    }

    // 按相关性排序
    results.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
    return results;
  }

  /// 标记引导完成
  void markOnboardingCompleted() {
    _hasCompletedOnboarding = true;
    // 这里应该保存到本地存储
  }

  /// 重置引导状态（用于测试）
  void resetOnboarding() {
    _hasCompletedOnboarding = false;
  }

  /// 获取引导步骤
  List<OnboardingStep> _getOnboardingSteps(BuildContext context) {
    return [
      OnboardingStep(
        id: 'welcome',
        title: context.l10n(
          'onboarding_welcome_title',
          fallback: '欢迎使用Prvin AI日历',
        ),
        description: context.l10n(
          'onboarding_welcome_desc',
          fallback: '让我们快速了解一下主要功能',
        ),
        icon: Icons.waving_hand,
        color: const Color(0xFF4FC3F7),
      ),
      OnboardingStep(
        id: 'calendar_view',
        title: context.l10n('onboarding_calendar_title', fallback: '日历视图'),
        description: context.l10n(
          'onboarding_calendar_desc',
          fallback: '点击日期查看任务，拖拽任务可以移动到其他日期',
        ),
        icon: Icons.calendar_today,
        color: const Color(0xFF81C784),
      ),
      OnboardingStep(
        id: 'create_task',
        title: context.l10n('onboarding_task_title', fallback: '创建任务'),
        description: context.l10n(
          'onboarding_task_desc',
          fallback: '点击右下角的+按钮快速创建新任务',
        ),
        icon: Icons.add_task,
        color: const Color(0xFFFFB74D),
      ),
      OnboardingStep(
        id: 'pomodoro',
        title: context.l10n('onboarding_pomodoro_title', fallback: '番茄钟专注'),
        description: context.l10n(
          'onboarding_pomodoro_desc',
          fallback: '切换到专注页面开始番茄钟计时，提高工作效率',
        ),
        icon: Icons.timer,
        color: const Color(0xFFE57373),
      ),
      OnboardingStep(
        id: 'language_toggle',
        title: context.l10n('onboarding_language_title', fallback: '语言切换'),
        description: context.l10n(
          'onboarding_language_desc',
          fallback: '点击右上角的语言按钮可以快速切换中英文',
        ),
        icon: Icons.language,
        color: const Color(0xFFAB47BC),
      ),
    ];
  }

  /// 获取上下文相关的帮助提示
  HelpTip? _getContextualTip(BuildContext context, HelpContext helpContext) {
    switch (helpContext) {
      case HelpContext.calendarView:
        return HelpTip(
          id: 'calendar_help',
          title: context.l10n('help_calendar_title', fallback: '日历操作'),
          content: context.l10n(
            'help_calendar_content',
            fallback: '• 点击日期查看当天任务\n• 拖拽任务可以移动日期\n• 不同颜色代表不同任务类型',
          ),
          type: HelpTipType.info,
          actions: [
            HelpAction(
              label: context.l10n('got_it', fallback: '知道了'),
              onTap: hideCurrentTip,
            ),
          ],
        );

      case HelpContext.taskCreation:
        return HelpTip(
          id: 'task_creation_help',
          title: context.l10n('help_task_title', fallback: '创建任务'),
          content: context.l10n(
            'help_task_content',
            fallback: '• 填写任务标题和描述\n• 设置开始和结束时间\n• 选择任务类型和优先级\n• 添加标签便于分类',
          ),
          type: HelpTipType.tutorial,
          actions: [
            HelpAction(
              label: context.l10n('learn_more', fallback: '了解更多'),
              onTap: () => showHelpPage(context, HelpPageType.taskManagement),
            ),
            HelpAction(
              label: context.l10n('close', fallback: '关闭'),
              onTap: hideCurrentTip,
            ),
          ],
        );

      case HelpContext.pomodoroTimer:
        return HelpTip(
          id: 'pomodoro_help',
          title: context.l10n('help_pomodoro_title', fallback: '番茄钟专注'),
          content: context.l10n(
            'help_pomodoro_content',
            fallback: '• 点击开始按钮启动25分钟专注时间\n• 专注期间会阻止通知干扰\n• 完成后可以查看专注统计',
          ),
          type: HelpTipType.tutorial,
          actions: [
            HelpAction(
              label: context.l10n('start_focus', fallback: '开始专注'),
              onTap: hideCurrentTip,
            ),
            HelpAction(
              label: context.l10n('close', fallback: '关闭'),
              onTap: hideCurrentTip,
            ),
          ],
        );

      case HelpContext.languageToggle:
        return HelpTip(
          id: 'language_help',
          title: context.l10n('help_language_title', fallback: '语言切换'),
          content: context.l10n(
            'help_language_content',
            fallback: '• 点击语言按钮快速切换中英文\n• 切换过程中保持所有数据不变\n• 语言设置会自动保存',
          ),
          type: HelpTipType.info,
          actions: [
            HelpAction(
              label: context.l10n('try_it', fallback: '试试看'),
              onTap: hideCurrentTip,
            ),
          ],
        );

      case HelpContext.aiFeatures:
        return HelpTip(
          id: 'ai_help',
          title: context.l10n('help_ai_title', fallback: 'AI智能功能'),
          content: context.l10n(
            'help_ai_content',
            fallback: '• AI会自动分析你的工作模式\n• 提供个性化的时间管理建议\n• 智能分类和标签建议',
          ),
          type: HelpTipType.feature,
          actions: [
            HelpAction(
              label: context.l10n('learn_more', fallback: '了解更多'),
              onTap: () => showHelpPage(context, HelpPageType.aiFeatures),
            ),
            HelpAction(
              label: context.l10n('close', fallback: '关闭'),
              onTap: hideCurrentTip,
            ),
          ],
        );
    }
  }

  /// 获取所有帮助主题
  List<HelpTopic> _getAllHelpTopics(BuildContext context) {
    return [
      HelpTopic(
        id: 'calendar_basics',
        title: context.l10n('help_topic_calendar', fallback: '日历基础操作'),
        content: context.l10n(
          'help_topic_calendar_content',
          fallback: '学习如何使用日历视图、创建任务、管理日程等基础功能。',
        ),
        category: HelpCategory.basics,
        keywords: ['日历', 'calendar', '任务', 'task', '基础'],
      ),
      HelpTopic(
        id: 'task_management',
        title: context.l10n('help_topic_tasks', fallback: '任务管理'),
        content: context.l10n(
          'help_topic_tasks_content',
          fallback: '了解如何创建、编辑、分类和管理你的任务，提高工作效率。',
        ),
        category: HelpCategory.features,
        keywords: ['任务', 'task', '管理', 'management', '编辑'],
      ),
      HelpTopic(
        id: 'pomodoro_technique',
        title: context.l10n('help_topic_pomodoro', fallback: '番茄钟专注法'),
        content: context.l10n(
          'help_topic_pomodoro_content',
          fallback: '学习如何使用番茄钟技术提高专注力和工作效率。',
        ),
        category: HelpCategory.features,
        keywords: ['番茄钟', 'pomodoro', '专注', 'focus', '效率'],
      ),
      HelpTopic(
        id: 'ai_features',
        title: context.l10n('help_topic_ai', fallback: 'AI智能功能'),
        content: context.l10n(
          'help_topic_ai_content',
          fallback: '探索AI如何帮助你更好地管理时间和提高生产力。',
        ),
        category: HelpCategory.advanced,
        keywords: ['AI', '人工智能', '智能', '分析', 'analysis'],
      ),
      HelpTopic(
        id: 'language_switching',
        title: context.l10n('help_topic_language', fallback: '语言切换'),
        content: context.l10n(
          'help_topic_language_content',
          fallback: '了解如何快速切换应用语言，支持中文和英文。',
        ),
        category: HelpCategory.settings,
        keywords: ['语言', 'language', '切换', 'switch', '中文', '英文'],
      ),
    ];
  }

  /// 计算搜索相关性
  double _calculateRelevance(HelpTopic topic, String query) {
    double score = 0.0;

    // 标题匹配权重最高
    if (topic.title.toLowerCase().contains(query)) {
      score += 10.0;
    }

    // 内容匹配
    if (topic.content.toLowerCase().contains(query)) {
      score += 5.0;
    }

    // 关键词匹配
    for (final keyword in topic.keywords) {
      if (keyword.toLowerCase().contains(query)) {
        score += 3.0;
      }
    }

    return score;
  }

  /// 释放资源
  void dispose() {
    _helpEventController.close();
  }
}

/// 帮助事件
abstract class HelpEvent {
  const HelpEvent();

  factory HelpEvent.showOnboarding({required List<OnboardingStep> steps}) =
      ShowOnboardingEvent;

  factory HelpEvent.showTip({
    required HelpTip tip,
    Widget? targetWidget,
    Offset? position,
  }) = ShowTipEvent;

  factory HelpEvent.hideTip(HelpTip tip) = HideTipEvent;

  factory HelpEvent.showHelpPage({required HelpPageType pageType}) =
      ShowHelpPageEvent;
}

/// 显示引导事件
class ShowOnboardingEvent extends HelpEvent {
  const ShowOnboardingEvent({required this.steps});
  final List<OnboardingStep> steps;
}

/// 显示提示事件
class ShowTipEvent extends HelpEvent {
  const ShowTipEvent({required this.tip, this.targetWidget, this.position});
  final HelpTip tip;
  final Widget? targetWidget;
  final Offset? position;
}

/// 隐藏提示事件
class HideTipEvent extends HelpEvent {
  const HideTipEvent(this.tip);
  final HelpTip tip;
}

/// 显示帮助页面事件
class ShowHelpPageEvent extends HelpEvent {
  const ShowHelpPageEvent({required this.pageType});
  final HelpPageType pageType;
}

/// 引导步骤
class OnboardingStep {
  const OnboardingStep({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
}

/// 帮助提示
class HelpTip {
  const HelpTip({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.actions,
  });

  final String id;
  final String title;
  final String content;
  final HelpTipType type;
  final List<HelpAction> actions;
}

/// 帮助操作
class HelpAction {
  const HelpAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;
}

/// 帮助主题
class HelpTopic {
  const HelpTopic({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.keywords,
  });

  final String id;
  final String title;
  final String content;
  final HelpCategory category;
  final List<String> keywords;
}

/// 帮助搜索结果
class HelpSearchResult {
  const HelpSearchResult({required this.topic, required this.relevanceScore});

  final HelpTopic topic;
  final double relevanceScore;
}

/// 帮助上下文
enum HelpContext {
  calendarView,
  taskCreation,
  pomodoroTimer,
  languageToggle,
  aiFeatures,
}

/// 帮助提示类型
enum HelpTipType { info, tutorial, feature, warning }

/// 帮助页面类型
enum HelpPageType {
  overview,
  taskManagement,
  pomodoroGuide,
  aiFeatures,
  languageSettings,
  troubleshooting,
}

/// 帮助分类
enum HelpCategory { basics, features, advanced, settings, troubleshooting }
