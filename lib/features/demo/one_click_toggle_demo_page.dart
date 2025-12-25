import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prvin/core/bloc/app_bloc.dart';
import 'package:prvin/core/localization/localization_exports.dart';
import 'package:prvin/core/widgets/language_switcher.dart';
import 'package:prvin/core/widgets/one_click_language_toggle_button.dart';

/// 一键语言切换功能演示页面
///
/// 展示一键语言切换按钮的各种功能和用法，包括：
/// - 基本切换功能演示
/// - 性能监控和统计信息
/// - 错误处理演示
/// - 可访问性功能展示
/// - API使用示例
class OneClickToggleDemoPage extends StatefulWidget {
  const OneClickToggleDemoPage({super.key});

  @override
  State<OneClickToggleDemoPage> createState() => _OneClickToggleDemoPageState();
}

class _OneClickToggleDemoPageState extends State<OneClickToggleDemoPage> {
  final bool _showStatistics = false;
  bool _showPerformanceDetails = false;
  String _lastToggleResult = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n('language_settings', fallback: '一键语言切换演示')),
        backgroundColor: const Color(0xFF4FC3F7),
        foregroundColor: Colors.white,
        actions: [
          // 传统语言切换器作为对比
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => LanguageSwitcherDialog.show(context),
            tooltip: '传统语言切换器',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 功能介绍卡片
            _buildIntroductionCard(context),
            const SizedBox(height: 16),

            // 一键切换演示区域
            _buildToggleDemoCard(context),
            const SizedBox(height: 16),

            // 当前状态显示
            _buildCurrentStateCard(context),
            const SizedBox(height: 16),

            // 性能监控卡片
            _buildPerformanceCard(context),
            const SizedBox(height: 16),

            // 统计信息卡片
            if (_showStatistics) ...[
              _buildStatisticsCard(context),
              const SizedBox(height: 16),
            ],

            // API使用示例
            _buildApiExamplesCard(context),
            const SizedBox(height: 16),

            // 可访问性演示
            _buildAccessibilityCard(context),
            const SizedBox(height: 16),

            // 错误处理演示
            _buildErrorHandlingCard(context),
          ],
        ),
      ),
    );
  }

  /// 构建功能介绍卡片
  Widget _buildIntroductionCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFF4FC3F7),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  context.l10n('app_name', fallback: '功能介绍'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0277BD),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n(
                'language',
                fallback:
                    '一键语言切换功能让您可以通过点击按钮快速在中英文之间切换，'
                    '无需对话框确认，提供更流畅的用户体验。',
              ),
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF0277BD).withValues(alpha: 0.8),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            _buildFeatureList(context),
          ],
        ),
      ),
    );
  }

  /// 构建特性列表
  Widget _buildFeatureList(BuildContext context) {
    final features = [
      '⚡ 即时切换，无延迟',
      '🎯 一键操作，无需确认',
      '📱 直观显示当前语言状态',
      '♿ 完整的可访问性支持',
      '🛡️ 智能错误处理和恢复',
      '📊 性能监控和统计',
    ];

    return Column(
      children: features
          .map(
            (feature) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feature,
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF0277BD).withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  /// 构建一键切换演示卡片
  Widget _buildToggleDemoCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.touch_app, color: Color(0xFF4FC3F7), size: 24),
                const SizedBox(width: 12),
                Text(
                  context.l10n('language_settings', fallback: '一键切换演示'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0277BD),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 不同尺寸的按钮演示
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const OneClickLanguageToggleButton(size: 32),
                    const SizedBox(height: 8),
                    Text(
                      '小尺寸 (32px)',
                      style: TextStyle(
                        fontSize: 10,
                        color: const Color(0xFF0277BD).withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const OneClickLanguageToggleButton(),
                    const SizedBox(height: 8),
                    Text(
                      '标准尺寸 (40px)',
                      style: TextStyle(
                        fontSize: 10,
                        color: const Color(0xFF0277BD).withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const OneClickLanguageToggleButton(size: 48),
                    const SizedBox(height: 8),
                    Text(
                      '大尺寸 (48px)',
                      style: TextStyle(
                        fontSize: 10,
                        color: const Color(0xFF0277BD).withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 程序化切换按钮
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _performProgrammaticToggle(context),
                    icon: const Icon(Icons.code),
                    label: const Text('程序化切换'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4FC3F7),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _performMultipleToggles(context),
                    icon: const Icon(Icons.repeat),
                    label: const Text('连续切换测试'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0277BD),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            if (_lastToggleResult.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4FC3F7).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF4FC3F7).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  _lastToggleResult,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF0277BD),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建当前状态卡片
  Widget _buildCurrentStateCard(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final currentLanguage = state is AppReadyState
            ? state.languageCode
            : 'zh';
        final languageName = currentLanguage == 'zh' ? '中文' : 'English';

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.language,
                      color: Color(0xFF4FC3F7),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      context.l10n('language', fallback: '当前状态'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0277BD),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 语言状态显示
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4FC3F7).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF4FC3F7).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            currentLanguage == 'zh' ? '🇨🇳' : '🇺🇸',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            languageName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0277BD),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Code: $currentLanguage',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF0277BD).withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // 本地化文本演示
                _buildLocalizationDemo(context),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 构建本地化演示
  Widget _buildLocalizationDemo(BuildContext context) {
    final demoTexts = [
      ('app_name', 'Prvin AI日历'),
      ('calendar', '日历'),
      ('focus', '专注'),
      ('today', '今天'),
      ('create_task', '创建任务'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '本地化文本演示:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0277BD).withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 8),
        ...demoTexts.map(
          (demo) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    demo.$1,
                    style: TextStyle(
                      fontSize: 10,
                      color: const Color(0xFF0277BD).withValues(alpha: 0.5),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.l10n(demo.$1, fallback: demo.$2),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF0277BD),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 构建性能监控卡片
  Widget _buildPerformanceCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.speed, color: Color(0xFF4FC3F7), size: 24),
                const SizedBox(width: 12),
                Text(
                  context.l10n('language', fallback: '性能监控'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0277BD),
                  ),
                ),
                const Spacer(),
                Switch(
                  value: _showPerformanceDetails,
                  onChanged: (value) {
                    setState(() {
                      _showPerformanceDetails = value;
                    });
                  },
                  activeThumbColor: const Color(0xFF4FC3F7),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_showPerformanceDetails) ...[
              _buildPerformanceMetrics(context),
              const SizedBox(height: 12),
            ],

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _refreshPerformanceData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('刷新数据'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4FC3F7),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _performCleanup,
                    icon: const Icon(Icons.cleaning_services),
                    label: const Text('清理缓存'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0277BD),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建性能指标显示
  Widget _buildPerformanceMetrics(BuildContext context) {
    final performance = OneClickLanguageToggleButton.getPerformanceReport();
    final cacheStats = OneClickLanguageToggleButton.getCacheStatistics();
    final memoryStats = OneClickLanguageToggleButton.getMemoryStats();

    return Column(
      children: [
        _buildMetricRow(
          '平均响应时间',
          '${performance.averageResponseTime.toStringAsFixed(1)}ms',
        ),
        _buildMetricRow(
          '当前FPS',
          '${performance.currentFps.toStringAsFixed(1)}',
        ),
        _buildMetricRow(
          '缓存命中率',
          '${(cacheStats.hitRate * 100).toStringAsFixed(1)}%',
        ),
        _buildMetricRow(
          '内存使用',
          '${(memoryStats.currentUsage / 1024 / 1024).toStringAsFixed(1)}MB',
        ),
        _buildMetricRow(
          '动画状态',
          OneClickLanguageToggleButton.areAnimationsStable() ? '稳定' : '不稳定',
        ),
      ],
    );
  }

  /// 构建指标行
  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: const Color(0xFF0277BD).withValues(alpha: 0.7),
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0277BD),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建统计信息卡片
  Widget _buildStatisticsCard(BuildContext context) {
    final stats = OneClickLanguageToggleButton.getToggleStatistics();
    final idempotence = OneClickLanguageToggleButton.verifyToggleIdempotence();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: Color(0xFF4FC3F7), size: 24),
                const SizedBox(width: 12),
                Text(
                  context.l10n('language', fallback: '切换统计'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0277BD),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildMetricRow('切换次数', '${stats.toggleCount}'),
            _buildMetricRow('会话ID', stats.sessionId ?? '无'),
            _buildMetricRow('初始语言', stats.initialLanguage ?? '未知'),
            _buildMetricRow('切换类型', stats.isOddToggle ? '奇数次' : '偶数次'),
            _buildMetricRow('幂等性验证', idempotence.isValid ? '通过' : '失败'),

            if (!idempotence.isValid && idempotence.errorMessage != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '幂等性错误: ${idempotence.errorMessage}',
                  style: const TextStyle(fontSize: 10, color: Colors.red),
                ),
              ),
            ],

            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _resetToggleSession,
              icon: const Icon(Icons.refresh),
              label: const Text('重置会话'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建API使用示例卡片
  Widget _buildApiExamplesCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.code, color: Color(0xFF4FC3F7), size: 24),
                const SizedBox(width: 12),
                Text(
                  context.l10n('language', fallback: 'API使用示例'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0277BD),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildCodeExample('基本使用', 'OneClickLanguageToggleButton()'),
            const SizedBox(height: 8),

            _buildCodeExample(
              '自定义尺寸',
              'OneClickLanguageToggleButton(\n  size: 48.0,\n  animationDuration: Duration(milliseconds: 400),\n)',
            ),
            const SizedBox(height: 8),

            _buildCodeExample('程序化切换', 'await context.toggleLanguage();'),
            const SizedBox(height: 8),

            _buildCodeExample(
              '获取统计信息',
              'final stats = OneClickLanguageToggleButton.getToggleStatistics();',
            ),
          ],
        ),
      ),
    );
  }

  /// 构建代码示例
  Widget _buildCodeExample(String title, String code) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0277BD).withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF263238),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            code,
            style: const TextStyle(
              fontSize: 11,
              fontFamily: 'monospace',
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  /// 构建可访问性卡片
  Widget _buildAccessibilityCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.accessibility,
                  color: Color(0xFF4FC3F7),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  context.l10n('language', fallback: '可访问性功能'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0277BD),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildAccessibilityFeature('🔊', '屏幕阅读器支持', '按钮提供语义标签和状态描述'),
            _buildAccessibilityFeature('⌨️', '键盘导航', '支持Tab键导航和空格键/回车键激活'),
            _buildAccessibilityFeature('🎨', '高对比度模式', '自动适配系统高对比度设置'),
            _buildAccessibilityFeature('📢', '状态播报', '语言切换后自动播报新状态'),

            const SizedBox(height: 12),
            Text(
              '提示：使用Tab键可以导航到按钮，然后按空格键或回车键进行切换。',
              style: TextStyle(
                fontSize: 12,
                color: const Color(0xFF0277BD).withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建可访问性功能项
  Widget _buildAccessibilityFeature(
    String icon,
    String title,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0277BD),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    color: const Color(0xFF0277BD).withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建错误处理卡片
  Widget _buildErrorHandlingCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Color(0xFF4FC3F7),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  context.l10n('language', fallback: '错误处理演示'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0277BD),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              '一键切换功能具有完善的错误处理机制：',
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF0277BD).withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 12),

            _buildErrorHandlingFeature('🔄', '自动重试', '切换失败时自动重试'),
            _buildErrorHandlingFeature('🛡️', '状态保护', '错误时保持原有状态不变'),
            _buildErrorHandlingFeature('📝', '错误日志', '详细记录错误信息用于调试'),
            _buildErrorHandlingFeature('💬', '用户提示', '友好的错误提示信息'),

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _simulateError(context),
                    icon: const Icon(Icons.bug_report),
                    label: const Text('模拟错误'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _testErrorRecovery(context),
                    icon: const Icon(Icons.healing),
                    label: const Text('测试恢复'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建错误处理功能项
  Widget _buildErrorHandlingFeature(
    String icon,
    String title,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$title: $description',
              style: TextStyle(
                fontSize: 12,
                color: const Color(0xFF0277BD).withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 执行程序化切换
  Future<void> _performProgrammaticToggle(BuildContext context) async {
    try {
      final startTime = DateTime.now();
      await context.toggleLanguage();
      final duration = DateTime.now().difference(startTime);

      setState(() {
        _lastToggleResult = '程序化切换成功，耗时: ${duration.inMilliseconds}ms';
      });
    } catch (e) {
      setState(() {
        _lastToggleResult = '程序化切换失败: $e';
      });
    }
  }

  /// 执行连续切换测试
  Future<void> _performMultipleToggles(BuildContext context) async {
    try {
      final startTime = DateTime.now();

      // 执行4次切换（应该回到原始状态）
      for (var i = 0; i < 4; i++) {
        await context.toggleLanguage();
        await Future.delayed(const Duration(milliseconds: 100));
      }

      final duration = DateTime.now().difference(startTime);
      final idempotence =
          OneClickLanguageToggleButton.verifyToggleIdempotence();

      setState(() {
        _lastToggleResult =
            '连续切换测试完成，耗时: ${duration.inMilliseconds}ms，'
            '幂等性验证: ${idempotence.isValid ? "通过" : "失败"}';
      });
    } catch (e) {
      setState(() {
        _lastToggleResult = '连续切换测试失败: $e';
      });
    }
  }

  /// 刷新性能数据
  void _refreshPerformanceData() {
    setState(() {
      // 触发重建以刷新性能数据
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('性能数据已刷新'), duration: Duration(seconds: 1)),
    );
  }

  /// 执行清理
  void _performCleanup() {
    OneClickLanguageToggleButton.performCleanup();

    setState(() {
      // 触发重建
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('缓存和内存已清理'), duration: Duration(seconds: 1)),
    );
  }

  /// 重置切换会话
  void _resetToggleSession() {
    final summary = OneClickLanguageToggleButton.endToggleSession();

    setState(() {
      _lastToggleResult = '会话已重置，总切换次数: ${summary.totalToggles}';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('切换会话已重置'), duration: Duration(seconds: 1)),
    );
  }

  /// 模拟错误
  void _simulateError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.error, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text('模拟错误：语言切换失败'),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: '重试',
          textColor: Colors.white,
          onPressed: () => _performProgrammaticToggle(context),
        ),
      ),
    );
  }

  /// 测试错误恢复
  void _testErrorRecovery(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text('错误恢复测试：系统状态正常'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
