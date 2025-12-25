#!/usr/bin/env dart

/// Prvin AI智能日历 - 构建发布脚本
/// 用于自动化构建不同平台的发布版本

import 'dart:io';

class BuildManager {
  static const String outputDir = 'build/release';

  /// 清理构建目录
  static void cleanBuild() {
    print('🧹 清理构建目录...');

    final buildDir = Directory('build');
    if (buildDir.existsSync()) {
      buildDir.deleteSync(recursive: true);
    }

    final releaseDir = Directory(outputDir);
    if (!releaseDir.existsSync()) {
      releaseDir.createSync(recursive: true);
    }

    print('✅ 构建目录已清理');
  }

  /// 运行Flutter命令
  static ProcessResult runFlutterCommand(List<String> args) {
    print('🔨 执行: flutter ${args.join(' ')}');
    final result = Process.runSync('flutter', args);

    if (result.exitCode != 0) {
      print('❌ 命令执行失败:');
      print(result.stderr);
      exit(1);
    }

    return result;
  }

  /// 构建Android APK
  static void buildAndroidApk() {
    print('📱 构建Android APK...');

    runFlutterCommand(['build', 'apk', '--release']);

    // 复制APK到发布目录
    final apkSource = File('build/app/outputs/flutter-apk/app-release.apk');
    final apkTarget = File('$outputDir/prvin-android.apk');

    if (apkSource.existsSync()) {
      apkSource.copySync(apkTarget.path);
      print('✅ Android APK构建完成: ${apkTarget.path}');
    } else {
      print('❌ APK文件未找到');
    }
  }

  /// 构建Android App Bundle
  static void buildAndroidAppBundle() {
    print('📱 构建Android App Bundle...');

    runFlutterCommand(['build', 'appbundle', '--release']);

    // 复制AAB到发布目录
    final aabSource = File('build/app/outputs/bundle/release/app-release.aab');
    final aabTarget = File('$outputDir/prvin-android.aab');

    if (aabSource.existsSync()) {
      aabSource.copySync(aabTarget.path);
      print('✅ Android App Bundle构建完成: ${aabTarget.path}');
    } else {
      print('❌ AAB文件未找到');
    }
  }

  /// 构建iOS应用 (仅在macOS上可用)
  static void buildIos() {
    if (!Platform.isMacOS) {
      print('⚠️  iOS构建仅在macOS上可用，跳过...');
      return;
    }

    print('🍎 构建iOS应用...');

    runFlutterCommand(['build', 'ios', '--release']);

    print('✅ iOS构建完成 (需要在Xcode中进一步处理)');
  }

  /// 构建Web版本
  static void buildWeb() {
    print('🌐 构建Web版本...');

    runFlutterCommand(['build', 'web', '--release']);

    // 复制Web构建到发布目录
    final webSource = Directory('build/web');
    final webTarget = Directory('$outputDir/web');

    if (webSource.existsSync()) {
      if (webTarget.existsSync()) {
        webTarget.deleteSync(recursive: true);
      }

      // 递归复制目录
      copyDirectory(webSource, webTarget);
      print('✅ Web版本构建完成: ${webTarget.path}');
    } else {
      print('❌ Web构建目录未找到');
    }
  }

  /// 递归复制目录
  static void copyDirectory(Directory source, Directory target) {
    target.createSync(recursive: true);

    for (final entity in source.listSync()) {
      if (entity is File) {
        final targetFile = File(
          '${target.path}/${entity.uri.pathSegments.last}',
        );
        entity.copySync(targetFile.path);
      } else if (entity is Directory) {
        final targetDir = Directory(
          '${target.path}/${entity.uri.pathSegments[entity.uri.pathSegments.length - 2]}',
        );
        copyDirectory(entity, targetDir);
      }
    }
  }

  /// 生成构建信息文件
  static void generateBuildInfo() {
    print('📋 生成构建信息...');

    final buildTime = DateTime.now().toIso8601String();
    final gitCommit = _getGitCommit();
    final gitBranch = _getGitBranch();

    final buildInfo =
        '''
# Prvin AI智能日历 - 构建信息

## 构建详情
- **构建时间**: $buildTime
- **Git提交**: $gitCommit
- **Git分支**: $gitBranch
- **Flutter版本**: ${_getFlutterVersion()}
- **Dart版本**: ${_getDartVersion()}

## 构建产物
- **Android APK**: prvin-android.apk
- **Android App Bundle**: prvin-android.aab
- **Web版本**: web/
- **iOS应用**: 需要在macOS上构建

## 安装说明

### Android
1. 下载 `prvin-android.apk`
2. 在设备上启用"未知来源"安装
3. 安装APK文件

### Web
1. 将 `web/` 目录部署到Web服务器
2. 或直接打开 `web/index.html` 文件

### iOS
1. 需要在macOS上使用Xcode构建
2. 或等待App Store版本发布

## 系统要求
- **Android**: Android 5.0 (API 21) 或更高版本
- **iOS**: iOS 11.0 或更高版本
- **Web**: 现代浏览器 (Chrome 88+, Firefox 85+, Safari 14+)
''';

    final buildInfoFile = File('$outputDir/BUILD_INFO.md');
    buildInfoFile.writeAsStringSync(buildInfo);

    print('✅ 构建信息已生成: ${buildInfoFile.path}');
  }

  /// 获取Git提交哈希
  static String _getGitCommit() {
    try {
      final result = Process.runSync('git', ['rev-parse', '--short', 'HEAD']);
      return result.stdout.toString().trim();
    } catch (e) {
      return 'unknown';
    }
  }

  /// 获取Git分支
  static String _getGitBranch() {
    try {
      final result = Process.runSync('git', ['branch', '--show-current']);
      return result.stdout.toString().trim();
    } catch (e) {
      return 'unknown';
    }
  }

  /// 获取Flutter版本
  static String _getFlutterVersion() {
    try {
      final result = Process.runSync('flutter', ['--version']);
      final lines = result.stdout.toString().split('\n');
      return lines.first.trim();
    } catch (e) {
      return 'unknown';
    }
  }

  /// 获取Dart版本
  static String _getDartVersion() {
    try {
      final result = Process.runSync('dart', ['--version']);
      return result.stdout.toString().trim();
    } catch (e) {
      return 'unknown';
    }
  }

  /// 构建所有平台
  static void buildAll() {
    print('🚀 开始构建所有平台...');

    cleanBuild();

    // 检查Flutter环境
    print('🔍 检查Flutter环境...');
    runFlutterCommand(['doctor', '--verbose']);

    // 获取依赖
    print('📦 获取依赖...');
    runFlutterCommand(['pub', 'get']);

    // 运行测试
    print('🧪 运行测试...');
    runFlutterCommand(['test']);

    // 构建各平台
    buildWeb();
    buildAndroidApk();
    buildAndroidAppBundle();
    buildIos();

    // 生成构建信息
    generateBuildInfo();

    print('🎉 所有平台构建完成！');
    print('📁 构建产物位于: $outputDir');
  }
}

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    print('''
Prvin AI智能日历 - 构建工具

用法:
  dart scripts/build_release.dart <command>

命令:
  all                 构建所有平台
  web                 构建Web版本
  android-apk         构建Android APK
  android-aab         构建Android App Bundle
  ios                 构建iOS应用 (仅macOS)
  clean               清理构建目录
  info                生成构建信息

示例:
  dart scripts/build_release.dart all
  dart scripts/build_release.dart web
  dart scripts/build_release.dart android-apk
''');
    return;
  }

  final command = arguments[0];

  try {
    switch (command) {
      case 'all':
        BuildManager.buildAll();
        break;

      case 'web':
        BuildManager.cleanBuild();
        BuildManager.buildWeb();
        BuildManager.generateBuildInfo();
        break;

      case 'android-apk':
        BuildManager.cleanBuild();
        BuildManager.buildAndroidApk();
        BuildManager.generateBuildInfo();
        break;

      case 'android-aab':
        BuildManager.cleanBuild();
        BuildManager.buildAndroidAppBundle();
        BuildManager.generateBuildInfo();
        break;

      case 'ios':
        BuildManager.cleanBuild();
        BuildManager.buildIos();
        BuildManager.generateBuildInfo();
        break;

      case 'clean':
        BuildManager.cleanBuild();
        break;

      case 'info':
        BuildManager.generateBuildInfo();
        break;

      default:
        print('❌ 未知命令: $command');
        exit(1);
    }
  } catch (e) {
    print('❌ 构建失败: $e');
    exit(1);
  }
}
