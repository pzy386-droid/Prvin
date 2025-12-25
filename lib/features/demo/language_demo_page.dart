import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prvin/core/bloc/app_bloc.dart';
import 'package:prvin/core/localization/localization_exports.dart';
import 'package:prvin/core/widgets/language_switcher.dart';
import 'package:prvin/core/widgets/one_click_language_toggle_button.dart';
import 'package:prvin/features/demo/one_click_toggle_demo_page.dart';

/// 语言切换功能演示页面
class LanguageDemoPage extends StatelessWidget {
  const LanguageDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n('language_settings', fallback: '语言设置')),
        backgroundColor: const Color(0xFF4FC3F7),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 当前语言状态
            _buildCurrentLanguageCard(context),
            const SizedBox(height: 24),

            // 一键切换演示按钮
            _buildOneClickToggleDemoCard(context),
            const SizedBox(height: 24),

            // 语言切换器
            _buildLanguageSwitcherCard(context),
            const SizedBox(height: 24),

            // 本地化文本演示
            _buildLocalizationDemoCard(context),
            const SizedBox(height: 24),

            // 使用说明
            _buildUsageInstructionsCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentLanguageCard(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final currentLanguage = state is AppReadyState
            ? state.languageCode
            : 'zh';
        final languageName = AppLocalizations.getLanguageDisplayName(
          currentLanguage,
        );

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
                      context.l10n('language', fallback: '当前语言'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0277BD),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4FC3F7).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF4FC3F7).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text('🌐', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Text(
                        languageName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0277BD),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        currentLanguage.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF0277BD).withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOneClickToggleDemoCard(BuildContext context) {
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
                  context.l10n('language_settings', fallback: '一键语言切换'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0277BD),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 一键切换按钮演示
            Row(
              children: [
                const OneClickLanguageToggleButton(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '点击按钮即可快速切换语言',
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF0277BD).withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• 无需对话框确认\n• 即时响应\n• 显示当前语言状态',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF0277BD).withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 查看详细演示按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => const OneClickToggleDemoPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.explore),
                label: const Text('查看详细演示和API文档'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4FC3F7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSwitcherCard(BuildContext context) {
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
                  Icons.swap_horiz,
                  color: Color(0xFF4FC3F7),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  context.l10n('language_settings', fallback: '传统语言切换器'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0277BD),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const LanguageSwitcher(showTitle: false),
          ],
        ),
      ),
    );
  }

  Widget _buildLocalizationDemoCard(BuildContext context) {
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
                  Icons.text_fields,
                  color: Color(0xFF4FC3F7),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  context.l10n('app_name', fallback: '本地化演示'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0277BD),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDemoTextRow(context, 'app_name', 'Prvin AI日历'),
            _buildDemoTextRow(context, 'calendar', '日历'),
            _buildDemoTextRow(context, 'focus', '专注'),
            _buildDemoTextRow(context, 'today', '今天'),
            _buildDemoTextRow(context, 'create_task', '创建任务'),
            _buildDemoTextRow(context, 'pomodoro', '番茄钟'),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoTextRow(BuildContext context, String key, String fallback) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              key,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF0277BD).withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF4FC3F7).withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF4FC3F7).withOpacity(0.2),
                ),
              ),
              child: Text(
                context.l10n(key, fallback: fallback),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0277BD),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageInstructionsCard(BuildContext context) {
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
                  context.l10n('language', fallback: '使用说明'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0277BD),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInstructionItem(
              context,
              '1.',
              context.l10n('language', fallback: '点击上方的语言选项切换语言'),
            ),
            _buildInstructionItem(
              context,
              '2.',
              context.l10n('language', fallback: '语言设置会自动保存'),
            ),
            _buildInstructionItem(
              context,
              '3.',
              context.l10n('language', fallback: '重启应用后语言设置会保持'),
            ),
            _buildInstructionItem(
              context,
              '4.',
              context.l10n('language', fallback: '在日历页面点击地球图标也可以切换语言'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(
    BuildContext context,
    String number,
    String text,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFF4FC3F7).withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF4FC3F7).withOpacity(0.3),
              ),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0277BD),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF0277BD).withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
