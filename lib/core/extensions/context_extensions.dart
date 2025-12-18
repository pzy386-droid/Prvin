import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/app_bloc.dart';

/// Context扩展，提供便捷的BLoC访问方法
extension ContextExtensions on BuildContext {
  /// 获取应用BLoC
  AppBloc get appBloc => read<AppBloc>();

  /// 监听应用状态
  AppState get appState => watch<AppBloc>().state;

  /// 获取主题模式
  bool get isDarkMode {
    final state = read<AppBloc>().state;
    if (state is AppReadyState) {
      return state.isDarkMode;
    }
    return false;
  }

  /// 获取当前语言
  String get currentLanguage {
    final state = read<AppBloc>().state;
    if (state is AppReadyState) {
      return state.languageCode;
    }
    return 'zh';
  }

  /// 切换主题
  void toggleTheme() {
    final currentState = read<AppBloc>().state;
    if (currentState is AppReadyState) {
      read<AppBloc>().add(AppThemeChangedEvent(!currentState.isDarkMode));
    }
  }

  /// 切换语言
  void changeLanguage(String languageCode) {
    read<AppBloc>().add(AppLanguageChangedEvent(languageCode));
  }

  /// 显示加载对话框
  void showLoadingDialog() {
    showDialog(
      context: this,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  /// 隐藏加载对话框
  void hideLoadingDialog() {
    Navigator.of(this).pop();
  }

  /// 显示错误消息
  void showErrorMessage(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 显示成功消息
  void showSuccessMessage(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
