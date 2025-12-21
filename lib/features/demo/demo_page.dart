import 'package:flutter/material.dart';
import 'package:prvin/core/theme/app_theme.dart';
import 'package:prvin/core/theme/responsive_layout.dart';
import 'package:prvin/core/widgets/app_button.dart';
import 'package:prvin/core/widgets/app_card.dart';
import 'package:prvin/core/widgets/app_input.dart';

/// 演示页面
class DemoPage extends StatefulWidget {
  /// 创建演示页面
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  List<String> _tags = ['Flutter', 'Dart', 'UI'];

  @override
  void dispose() {
    _textController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prvin UI 组件演示'), centerTitle: true),
      body: ResponsiveContainer(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题
              Text(
                'UI 组件展示',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),

              // 按钮组件演示
              _buildSection(
                context,
                title: '按钮组件',
                child: ResponsiveGrid(
                  children: [
                    AppButton(
                      text: '主要按钮',
                      onPressed: () => _showSnackBar(context, '主要按钮被点击'),
                      icon: Icons.star,
                    ),
                    AppButton(
                      text: '次要按钮',
                      type: AppButtonType.secondary,
                      onPressed: () => _showSnackBar(context, '次要按钮被点击'),
                    ),
                    AppButton(
                      text: '文本按钮',
                      type: AppButtonType.text,
                      onPressed: () => _showSnackBar(context, '文本按钮被点击'),
                    ),
                    AppButton(
                      text: '轮廓按钮',
                      type: AppButtonType.outline,
                      onPressed: () => _showSnackBar(context, '轮廓按钮被点击'),
                    ),
                    AppButton(
                      text: '危险按钮',
                      type: AppButtonType.danger,
                      onPressed: () => _showSnackBar(context, '危险按钮被点击'),
                    ),
                    AppButton(text: '加载中', isLoading: true, onPressed: () {}),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spacingXL),

              // 输入框组件演示
              _buildSection(
                context,
                title: '输入框组件',
                child: Column(
                  children: [
                    AppInput(
                      controller: _textController,
                      label: '文本输入',
                      hint: '请输入文本',
                      prefixIcon: Icons.text_fields,
                      helperText: '这是帮助文本',
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    const AppInput(
                      type: AppInputType.password,
                      label: '密码输入',
                      hint: '请输入密码',
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    AppSearchInput(
                      controller: _searchController,
                      hint: '搜索任务...',
                      onChanged: (value) {
                        // 搜索逻辑
                      },
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    AppTagInput(
                      initialTags: _tags,
                      onTagsChanged: (tags) {
                        setState(() {
                          _tags = tags;
                        });
                      },
                      hint: '添加新标签',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spacingXL),

              // 卡片组件演示
              _buildSection(
                context,
                title: '卡片组件',
                child: ResponsiveGrid(
                  desktopColumns: 2,
                  children: [
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '基础卡片',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: AppTheme.spacingS),
                          Text(
                            '这是一个基础的卡片组件，具有柔和的阴影和圆角设计。',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    TaskCard(
                      title: '完成项目文档',
                      description: '编写项目的技术文档和用户手册，包括API文档和使用指南。',
                      category: 'work',
                      priority: 'high',
                      dueDate: DateTime.now().add(const Duration(days: 2)),
                      tags: const ['文档', '项目', '重要'],
                      onTap: () => _showSnackBar(context, '任务卡片被点击'),
                      onToggleComplete: () => _showSnackBar(context, '切换完成状态'),
                    ),
                    TaskCard(
                      title: '学习Flutter动画',
                      description: '深入学习Flutter的动画系统，包括隐式动画和显式动画。',
                      category: 'learning',
                      priority: 'medium',
                      dueDate: DateTime.now().add(const Duration(days: 7)),
                      tags: const ['学习', 'Flutter', '动画'],
                      isCompleted: true,
                      onTap: () => _showSnackBar(context, '已完成任务被点击'),
                    ),
                    AppCard(
                      onTap: () => _showSnackBar(context, '可点击卡片被点击'),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusM,
                              ),
                            ),
                            child: const Icon(
                              Icons.touch_app,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacingM),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '可点击卡片',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: AppTheme.spacingXS),
                                Text(
                                  '点击这个卡片查看交互效果',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spacingXL),

              // 颜色展示
              _buildSection(
                context,
                title: '主题颜色',
                child: ResponsiveGrid(
                  mobileColumns: 2,
                  tabletColumns: 4,
                  desktopColumns: 6,
                  children: [
                    _buildColorCard('主色调', AppTheme.primaryColor),
                    _buildColorCard('次要色', AppTheme.secondaryColor),
                    _buildColorCard('强调色', AppTheme.accentColor),
                    _buildColorCard('成功色', AppTheme.successColor),
                    _buildColorCard('警告色', AppTheme.warningColor),
                    _buildColorCard('错误色', AppTheme.errorColor),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spacingXL),

              // 任务分类颜色
              _buildSection(
                context,
                title: '任务分类颜色',
                child: ResponsiveGrid(
                  mobileColumns: 2,
                  tabletColumns: 3,
                  desktopColumns: 5,
                  children: AppTheme.taskCategoryColors.entries.map((entry) {
                    return _buildColorCard(entry.key, entry.value);
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: AppFloatingActionButton(
        onPressed: () => _showSnackBar(context, '浮动按钮被点击'),
        icon: Icons.add,
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppTheme.spacingM),
        child,
      ],
    );
  }

  Widget _buildColorCard(String name, Color color) {
    return AppCard(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppTheme.radiusS),
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            name,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          Text(
            color.value.toRadixString(16).toUpperCase(),
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
      ),
    );
  }
}
