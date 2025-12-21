import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prvin/core/theme/theme_exports.dart';

/// 输入框类型枚举
enum AppInputType {
  /// 文本输入
  text,

  /// 密码输入
  password,

  /// 邮箱输入
  email,

  /// 数字输入
  number,

  /// 多行文本输入
  multiline,
}

/// 应用输入框组件
class AppInput extends StatefulWidget {
  /// 创建应用输入框
  const AppInput({
    super.key,
    this.controller,
    this.initialValue,
    this.type = AppInputType.text,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.maxLines,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.focusNode,
    this.autofocus = false,
    this.borderRadius,
    this.fillColor,
    this.contentPadding,
  });

  /// 文本控制器
  final TextEditingController? controller;

  /// 初始值
  final String? initialValue;

  /// 输入框类型
  final AppInputType type;

  /// 标签
  final String? label;

  /// 提示文本
  final String? hint;

  /// 帮助文本
  final String? helperText;

  /// 错误文本
  final String? errorText;

  /// 前缀图标
  final IconData? prefixIcon;

  /// 后缀图标
  final IconData? suffixIcon;

  /// 文本变化回调
  final ValueChanged<String>? onChanged;

  /// 提交回调
  final ValueChanged<String>? onSubmitted;

  /// 点击回调
  final VoidCallback? onTap;

  /// 验证器
  final String? Function(String?)? validator;

  /// 是否启用
  final bool enabled;

  /// 是否只读
  final bool readOnly;

  /// 是否隐藏文本
  final bool obscureText;

  /// 最大行数
  final int? maxLines;

  /// 最小行数
  final int? minLines;

  /// 最大长度
  final int? maxLength;

  /// 键盘类型
  final TextInputType? keyboardType;

  /// 文本输入动作
  final TextInputAction? textInputAction;

  /// 输入格式化器
  final List<TextInputFormatter>? inputFormatters;

  /// 焦点节点
  final FocusNode? focusNode;

  /// 是否自动聚焦
  final bool autofocus;

  /// 圆角半径
  final BorderRadius? borderRadius;

  /// 填充色
  final Color? fillColor;

  /// 内容边距
  final EdgeInsets? contentPadding;

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  late bool _obscureText;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText || widget.type == AppInputType.password;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: widget.errorText != null
                  ? AppTheme.errorColor
                  : _isFocused
                  ? AppTheme.primaryColor
                  : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
        ],

        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          focusNode: _focusNode,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          obscureText: _obscureText,
          autofocus: widget.autofocus,
          maxLines: _getMaxLines(),
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          keyboardType: _getKeyboardType(),
          textInputAction: widget.textInputAction,
          inputFormatters: _getInputFormatters(),
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          validator: widget.validator,
          decoration: InputDecoration(
            hintText: widget.hint,
            helperText: widget.helperText,
            errorText: widget.errorText,
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon)
                : null,
            suffixIcon: _buildSuffixIcon(),
            filled: true,
            fillColor: widget.fillColor ?? _getFillColor(theme),
            contentPadding:
                widget.contentPadding ??
                const EdgeInsets.all(AppTheme.spacingM),
            border: _getBorder(theme, false, false),
            enabledBorder: _getBorder(theme, false, false),
            focusedBorder: _getBorder(theme, true, false),
            errorBorder: _getBorder(theme, false, true),
            focusedErrorBorder: _getBorder(theme, true, true),
            counterText: '', // 隐藏字符计数器
          ),
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.type == AppInputType.password) {
      return IconButton(
        icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }

    if (widget.suffixIcon != null) {
      return Icon(widget.suffixIcon);
    }

    return null;
  }

  int? _getMaxLines() {
    if (widget.type == AppInputType.multiline) {
      return widget.maxLines ?? 3;
    }
    return widget.maxLines ?? 1;
  }

  TextInputType _getKeyboardType() {
    if (widget.keyboardType != null) {
      return widget.keyboardType!;
    }

    switch (widget.type) {
      case AppInputType.email:
        return TextInputType.emailAddress;
      case AppInputType.number:
        return TextInputType.number;
      case AppInputType.multiline:
        return TextInputType.multiline;
      case AppInputType.text:
      case AppInputType.password:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter>? _getInputFormatters() {
    if (widget.inputFormatters != null) {
      return widget.inputFormatters;
    }

    switch (widget.type) {
      case AppInputType.number:
        return [FilteringTextInputFormatter.digitsOnly];
      case AppInputType.text:
      case AppInputType.password:
      case AppInputType.email:
      case AppInputType.multiline:
        return null;
    }
  }

  Color _getFillColor(ThemeData theme) {
    if (widget.errorText != null) {
      return AppTheme.errorColor.withValues(alpha: 0.05);
    }

    if (_isFocused) {
      return AppTheme.primaryColor.withValues(alpha: 0.05);
    }

    return theme.brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade50;
  }

  OutlineInputBorder _getBorder(ThemeData theme, bool isFocused, bool isError) {
    Color borderColor;
    double borderWidth;

    if (isError) {
      borderColor = AppTheme.errorColor;
      borderWidth = isFocused ? 2 : 1;
    } else if (isFocused) {
      borderColor = AppTheme.primaryColor;
      borderWidth = 2;
    } else {
      borderColor = theme.brightness == Brightness.dark
          ? Colors.grey.shade600
          : Colors.grey.shade300;
      borderWidth = 1;
    }

    return OutlineInputBorder(
      borderRadius:
          widget.borderRadius ?? BorderRadius.circular(AppTheme.radiusM),
      borderSide: BorderSide(color: borderColor, width: borderWidth),
    );
  }
}

/// 搜索输入框组件
class AppSearchInput extends StatelessWidget {
  /// 创建搜索输入框
  const AppSearchInput({
    super.key,
    this.controller,
    this.hint = '搜索...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.enabled = true,
    this.autofocus = false,
  });

  /// 文本控制器
  final TextEditingController? controller;

  /// 提示文本
  final String hint;

  /// 文本变化回调
  final ValueChanged<String>? onChanged;

  /// 提交回调
  final ValueChanged<String>? onSubmitted;

  /// 清除回调
  final VoidCallback? onClear;

  /// 是否启用
  final bool enabled;

  /// 是否自动聚焦
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return AppInput(
      controller: controller,
      hint: hint,
      prefixIcon: Icons.search,
      suffixIcon: (controller?.text.isNotEmpty ?? false) ? Icons.clear : null,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      enabled: enabled,
      autofocus: autofocus,
      borderRadius: BorderRadius.circular(AppTheme.radiusXL),
    );
  }
}

/// 标签输入框组件
class AppTagInput extends StatefulWidget {
  /// 创建标签输入框
  const AppTagInput({
    super.key,
    this.initialTags = const [],
    this.onTagsChanged,
    this.hint = '添加标签...',
    this.maxTags,
    this.tagColor,
  });

  /// 初始标签
  final List<String> initialTags;

  /// 标签变化回调
  final ValueChanged<List<String>>? onTagsChanged;

  /// 提示文本
  final String hint;

  /// 最大标签数
  final int? maxTags;

  /// 标签颜色
  final Color? tagColor;

  @override
  State<AppTagInput> createState() => _AppTagInputState();
}

class _AppTagInputState extends State<AppTagInput> {
  late List<String> _tags;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tags = List.from(widget.initialTags);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    final trimmedTag = tag.trim();
    if (trimmedTag.isNotEmpty &&
        !_tags.contains(trimmedTag) &&
        (widget.maxTags == null || _tags.length < widget.maxTags!)) {
      setState(() {
        _tags.add(trimmedTag);
      });
      _controller.clear();
      widget.onTagsChanged?.call(_tags);
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
    widget.onTagsChanged?.call(_tags);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tagColor = widget.tagColor ?? AppTheme.primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标签显示
        if (_tags.isNotEmpty) ...[
          Wrap(
            spacing: AppTheme.spacingS,
            runSpacing: AppTheme.spacingS,
            children: _tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingM,
                  vertical: AppTheme.spacingS,
                ),
                decoration: BoxDecoration(
                  color: tagColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                  border: Border.all(color: tagColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tag,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: tagColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingXS),
                    GestureDetector(
                      onTap: () => _removeTag(tag),
                      child: Icon(Icons.close, size: 16, color: tagColor),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppTheme.spacingS),
        ],

        // 输入框
        AppInput(
          controller: _controller,
          hint: widget.hint,
          onSubmitted: _addTag,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }
}
