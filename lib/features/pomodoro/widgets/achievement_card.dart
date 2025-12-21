import 'package:flutter/material.dart';
import 'package:prvin/core/theme/theme_exports.dart';
import 'package:prvin/core/widgets/widgets_exports.dart';

/// 成就卡片组件
class AchievementCard extends StatefulWidget {
  /// 创建成就卡片
  const AchievementCard({
    required this.title, required this.description, required this.icon, required this.isUnlocked, required this.progress, super.key,
    this.onTap,
  });

  /// 成就标题
  final String title;

  /// 成就描述
  final String description;

  /// 成就图标
  final IconData icon;

  /// 是否已解锁
  final bool isUnlocked;

  /// 进度（0.0 - 1.0）
  final double progress;

  /// 点击回调
  final VoidCallback? onTap;

  @override
  State<AchievementCard> createState() => _AchievementCardState();
}

class _AchievementCardState extends State<AchievementCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: AnimationTheme.shortAnimationDuration,
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1, end: 1.02).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: AnimationTheme.defaultCurve,
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 1).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    if (widget.isUnlocked) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AchievementCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isUnlocked && !oldWidget.isUnlocked) {
      _glowController.repeat(reverse: true);
    } else if (!widget.isUnlocked && oldWidget.isUnlocked) {
      _glowController.stop();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: MicroInteractions.createInteractiveContainer(
              onTap: widget.onTap,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                  boxShadow: widget.isUnlocked
                      ? [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(
                              alpha: 0.3 * _glowAnimation.value,
                            ),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: AppCard(
                  elevation: _isHovered ? 8 : 2,
                  child: _buildCardContent(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardContent() {
    return Column(
      children: [
        Row(
          children: [
            // 成就图标
            _buildAchievementIcon(),
            const SizedBox(width: AppTheme.spacingM),

            // 成就信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: widget.isUnlocked
                          ? AppTheme.primaryColor
                          : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXS),
                  Text(
                    widget.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.isUnlocked
                          ? Colors.grey.shade700
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),

            // 解锁状态
            _buildUnlockStatus(),
          ],
        ),

        if (!widget.isUnlocked) ...[
          const SizedBox(height: AppTheme.spacingM),
          _buildProgressBar(),
        ],
      ],
    );
  }

  Widget _buildAchievementIcon() {
    return AnimatedContainer(
      duration: AnimationTheme.shortAnimationDuration,
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: widget.isUnlocked
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withValues(alpha: 0.7),
                ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.grey.shade300, Colors.grey.shade400],
              ),
        boxShadow: widget.isUnlocked
            ? [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Icon(
        widget.icon,
        size: 30,
        color: widget.isUnlocked ? Colors.white : Colors.grey.shade600,
      ),
    );
  }

  Widget _buildUnlockStatus() {
    if (widget.isUnlocked) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingS,
          vertical: AppTheme.spacingXS,
        ),
        decoration: BoxDecoration(
          color: AppTheme.successColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusS),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 16, color: AppTheme.successColor),
            SizedBox(width: AppTheme.spacingXS),
            Text(
              '已解锁',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppTheme.successColor,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingS,
          vertical: AppTheme.spacingXS,
        ),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(AppTheme.radiusS),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: AppTheme.spacingXS),
            Text(
              '未解锁',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '进度',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(widget.progress * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingXS),
        LinearProgressIndicator(
          value: widget.progress,
          backgroundColor: Colors.grey.shade200,
          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
        ),
      ],
    );
  }

  void _setHovered(bool hovered) {
    setState(() => _isHovered = hovered);
    if (hovered) {
      _scaleController.forward();
    } else {
      _scaleController.reverse();
    }
  }
}
