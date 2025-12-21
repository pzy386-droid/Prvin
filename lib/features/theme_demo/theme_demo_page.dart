import 'package:flutter/material.dart';
import 'package:prvin/core/theme/theme_exports.dart';

/// 主题演示页面
/// 展示新的视觉主题系统的各种功能
class ThemeDemoPage extends StatefulWidget {
  const ThemeDemoPage({super.key});

  @override
  State<ThemeDemoPage> createState() => _ThemeDemoPageState();
}

class _ThemeDemoPageState extends State<ThemeDemoPage> {
  bool _isPomodoroActive = false;
  bool _isShaking = false;
  bool _showSuccessGlow = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('主题系统演示'), elevation: 0),
      body: SingleChildScrollView(
        padding: ResponsiveTheme.getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('响应式设计'),
            _buildResponsiveDemo(),

            const SizedBox(height: 32),
            _buildSectionTitle('微光效果'),
            _buildGlowEffectsDemo(),

            const SizedBox(height: 32),
            _buildSectionTitle('微动效交互'),
            _buildMicroInteractionsDemo(),

            const SizedBox(height: 32),
            _buildSectionTitle('动画效果'),
            _buildAnimationDemo(),
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

  Widget _buildResponsiveDemo() {
    return ResponsiveTheme.createResponsiveContainer(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '当前设备类型: ${ResponsiveTheme.getDeviceType(context).name}',
            style: ResponsiveTheme.createResponsiveTextStyle(
              context,
              baseFontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '响应式间距: ${ResponsiveTheme.getResponsiveSpacing(context)}px',
            style: ResponsiveTheme.createResponsiveTextStyle(
              context,
              baseFontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          ResponsiveTheme.createResponsiveGridView(
            context: context,
            children: List.generate(6, (index) {
              return Container(
                decoration: BoxDecoration(
                  color: AppTheme.taskCategoryColors.values.elementAt(
                    index % AppTheme.taskCategoryColors.length,
                  ),
                  borderRadius: BorderRadius.circular(
                    ResponsiveTheme.getResponsiveBorderRadius(context),
                  ),
                ),
                child: Center(
                  child: Text(
                    '卡片 ${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildGlowEffectsDemo() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // 当天日期微光效果
            GlowEffects.createTodayGlow(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    '今天',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            // 卡片悬停微光效果
            GlowEffects.createCardGlow(
              isHovered: true,
              child: Container(
                width: 80,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Center(child: Text('悬停卡片')),
              ),
            ),

            // 成功状态微光效果
            GlowEffects.createSuccessGlow(
              isVisible: _showSuccessGlow,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.successColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.check, color: Colors.white),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // 番茄钟呼吸微光效果
        GlowEffects.createPomodoroGlow(
          glowColor: AppTheme.pomodoroWorkColor,
          isActive: _isPomodoroActive,
          child: Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: AppTheme.pomodoroWorkColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.timer, color: Colors.white, size: 40),
          ),
        ),

        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isPomodoroActive = !_isPomodoroActive;
                });
              },
              child: Text(_isPomodoroActive ? '停止番茄钟' : '启动番茄钟'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showSuccessGlow = !_showSuccessGlow;
                });
              },
              child: Text(_showSuccessGlow ? '隐藏成功效果' : '显示成功效果'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMicroInteractionsDemo() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // 可交互容器
            MicroInteractions.createInteractiveContainer(
              onTap: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('交互容器被点击')));
              },
              child: Container(
                width: 80,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.accentColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    '点击我',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            // 弹性按钮
            MicroInteractions.createElasticButton(
              onPressed: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('弹性按钮被点击')));
              },
              child: Container(
                width: 80,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    '弹性',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            // 晃动效果
            MicroInteractions.createShakeWidget(
              isShaking: _isShaking,
              child: Container(
                width: 80,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.warningColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    '晃动',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        ElevatedButton(
          onPressed: () {
            setState(() {
              _isShaking = !_isShaking;
            });
          },
          child: Text(_isShaking ? '停止晃动' : '开始晃动'),
        ),
      ],
    );
  }

  Widget _buildAnimationDemo() {
    return Column(
      children: [
        // 渐变出现效果
        MicroInteractions.createFadeInWidget(
          delay: const Duration(milliseconds: 200),
          child: Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                '渐变出现效果',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 滑入效果
        MicroInteractions.createSlideInWidget(
          delay: const Duration(milliseconds: 400),
          beginOffset: const Offset(1, 0),
          child: Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.accentColor, AppTheme.infoColor],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                '滑入效果',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 呼吸效果
        MicroInteractions.createBreathingWidget(
          child: Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: AppTheme.successColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite, color: Colors.white, size: 40),
          ),
        ),
      ],
    );
  }
}
