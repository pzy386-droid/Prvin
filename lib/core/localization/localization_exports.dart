/// 本地化模块统一导出文件
///
/// 使用方式：
/// ```dart
/// import 'package:prvin/core/localization/localization_exports.dart';
///
/// // 在Widget中使用
/// Text(context.l10n('app_name'))
///
/// // 或者直接使用
/// Text(AppLocalizations.get('app_name'))
/// ```
library localization_exports;

export 'app_localizations.dart';
export 'app_strings.dart';
