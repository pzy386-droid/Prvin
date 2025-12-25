import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prvin/core/bloc/app_bloc.dart';
import 'package:prvin/core/localization/localization_exports.dart';

/// 语言切换组件
///
/// 提供简洁的语言切换界面，支持中英文切换
/// 可以作为独立组件使用，也可以嵌入到设置页面中
class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({
    super.key,
    this.showTitle = true,
    this.compact = false,
  });

  /// 是否显示标题
  final bool showTitle;

  /// 是否使用紧凑模式
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final currentLanguage = state is AppReadyState
            ? state.languageCode
            : 'zh';

        if (compact) {
          return _buildCompactSwitcher(context, currentLanguage);
        } else {
          return _buildFullSwitcher(context, currentLanguage);
        }
      },
    );
  }

  /// 构建完整的语言切换器
  Widget _buildFullSwitcher(BuildContext context, String currentLanguage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showTitle) ...[
          Text(
            AppLocalizations.get('language', fallback: '语言'),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
        ],
        _buildLanguageOptions(context, currentLanguage),
      ],
    );
  }

  /// 构建紧凑的语言切换器
  Widget _buildCompactSwitcher(BuildContext context, String currentLanguage) {
    return PopupMenuButton<String>(
      onSelected: (locale) => _changeLanguage(context, locale),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'zh',
          child: Row(
            children: [
              if (currentLanguage == 'zh')
                const Icon(Icons.check, size: 20)
              else
                const SizedBox(width: 20),
              const SizedBox(width: 8),
              const Text('中文'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'en',
          child: Row(
            children: [
              if (currentLanguage == 'en')
                const Icon(Icons.check, size: 20)
              else
                const SizedBox(width: 20),
              const SizedBox(width: 8),
              const Text('English'),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language, size: 20),
            const SizedBox(width: 8),
            Text(AppLocalizations.getLanguageDisplayName(currentLanguage)),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
    );
  }

  /// 构建语言选项列表
  Widget _buildLanguageOptions(BuildContext context, String currentLanguage) {
    return Column(
      children: [
        _buildLanguageOption(
          context,
          locale: 'zh',
          displayName: '中文',
          isSelected: currentLanguage == 'zh',
        ),
        const SizedBox(height: 8),
        _buildLanguageOption(
          context,
          locale: 'en',
          displayName: 'English',
          isSelected: currentLanguage == 'en',
        ),
      ],
    );
  }

  /// 构建单个语言选项
  Widget _buildLanguageOption(
    BuildContext context, {
    required String locale,
    required String displayName,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => _changeLanguage(context, locale),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
              : null,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Theme.of(context).dividerColor,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            if (isSelected) ...[
              Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              const SizedBox(width: 12),
            ],
            Text(
              displayName,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Theme.of(context).primaryColor : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 切换语言
  void _changeLanguage(BuildContext context, String locale) {
    if (AppLocalizations.isLocaleSupported(locale)) {
      context.read<AppBloc>().add(AppLanguageChangedEvent(locale));
    }
  }
}

/// 语言切换对话框
///
/// 提供模态对话框形式的语言切换界面
class LanguageSwitcherDialog extends StatelessWidget {
  const LanguageSwitcherDialog({super.key});

  /// 显示语言切换对话框
  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => const LanguageSwitcherDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.get('language_settings', fallback: '语言设置')),
      content: const SizedBox(
        width: double.maxFinite,
        child: LanguageSwitcher(showTitle: false),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.get('close', fallback: '关闭')),
        ),
      ],
    );
  }
}
