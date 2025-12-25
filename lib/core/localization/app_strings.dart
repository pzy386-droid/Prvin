/// 应用字符串常量定义
///
/// 这个文件定义了应用中所有需要本地化的字符串
/// 采用分类管理，便于维护和扩展
class AppStrings {
  // 私有构造函数，防止实例化
  AppStrings._();

  /// 所有本地化字符串的映射表
  static const Map<String, Map<String, String>> _localizedValues = {
    // 中文（默认）
    'zh': {
      // 应用基础信息
      'app_name': 'Prvin AI日历',
      'app_subtitle': 'AI智能日程表应用',

      // 导航和标签
      'calendar': '日历',
      'focus': '专注',
      'today': '今天',
      'settings': '设置',

      // 按钮文本
      'start': '开始',
      'pause': '暂停',
      'reset': '重置',
      'save': '保存',
      'cancel': '取消',
      'close': '关闭',
      'retry': '重试',
      'edit': '编辑',
      'delete': '删除',
      'create': '创建',
      'confirm': '确认',

      // 状态文本
      'loading': '加载中...',
      'completed': '已完成',
      'pending': '待处理',
      'in_progress': '进行中',
      'cancelled': '已取消',

      // 错误和提示消息
      'app_startup_failed': '应用启动失败',
      'operation_failed': '操作失败',
      'network_error': '网络错误',
      'unknown_error': '未知错误',

      // 任务相关
      'task': '任务',
      'tasks': '任务',
      'create_task': '创建任务',
      'edit_task': '编辑任务',
      'delete_task': '删除任务',
      'task_title': '任务标题',
      'task_description': '任务描述',
      'no_tasks': '暂无任务',
      'no_tasks_hint': '点击右下角按钮创建第一个任务',
      'today_tasks': '今天的任务',
      'task_created_success': '任务创建成功',

      // 番茄钟相关
      'pomodoro': '番茄钟',
      'focus_time': '专注时间',
      'break_time': '休息时间',
      'pomodoro_settings': '番茄钟设置',
      'work_duration': '专注时间',
      'short_break': '短休息',
      'long_break': '长休息',
      'focus_preparing': '准备开始专注',
      'focus_in_progress': '专注进行中...',
      'focus_paused': '已暂停',
      'focus_completed': '专注完成！',
      'focus_completed_title': '🎉 专注时间完成！',
      'focus_completed_message': '恭喜你完成了一个番茄钟！现在可以休息一下。',
      'start_break': '开始休息',
      'continue_focus': '继续专注',

      // 统计相关
      'statistics': '统计',
      'daily_focus_time': '今日专注时间',
      'weekly_focus_time': '本周专注时间',
      'completed_pomodoros': '完成的番茄钟',
      'minutes': '分钟',
      'hours': '小时',

      // 日历相关
      'calendar_view': '日历视图',
      'month_view': '月视图',
      'week_view': '周视图',
      'day_view': '日视图',
      'search_placeholder': '搜索功能开发中...',

      // 时间相关
      'start_time': '开始时间',
      'end_time': '结束时间',
      'duration': '时长',
      'all_day': '全天',

      // 优先级
      'priority': '优先级',
      'priority_low': '低',
      'priority_medium': '中',
      'priority_high': '高',
      'priority_urgent': '紧急',

      // 分类
      'category': '分类',
      'category_work': '工作',
      'category_personal': '个人',
      'category_health': '健康',
      'category_learning': '学习',
      'category_social': '社交',

      // 语言设置
      'language': '语言',
      'language_settings': '语言设置',
      'chinese': '中文',
      'english': 'English',

      // AI功能相关
      'ai_analytics': 'AI 数据分析',
      'ai_analytics_subtitle': '智能分析您的工作模式',
      'ai_suggestions': 'AI智能建议',
      'ai_recommendations': 'AI 专注建议',
      'task_patterns': '任务模式分析',
      'time_distribution': '时间分配',
      'productivity_trends': '生产力趋势',
      'focus_recommendations': '专注建议',
      'no_ai_suggestions': '暂无AI建议',
      'no_ai_suggestions_hint': '使用应用一段时间后，AI将为您生成个性化建议',
      'no_time_distribution_data': '暂无时间分配数据',
      'no_task_patterns_data': '暂无任务模式数据',
      'no_task_patterns_hint': '完成更多任务后，AI将为您识别任务模式',
      'no_trends_data': '暂无趋势数据',
      'analyzing_data': '正在分析您的数据...',
      'start_analysis': '开始分析',
      'refresh_analysis': '刷新分析',
      'similar_tasks': '相似任务',
      'suggested_tags': '建议标签',
      'confidence': '置信度',
      'apply_suggestion': '应用建议',
      'best_time': '最佳时间',
      'recommended_duration': '建议时长',
      'minutes_short': '分钟',
      'hours_short': '小时',
      'average_tasks': '平均任务',
      'average_efficiency': '平均效率',
      'focus_time_total': '专注时间',
      'tasks_per_day': '个/天',
      'efficiency_score': '分',
      'completion_rate': '完成率',
      'total_work_time': '总工作时间',
      'most_active_category': '最活跃分类',
      'data_overview': '数据概览',

      // 同步功能相关
      'sync_settings': '同步设置',
      'external_calendar': '外部日历',
      'google_calendar': 'Google 日历',
      'outlook_calendar': 'Outlook 日历',
      'sync_status': '同步状态',
      'sync_enabled': '同步已启用',
      'sync_disabled': '同步已禁用',
      'last_sync': '上次同步',
      'sync_now': '立即同步',
      'sync_conflict': '同步冲突',
      'resolve_conflict': '解决冲突',
      'sync_error': '同步错误',
      'offline_mode': '离线模式',
      'online_mode': '在线模式',
      'connection_lost': '连接丢失',
      'connection_restored': '连接已恢复',

      // Web平台相关
      'install_pwa': '安装应用',
      'pwa_install_prompt': '将此应用安装到您的设备',
      'pwa_installed': '应用已安装',
      'offline_available': '离线可用',
      'update_available': '有可用更新',
      'keyboard_shortcuts': '键盘快捷键',
      'copy_to_clipboard': '复制到剪贴板',
      'copied_to_clipboard': '已复制到剪贴板',
      'paste_from_clipboard': '从剪贴板粘贴',
      'browser_notification': '浏览器通知',
      'notification_permission': '通知权限',
      'enable_notifications': '启用通知',

      // 可访问性相关
      'accessibility_mode': '无障碍模式',
      'high_contrast': '高对比度',
      'large_text': '大字体',
      'screen_reader': '屏幕阅读器',
      'keyboard_navigation': '键盘导航',
      'voice_control': '语音控制',
      'accessibility_settings': '无障碍设置',

      // 其他
      'no_description': '暂无描述',
      'empty_state_title': '这一天还没有任务',
      'empty_state_subtitle': '点击右下角的 + 按钮添加新的任务',
      'start_focus_time': '开始专注时间',
    },

    // 英文
    'en': {
      // 应用基础信息
      'app_name': 'Prvin AI Calendar',
      'app_subtitle': 'AI Smart Schedule Application',

      // 导航和标签
      'calendar': 'Calendar',
      'focus': 'Focus',
      'today': 'Today',
      'settings': 'Settings',

      // 按钮文本
      'start': 'Start',
      'pause': 'Pause',
      'reset': 'Reset',
      'save': 'Save',
      'cancel': 'Cancel',
      'close': 'Close',
      'retry': 'Retry',
      'edit': 'Edit',
      'delete': 'Delete',
      'create': 'Create',
      'confirm': 'Confirm',

      // 状态文本
      'loading': 'Loading...',
      'completed': 'Completed',
      'pending': 'Pending',
      'in_progress': 'In Progress',
      'cancelled': 'Cancelled',

      // 错误和提示消息
      'app_startup_failed': 'App Startup Failed',
      'operation_failed': 'Operation Failed',
      'network_error': 'Network Error',
      'unknown_error': 'Unknown Error',

      // 任务相关
      'task': 'Task',
      'tasks': 'Tasks',
      'create_task': 'Create Task',
      'edit_task': 'Edit Task',
      'delete_task': 'Delete Task',
      'task_title': 'Task Title',
      'task_description': 'Task Description',
      'no_tasks': 'No Tasks',
      'no_tasks_hint': 'Tap the + button to create your first task',
      'today_tasks': "Today's Tasks",
      'task_created_success': 'Task Created Successfully',

      // 番茄钟相关
      'pomodoro': 'Pomodoro',
      'focus_time': 'Focus Time',
      'break_time': 'Break Time',
      'pomodoro_settings': 'Pomodoro Settings',
      'work_duration': 'Work Duration',
      'short_break': 'Short Break',
      'long_break': 'Long Break',
      'focus_preparing': 'Ready to Focus',
      'focus_in_progress': 'Focusing...',
      'focus_paused': 'Paused',
      'focus_completed': 'Focus Completed!',
      'focus_completed_title': '🎉 Focus Session Complete!',
      'focus_completed_message':
          "Congratulations! You've completed a pomodoro session. Time for a break.",
      'start_break': 'Start Break',
      'continue_focus': 'Continue Focus',

      // 统计相关
      'statistics': 'Statistics',
      'daily_focus_time': 'Daily Focus Time',
      'weekly_focus_time': 'Weekly Focus Time',
      'completed_pomodoros': 'Completed Pomodoros',
      'minutes': 'minutes',
      'hours': 'hours',

      // 日历相关
      'calendar_view': 'Calendar View',
      'month_view': 'Month View',
      'week_view': 'Week View',
      'day_view': 'Day View',
      'search_placeholder': 'Search feature coming soon...',

      // 时间相关
      'start_time': 'Start Time',
      'end_time': 'End Time',
      'duration': 'Duration',
      'all_day': 'All Day',

      // 优先级
      'priority': 'Priority',
      'priority_low': 'Low',
      'priority_medium': 'Medium',
      'priority_high': 'High',
      'priority_urgent': 'Urgent',

      // 分类
      'category': 'Category',
      'category_work': 'Work',
      'category_personal': 'Personal',
      'category_health': 'Health',
      'category_learning': 'Learning',
      'category_social': 'Social',

      // 语言设置
      'language': 'Language',
      'language_settings': 'Language Settings',
      'chinese': '中文',
      'english': 'English',

      // AI Features
      'ai_analytics': 'AI Data Analysis',
      'ai_analytics_subtitle': 'Intelligent analysis of your work patterns',
      'ai_suggestions': 'AI Smart Suggestions',
      'ai_recommendations': 'AI Focus Recommendations',
      'task_patterns': 'Task Pattern Analysis',
      'time_distribution': 'Time Distribution',
      'productivity_trends': 'Productivity Trends',
      'focus_recommendations': 'Focus Recommendations',
      'no_ai_suggestions': 'No AI Suggestions',
      'no_ai_suggestions_hint':
          'Use the app for a while and AI will generate personalized suggestions for you',
      'no_time_distribution_data': 'No time distribution data',
      'no_task_patterns_data': 'No task pattern data',
      'no_task_patterns_hint':
          'Complete more tasks and AI will identify task patterns for you',
      'no_trends_data': 'No trend data',
      'analyzing_data': 'Analyzing your data...',
      'start_analysis': 'Start Analysis',
      'refresh_analysis': 'Refresh Analysis',
      'similar_tasks': 'Similar Tasks',
      'suggested_tags': 'Suggested Tags',
      'confidence': 'Confidence',
      'apply_suggestion': 'Apply Suggestion',
      'best_time': 'Best Time',
      'recommended_duration': 'Recommended Duration',
      'minutes_short': 'minutes',
      'hours_short': 'hours',
      'average_tasks': 'Average Tasks',
      'average_efficiency': 'Average Efficiency',
      'focus_time_total': 'Focus Time',
      'tasks_per_day': 'tasks/day',
      'efficiency_score': 'points',
      'completion_rate': 'Completion Rate',
      'total_work_time': 'Total Work Time',
      'most_active_category': 'Most Active Category',
      'data_overview': 'Data Overview',

      // Sync Features
      'sync_settings': 'Sync Settings',
      'external_calendar': 'External Calendar',
      'google_calendar': 'Google Calendar',
      'outlook_calendar': 'Outlook Calendar',
      'sync_status': 'Sync Status',
      'sync_enabled': 'Sync Enabled',
      'sync_disabled': 'Sync Disabled',
      'last_sync': 'Last Sync',
      'sync_now': 'Sync Now',
      'sync_conflict': 'Sync Conflict',
      'resolve_conflict': 'Resolve Conflict',
      'sync_error': 'Sync Error',
      'offline_mode': 'Offline Mode',
      'online_mode': 'Online Mode',
      'connection_lost': 'Connection Lost',
      'connection_restored': 'Connection Restored',

      // Web Platform Features
      'install_pwa': 'Install App',
      'pwa_install_prompt': 'Install this app to your device',
      'pwa_installed': 'App Installed',
      'offline_available': 'Available Offline',
      'update_available': 'Update Available',
      'keyboard_shortcuts': 'Keyboard Shortcuts',
      'copy_to_clipboard': 'Copy to Clipboard',
      'copied_to_clipboard': 'Copied to Clipboard',
      'paste_from_clipboard': 'Paste from Clipboard',
      'browser_notification': 'Browser Notification',
      'notification_permission': 'Notification Permission',
      'enable_notifications': 'Enable Notifications',

      // Accessibility Features
      'accessibility_mode': 'Accessibility Mode',
      'high_contrast': 'High Contrast',
      'large_text': 'Large Text',
      'screen_reader': 'Screen Reader',
      'keyboard_navigation': 'Keyboard Navigation',
      'voice_control': 'Voice Control',
      'accessibility_settings': 'Accessibility Settings',

      // 其他
      'no_description': 'No Description',
      'empty_state_title': 'No tasks for this day',
      'empty_state_subtitle':
          'Tap the + button in the bottom right to add a new task',
      'start_focus_time': 'Start Focus Time',
    },
  };

  /// 获取本地化字符串映射表
  static Map<String, Map<String, String>> get localizedValues =>
      _localizedValues;

  /// 获取支持的语言列表
  static List<String> get supportedLocales => _localizedValues.keys.toList();

  /// 检查是否支持指定语言
  static bool isLocaleSupported(String locale) =>
      _localizedValues.containsKey(locale);
}
