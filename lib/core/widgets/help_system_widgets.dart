import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prvin/core/localization/localization_exports.dart';
import 'package:prvin/core/services/help_system_service.dart';

/// 帮助系统主要组件
class HelpSystemWidget extends StatefulWidget {
  const HelpSystemWidget({required this.child, super.key});

  final Widget child;

  @override
  State<HelpSystemWidget> createState() => _HelpSystemWidgetState();
}

class _HelpSystemWidgetState extends State<HelpSystemWidget>
    with TickerProviderStateMixin {
  late AnimationController _overlayController;
  late AnimationController _tipController;

  OverlayEntry? _currentOverlay;
  HelpTip? _currentTip;

  @override
  void initState() {
    super.initState();
    _overlayController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _tipController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // 监听帮助事件
    HelpSystemService.instance.helpEvents.listen(_handleHelpEvent);
  }

  @override
  void dispose() {
    _overlayController.dispose();
    _tipController.dispose();
    _removeCurrentOverlay();
    super.dispose();
  }

  void _handleHelpEvent(HelpEvent event) {
    if (event is ShowOnboardingEvent) {
      _showOnboarding(event.steps);
    } else if (event is ShowTipEvent) {
      _showTip(event.tip, event.targetWidget, event.position);
    } else if (event is HideTipEvent) {
      _hideTip();
    } else if (event is ShowHelpPageEvent) {
      _showHelpPage(event.pageType);
    }
  }

  void _showOnboarding(List<OnboardingStep> steps) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) {
          return OnboardingScreen(steps: steps);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _showTip(HelpTip tip, Widget? targetWidget, Offset? position) {
    _removeCurrentOverlay();
    _currentTip = tip;

    _currentOverlay = OverlayEntry(
      builder: (context) => HelpTipOverlay(
        tip: tip,
        targetWidget: targetWidget,
        position: position,
        animation: _tipController,
        onDismiss: _hideTip,
      ),
    );

    Overlay.of(context).insert(_currentOverlay!);
    _tipController.forward();
  }

  void _hideTip() {
    if (_currentOverlay != null) {
      _tipController.reverse().then((_) {
        _removeCurrentOverlay();
      });
    }
  }

  void _removeCurrentOverlay() {
    _currentOverlay?.remove();
    _currentOverlay = null;
    _currentTip = null;
  }

  void _showHelpPage(HelpPageType pageType) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => HelpPage(pageType: pageType),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// 引导屏幕
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({required this.steps, super.key});

  final List<OnboardingStep> steps;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fadeController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentIndex < widget.steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousStep() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeOnboarding() {
    HelpSystemService.instance.markOnboardingCompleted();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB), Color(0xFFE1F5FE)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeController,
            child: Column(
              children: [
                // 顶部进度指示器
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Text(
                        context.l10n('onboarding_progress', fallback: '引导进度'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0277BD),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_currentIndex + 1}/${widget.steps.length}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF0288D1),
                        ),
                      ),
                    ],
                  ),
                ),

                // 进度条
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: LinearProgressIndicator(
                    value: (_currentIndex + 1) / widget.steps.length,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF4FC3F7),
                    ),
                  ),
                ),

                // 引导内容
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemCount: widget.steps.length,
                    itemBuilder: (context, index) {
                      return OnboardingStepWidget(
                        step: widget.steps[index],
                        isActive: index == _currentIndex,
                      );
                    },
                  ),
                ),

                // 底部按钮
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      if (_currentIndex > 0)
                        TextButton(
                          onPressed: _previousStep,
                          child: Text(
                            context.l10n('previous', fallback: '上一步'),
                            style: const TextStyle(color: Color(0xFF0277BD)),
                          ),
                        )
                      else
                        const SizedBox(width: 80),

                      const Spacer(),

                      TextButton(
                        onPressed: _completeOnboarding,
                        child: Text(
                          context.l10n('skip', fallback: '跳过'),
                          style: TextStyle(
                            color: const Color(0xFF0277BD).withOpacity(0.7),
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      ElevatedButton(
                        onPressed: _nextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4FC3F7),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          _currentIndex < widget.steps.length - 1
                              ? context.l10n('next', fallback: '下一步')
                              : context.l10n('get_started', fallback: '开始使用'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 引导步骤组件
class OnboardingStepWidget extends StatelessWidget {
  const OnboardingStepWidget({
    required this.step,
    required this.isActive,
    super.key,
  });

  final OnboardingStep step;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isActive ? 1.0 : 0.7,
      duration: const Duration(milliseconds: 300),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 图标
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              tween: Tween(begin: 0, end: isActive ? 1 : 0.8),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          step.color.withOpacity(0.3),
                          step.color.withOpacity(0.1),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: step.color.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(step.icon, size: 48, color: step.color),
                  ),
                );
              },
            ),

            const SizedBox(height: 40),

            // 标题
            Text(
              step.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0277BD),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // 描述
            Text(
              step.description,
              style: TextStyle(
                fontSize: 16,
                color: const Color(0xFF0288D1).withOpacity(0.8),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// 帮助提示覆盖层
class HelpTipOverlay extends StatelessWidget {
  const HelpTipOverlay({
    required this.tip,
    required this.animation,
    required this.onDismiss,
    this.targetWidget,
    this.position,
    super.key,
  });

  final HelpTip tip;
  final Animation<double> animation;
  final VoidCallback onDismiss;
  final Widget? targetWidget;
  final Offset? position;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Material(
            color: Colors.black.withOpacity(0.5 * animation.value),
            child: GestureDetector(
              onTap: onDismiss,
              child: Stack(
                children: [
                  // 背景遮罩
                  Positioned.fill(child: Container(color: Colors.transparent)),

                  // 帮助提示卡片
                  Positioned(
                    top:
                        position?.dy ??
                        MediaQuery.of(context).size.height * 0.3,
                    left: 20,
                    right: 20,
                    child: Transform.scale(
                      scale: 0.8 + (0.2 * animation.value),
                      child: HelpTipCard(tip: tip, onDismiss: onDismiss),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 帮助提示卡片
class HelpTipCard extends StatelessWidget {
  const HelpTipCard({required this.tip, required this.onDismiss, super.key});

  final HelpTip tip;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.95),
            Colors.white.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4FC3F7).withOpacity(0.2),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题和关闭按钮
                Row(
                  children: [
                    Icon(
                      _getTipIcon(tip.type),
                      color: _getTipColor(tip.type),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        tip.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0277BD),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onDismiss,
                      icon: const Icon(
                        Icons.close,
                        color: Color(0xFF0288D1),
                        size: 20,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 内容
                Text(
                  tip.content,
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF0288D1).withOpacity(0.8),
                    height: 1.5,
                  ),
                ),

                if (tip.actions.isNotEmpty) ...[
                  const SizedBox(height: 20),

                  // 操作按钮
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: tip.actions.map((action) {
                      final isFirst = tip.actions.first == action;
                      return Padding(
                        padding: EdgeInsets.only(left: isFirst ? 0 : 12),
                        child: isFirst
                            ? ElevatedButton(
                                onPressed: action.onTap,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4FC3F7),
                                  foregroundColor: Colors.white,
                                ),
                                child: Text(action.label),
                              )
                            : TextButton(
                                onPressed: action.onTap,
                                child: Text(
                                  action.label,
                                  style: const TextStyle(
                                    color: Color(0xFF0277BD),
                                  ),
                                ),
                              ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getTipIcon(HelpTipType type) {
    switch (type) {
      case HelpTipType.info:
        return Icons.info_outline;
      case HelpTipType.tutorial:
        return Icons.school_outlined;
      case HelpTipType.feature:
        return Icons.star_outline;
      case HelpTipType.warning:
        return Icons.warning_outlined;
    }
  }

  Color _getTipColor(HelpTipType type) {
    switch (type) {
      case HelpTipType.info:
        return const Color(0xFF4FC3F7);
      case HelpTipType.tutorial:
        return const Color(0xFF81C784);
      case HelpTipType.feature:
        return const Color(0xFFFFB74D);
      case HelpTipType.warning:
        return const Color(0xFFE57373);
    }
  }
}

/// 帮助页面
class HelpPage extends StatefulWidget {
  const HelpPage({required this.pageType, super.key});

  final HelpPageType pageType;

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  final TextEditingController _searchController = TextEditingController();
  List<HelpSearchResult> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchResults = HelpSystemService.instance.searchHelp(query, context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n('help_center', fallback: '帮助中心'),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF0277BD),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0277BD)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB), Color(0xFFE1F5FE)],
          ),
        ),
        child: Column(
          children: [
            // 搜索栏
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: _performSearch,
                decoration: InputDecoration(
                  hintText: context.l10n('search_help', fallback: '搜索帮助内容...'),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            _performSearch('');
                          },
                          icon: const Icon(Icons.clear),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.8),
                ),
              ),
            ),

            // 内容区域
            Expanded(
              child: _isSearching ? _buildSearchResults() : _buildHelpContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Color(0xFF0288D1)),
            const SizedBox(height: 16),
            Text(
              context.l10n('no_search_results', fallback: '没有找到相关内容'),
              style: const TextStyle(fontSize: 16, color: Color(0xFF0288D1)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(result.topic.title),
            subtitle: Text(result.topic.content),
            trailing: Text(
              '${(result.relevanceScore * 10).toInt()}%',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF4FC3F7),
              ),
            ),
            onTap: () {
              // 这里可以导航到具体的帮助内容
            },
          ),
        );
      },
    );
  }

  Widget _buildHelpContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n('help_categories', fallback: '帮助分类'),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0277BD),
            ),
          ),
          const SizedBox(height: 16),

          // 帮助分类网格
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildHelpCategoryCard(
                title: context.l10n('help_basics', fallback: '基础操作'),
                icon: Icons.school,
                color: const Color(0xFF4FC3F7),
                onTap: () {},
              ),
              _buildHelpCategoryCard(
                title: context.l10n('help_features', fallback: '功能介绍'),
                icon: Icons.star,
                color: const Color(0xFF81C784),
                onTap: () {},
              ),
              _buildHelpCategoryCard(
                title: context.l10n('help_advanced', fallback: '高级功能'),
                icon: Icons.settings,
                color: const Color(0xFFFFB74D),
                onTap: () {},
              ),
              _buildHelpCategoryCard(
                title: context.l10n('help_troubleshooting', fallback: '故障排除'),
                icon: Icons.build,
                color: const Color(0xFFE57373),
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHelpCategoryCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.8),
              Colors.white.withOpacity(0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          color.withOpacity(0.3),
                          color.withOpacity(0.1),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0277BD),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 帮助按钮组件
class HelpButton extends StatelessWidget {
  const HelpButton({this.helpContext, this.onTap, this.size = 24.0, super.key});

  final HelpContext? helpContext;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          onTap ??
          () {
            if (helpContext != null) {
              HelpSystemService.instance.showContextualHelp(
                context,
                helpContext!,
              );
            } else {
              HelpSystemService.instance.showHelpPage(
                context,
                HelpPageType.overview,
              );
            }
          },
      child: Container(
        width: size + 16,
        height: size + 16,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              const Color(0xFF4FC3F7).withOpacity(0.2),
              const Color(0xFF4FC3F7).withOpacity(0.1),
            ],
          ),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF4FC3F7).withOpacity(0.3)),
        ),
        child: Icon(
          Icons.help_outline,
          size: size,
          color: const Color(0xFF4FC3F7),
        ),
      ),
    );
  }
}
