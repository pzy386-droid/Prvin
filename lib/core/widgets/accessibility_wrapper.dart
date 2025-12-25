import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:prvin/core/theme/accessibility_theme.dart';

/// 可访问性包装器组件
/// 为子组件提供增强的可访问性功能
class AccessibilityWrapper extends StatefulWidget {
  const AccessibilityWrapper({
    required this.child,
    super.key,
    this.semanticLabel,
    this.semanticHint,
    this.semanticValue,
    this.isButton = false,
    this.isHeader = false,
    this.isTextField = false,
    this.onTap,
    this.focusNode,
    this.enableVoiceControl = false,
    this.voiceControlCommands = const [],
    this.announceOnFocus = false,
    this.customAnnouncement,
  });

  /// 子组件
  final Widget child;

  /// 语义标签
  final String? semanticLabel;

  /// 语义提示
  final String? semanticHint;

  /// 语义值
  final String? semanticValue;

  /// 是否为按钮
  final bool isButton;

  /// 是否为标题
  final bool isHeader;

  /// 是否为文本输入框
  final bool isTextField;

  /// 点击回调
  final VoidCallback? onTap;

  /// 焦点节点
  final FocusNode? focusNode;

  /// 是否启用语音控制
  final bool enableVoiceControl;

  /// 语音控制命令
  final List<String> voiceControlCommands;

  /// 获得焦点时是否播报
  final bool announceOnFocus;

  /// 自定义播报内容
  final String? customAnnouncement;

  @override
  State<AccessibilityWrapper> createState() => _AccessibilityWrapperState();
}

class _AccessibilityWrapperState extends State<AccessibilityWrapper> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChanged);
    }
    super.dispose();
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus != _isFocused) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });

      // 焦点变化时的播报
      if (_isFocused && widget.announceOnFocus) {
        final announcement =
            widget.customAnnouncement ?? widget.semanticLabel ?? '已获得焦点';
        _announceToScreenReader(announcement);
      }
    }
  }

  void _announceToScreenReader(String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  @override
  Widget build(BuildContext context) {
    var child = widget.child;

    // 应用高对比度样式
    if (AccessibilityTheme.shouldUseHighContrast(context)) {
      child = _applyHighContrastStyles(context, child);
    }

    // 添加焦点指示器
    if (_isFocused) {
      child = Container(
        decoration: AccessibilityTheme.getFocusIndicatorDecoration(context),
        child: child,
      );
    }

    // 包装语义信息
    child = Semantics(
      label: widget.semanticLabel,
      hint: widget.semanticHint,
      value: widget.semanticValue,
      button: widget.isButton,
      header: widget.isHeader,
      textField: widget.isTextField,
      focusable: true,
      enabled: widget.onTap != null,
      onTap: widget.onTap,
      child: child,
    );

    // 添加焦点支持
    child = Focus(focusNode: _focusNode, child: child);

    // 添加手势检测
    if (widget.onTap != null) {
      child = GestureDetector(onTap: widget.onTap, child: child);
    }

    return child;
  }

  Widget _applyHighContrastStyles(BuildContext context, Widget child) {
    // 为高对比度模式应用特殊样式
    return Container(
      decoration: BoxDecoration(
        border: AccessibilityTheme.getAccessibleBorder(
          context,
          normalBorder: Border.all(color: Colors.transparent),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}

/// 可访问性按钮组件
class AccessibleButton extends StatelessWidget {
  const AccessibleButton({
    required this.onPressed,
    required this.child,
    super.key,
    this.semanticLabel,
    this.semanticHint,
    this.style,
    this.focusNode,
    this.announceOnPress = false,
    this.pressAnnouncement,
  });

  /// 按钮回调
  final VoidCallback? onPressed;

  /// 子组件
  final Widget child;

  /// 语义标签
  final String? semanticLabel;

  /// 语义提示
  final String? semanticHint;

  /// 按钮样式
  final ButtonStyle? style;

  /// 焦点节点
  final FocusNode? focusNode;

  /// 按下时是否播报
  final bool announceOnPress;

  /// 按下时的播报内容
  final String? pressAnnouncement;

  @override
  Widget build(BuildContext context) {
    final isHighContrast = AccessibilityTheme.shouldUseHighContrast(context);

    var effectiveStyle = style ?? ElevatedButton.styleFrom();

    if (isHighContrast) {
      effectiveStyle = effectiveStyle.copyWith(
        textStyle: WidgetStateProperty.all(
          AccessibilityTheme.getAccessibleTextStyle(
            context,
            normalStyle: const TextStyle(fontSize: 16),
          ),
        ),
        side: WidgetStateProperty.all(
          BorderSide(color: Theme.of(context).colorScheme.onSurface, width: 2),
        ),
      );
    }

    return AccessibilityWrapper(
      semanticLabel: semanticLabel,
      semanticHint: semanticHint,
      isButton: true,
      focusNode: focusNode,
      onTap: onPressed != null
          ? () {
              if (announceOnPress) {
                final announcement =
                    pressAnnouncement ?? semanticLabel ?? '按钮已按下';
                SemanticsService.announce(announcement, TextDirection.ltr);
              }
              onPressed!();
            }
          : null,
      child: ElevatedButton(
        onPressed: onPressed,
        style: effectiveStyle,
        child: child,
      ),
    );
  }
}

/// 可访问性文本组件
class AccessibleText extends StatelessWidget {
  const AccessibleText(
    this.data, {
    super.key,
    this.style,
    this.semanticLabel,
    this.isHeader = false,
    this.headerLevel = 1,
  });

  /// 文本内容
  final String data;

  /// 文本样式
  final TextStyle? style;

  /// 语义标签
  final String? semanticLabel;

  /// 是否为标题
  final bool isHeader;

  /// 标题级别 (1-6)
  final int headerLevel;

  @override
  Widget build(BuildContext context) {
    var effectiveStyle = style ?? Theme.of(context).textTheme.bodyMedium!;

    if (AccessibilityTheme.shouldUseHighContrast(context)) {
      effectiveStyle = AccessibilityTheme.getAccessibleTextStyle(
        context,
        normalStyle: effectiveStyle,
      );
    }

    if (isHeader) {
      // 根据标题级别调整样式
      final headerStyles = [
        Theme.of(context).textTheme.displayLarge,
        Theme.of(context).textTheme.displayMedium,
        Theme.of(context).textTheme.displaySmall,
        Theme.of(context).textTheme.headlineLarge,
        Theme.of(context).textTheme.headlineMedium,
        Theme.of(context).textTheme.headlineSmall,
      ];

      final headerIndex = (headerLevel - 1).clamp(0, headerStyles.length - 1);
      effectiveStyle = headerStyles[headerIndex] ?? effectiveStyle;

      if (AccessibilityTheme.shouldUseHighContrast(context)) {
        effectiveStyle = AccessibilityTheme.getAccessibleTextStyle(
          context,
          normalStyle: effectiveStyle,
        );
      }
    }

    return AccessibilityWrapper(
      semanticLabel: semanticLabel ?? data,
      isHeader: isHeader,
      child: Text(data, style: effectiveStyle),
    );
  }
}

/// 可访问性输入框组件
class AccessibleTextField extends StatefulWidget {
  const AccessibleTextField({
    super.key,
    this.controller,
    this.decoration,
    this.semanticLabel,
    this.semanticHint,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.announceChanges = false,
  });

  /// 文本控制器
  final TextEditingController? controller;

  /// 输入框装饰
  final InputDecoration? decoration;

  /// 语义标签
  final String? semanticLabel;

  /// 语义提示
  final String? semanticHint;

  /// 文本变化回调
  final ValueChanged<String>? onChanged;

  /// 提交回调
  final ValueChanged<String>? onSubmitted;

  /// 焦点节点
  final FocusNode? focusNode;

  /// 是否播报文本变化
  final bool announceChanges;

  @override
  State<AccessibleTextField> createState() => _AccessibleTextFieldState();
}

class _AccessibleTextFieldState extends State<AccessibleTextField> {
  late TextEditingController _controller;
  String _lastAnnouncedText = '';

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() {
    if (widget.announceChanges && _controller.text != _lastAnnouncedText) {
      _lastAnnouncedText = _controller.text;
      if (_controller.text.isNotEmpty) {
        SemanticsService.announce(
          '输入内容：${_controller.text}',
          TextDirection.ltr,
        );
      }
    }

    widget.onChanged?.call(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    var effectiveDecoration =
        widget.decoration ?? const InputDecoration();

    if (AccessibilityTheme.shouldUseHighContrast(context)) {
      effectiveDecoration = effectiveDecoration.copyWith(
        labelStyle: AccessibilityTheme.getAccessibleTextStyle(
          context,
          normalStyle: effectiveDecoration.labelStyle ?? const TextStyle(),
        ),
        hintStyle: AccessibilityTheme.getAccessibleTextStyle(
          context,
          normalStyle: effectiveDecoration.hintStyle ?? const TextStyle(),
        ),
      );
    }

    return AccessibilityWrapper(
      semanticLabel: widget.semanticLabel ?? effectiveDecoration.labelText,
      semanticHint: widget.semanticHint ?? effectiveDecoration.hintText,
      isTextField: true,
      focusNode: widget.focusNode,
      announceOnFocus: true,
      customAnnouncement: '${widget.semanticLabel ?? '输入框'}已获得焦点',
      child: TextField(
        controller: _controller,
        decoration: effectiveDecoration,
        onSubmitted: widget.onSubmitted,
        focusNode: widget.focusNode,
        style: AccessibilityTheme.shouldUseHighContrast(context)
            ? AccessibilityTheme.getAccessibleTextStyle(
                context,
                normalStyle: const TextStyle(fontSize: 16),
              )
            : null,
      ),
    );
  }
}

/// 可访问性图标按钮组件
class AccessibleIconButton extends StatelessWidget {
  const AccessibleIconButton({
    required this.onPressed,
    required this.icon,
    super.key,
    this.semanticLabel,
    this.semanticHint,
    this.tooltip,
    this.focusNode,
    this.announceOnPress = false,
  });

  /// 按钮回调
  final VoidCallback? onPressed;

  /// 图标
  final Widget icon;

  /// 语义标签
  final String? semanticLabel;

  /// 语义提示
  final String? semanticHint;

  /// 工具提示
  final String? tooltip;

  /// 焦点节点
  final FocusNode? focusNode;

  /// 按下时是否播报
  final bool announceOnPress;

  @override
  Widget build(BuildContext context) {
    final isHighContrast = AccessibilityTheme.shouldUseHighContrast(context);

    var iconWidget = icon;

    if (isHighContrast && icon is Icon) {
      final originalIcon = icon as Icon;
      iconWidget = Icon(
        originalIcon.icon,
        size: AccessibilityTheme.getAccessibleIconSize(
          context,
          normalSize: originalIcon.size ?? 24,
        ),
        color: Theme.of(context).colorScheme.onSurface,
      );
    }

    return AccessibilityWrapper(
      semanticLabel: semanticLabel ?? tooltip,
      semanticHint: semanticHint,
      isButton: true,
      focusNode: focusNode,
      onTap: onPressed != null
          ? () {
              if (announceOnPress) {
                final announcement = semanticLabel ?? tooltip ?? '图标按钮已按下';
                SemanticsService.announce(announcement, TextDirection.ltr);
              }
              onPressed!();
            }
          : null,
      child: IconButton(
        onPressed: onPressed,
        icon: iconWidget,
        tooltip: tooltip,
        focusNode: focusNode,
      ),
    );
  }
}
