import 'package:flutter/material.dart';
import 'package:prvin/core/theme/theme_exports.dart';
import 'package:prvin/core/widgets/widgets_exports.dart';

/// UI组件演示页面
/// 展示所有基础UI组件库的功能
class UIComponentsDemoPage extends StatefulWidget {
  const UIComponentsDemoPage({super.key});

  @override
  State<UIComponentsDemoPage> createState() => _UIComponentsDemoPageState();
}

class _UIComponentsDemoPageState extends State<UIComponentsDemoPage> {
  double _progressValue = 0.3;
  int _currentStep = 1;
  final List<String> _tags = ['Flutter', 'UI', 'Demo'];
  final bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('UI组件库演示'), elevation: 0),
      body: SingleChildScrollView(
        padding: ResponsiveTheme.getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('按钮组件'),
            _buildButtonsDemo(),

            const SizedBox(height: 32),
            _buildSectionTitle('卡片组件'),
            _buildCardsDemo(),

            const SizedBox(height: 32),
            _buildSectionTitle('输入框组件'),
            _buildInputsDemo(),

            const SizedBox(height: 32),
            _buildSectionTitle('进度指示器'),
            _buildProgressDemo(),

            const SizedBox(height: 32),
            _buildSectionTitle('动画组件'),
            _buildAnimationsDemo(),

            const SizedBox(height: 32),
            _buildSectionTitle('对话框组件'),
            _buildDialogsDemo(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: ResponsiveTheme.createResponsiveTextStyle(
          context,
          baseFontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildButtonsDemo() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '不同类型的按钮',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),

          // 主要按钮
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: '主要按钮',
                  onPressed: () => _showSnackBar('主要按钮被点击'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  text: '次要按钮',
                  onPressed: () => _showSnackBar('次要按钮被点击'),
                  type: AppButtonType.secondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 轮廓和文本按钮
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: '轮廓按钮',
                  onPressed: () => _showSnackBar('轮廓按钮被点击'),
                  type: AppButtonType.outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  text: '文本按钮',
                  onPressed: () => _showSnackBar('文本按钮被点击'),
                  type: AppButtonType.text,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 带图标和加载状态的按钮
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: '带图标',
                  onPressed: () => _showSnackBar('图标按钮被点击'),
                  icon: Icons.star,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  text: '加载中',
                  onPressed: () {},
                  isLoading: _isLoading,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 危险按钮
          SizedBox(
            width: double.infinity,
            child: AppButton(
              text: '危险操作',
              onPressed: () => _showSnackBar('危险按钮被点击'),
              type: AppButtonType.danger,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardsDemo() {
    return Column(
      children: [
        // 基础卡片
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '基础卡片',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                '这是一个基础的卡片组件，具有现代化的设计风格，包含阴影和圆角效果。',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 任务卡片
        TaskCard(
          title: '完成UI组件库开发',
          description: '开发包含按钮、卡片、输入框等基础组件的UI库，并添加微动效和交互反馈。',
          category: 'work',
          priority: 'high',
          dueDate: DateTime.now().add(const Duration(days: 2)),
          tags: const ['Flutter', 'UI', '开发'],
          onTap: () => _showSnackBar('任务卡片被点击'),
          onToggleComplete: () {
            setState(() {
              // 切换完成状态的逻辑
            });
            _showSnackBar('任务状态已切换');
          },
        ),
      ],
    );
  }

  Widget _buildInputsDemo() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '输入框组件',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),

          // 基础输入框
          const AppInput(
            label: '用户名',
            hint: '请输入用户名',
            prefixIcon: Icons.person,
          ),

          const SizedBox(height: 16),

          // 密码输入框
          const AppInput(
            label: '密码',
            hint: '请输入密码',
            type: AppInputType.password,
            prefixIcon: Icons.lock,
          ),

          const SizedBox(height: 16),

          // 搜索输入框
          const AppSearchInput(hint: '搜索任务...'),

          const SizedBox(height: 16),

          // 标签输入框
          AppTagInput(
            initialTags: _tags,
            onTagsChanged: (tags) {
              setState(() {
                _tags.clear();
                _tags.addAll(tags);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProgressDemo() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '进度指示器',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),

          // 线性进度条
          Text('线性进度条', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          SimpleProgress.linear(value: _progressValue, showPercentage: true),

          const SizedBox(height: 24),

          // 圆形进度条
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text('圆形进度条', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  SimpleProgress.circular(
                    value: _progressValue,
                    showPercentage: true,
                  ),
                ],
              ),
              Column(
                children: [
                  Text('番茄钟进度', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  SimpleProgress.pomodoro(
                    value: _progressValue,
                    breathingEffect: true,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 步骤进度条
          Text('步骤进度条', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          SimpleProgress.stepper(
            steps: 4,
            currentStep: _currentStep,
            stepLabels: const ['开始', '进行中', '测试', '完成'],
          ),

          const SizedBox(height: 16),

          // 控制按钮
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: '减少进度',
                  onPressed: () {
                    setState(() {
                      _progressValue = (_progressValue - 0.1).clamp(0.0, 1.0);
                      if (_currentStep > 0) _currentStep--;
                    });
                  },
                  type: AppButtonType.outline,
                  size: AppButtonSize.small,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  text: '增加进度',
                  onPressed: () {
                    setState(() {
                      _progressValue = (_progressValue + 0.1).clamp(0.0, 1.0);
                      if (_currentStep < 3) _currentStep++;
                    });
                  },
                  size: AppButtonSize.small,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimationsDemo() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lottie动画组件',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),

          // 动画展示
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  SimpleLottie.loading(size: 60),
                  const SizedBox(height: 8),
                  Text('加载动画', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
              Column(
                children: [
                  SimpleLottie.success(size: 60),
                  const SizedBox(height: 8),
                  Text('成功动画', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
              Column(
                children: [
                  SimpleLottie.error(size: 60),
                  const SizedBox(height: 8),
                  Text('错误动画', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  SimpleLottie.complete(size: 80),
                  const SizedBox(height: 8),
                  Text('完成动画', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
              Column(
                children: [
                  SimpleLottie.pomodoroComplete(size: 80),
                  const SizedBox(height: 8),
                  Text('番茄钟完成', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDialogsDemo() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '对话框组件',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),

          // 对话框按钮
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: '信息对话框',
                  onPressed: () => DialogUtils.showInfo(
                    context,
                    title: '信息',
                    message: '这是一个信息对话框的示例。',
                  ),
                  type: AppButtonType.outline,
                  size: AppButtonSize.small,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                  text: '成功对话框',
                  onPressed: () => DialogUtils.showSuccess(
                    context,
                    title: '成功',
                    message: '操作已成功完成！',
                  ),
                  type: AppButtonType.outline,
                  size: AppButtonSize.small,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: '错误对话框',
                  onPressed: () => DialogUtils.showError(
                    context,
                    title: '错误',
                    message: '操作失败，请重试。',
                  ),
                  type: AppButtonType.outline,
                  size: AppButtonSize.small,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                  text: '确认对话框',
                  onPressed: () async {
                    final result = await DialogUtils.showConfirm(
                      context,
                      title: '确认',
                      message: '确定要执行此操作吗？',
                    );
                    if (result ?? false) {
                      _showSnackBar('用户确认了操作');
                    }
                  },
                  type: AppButtonType.outline,
                  size: AppButtonSize.small,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: AppButton(
              text: '加载对话框',
              onPressed: () async {
                DialogUtils.showLoading<void>(context, message: '正在处理...');

                // 模拟异步操作
                await Future<void>.delayed(const Duration(seconds: 2));

                if (mounted) {
                  Navigator.of(context).pop();
                  _showSnackBar('加载完成');
                }
              },
              type: AppButtonType.outline,
              size: AppButtonSize.small,
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
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
