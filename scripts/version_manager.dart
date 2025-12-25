#!/usr/bin/env dart

/// Prvin AI智能日历 - 版本管理脚本
/// 用于自动化版本号管理、标签创建和发布准备

import 'dart:io';
import 'dart:convert';

class VersionManager {
  static const String pubspecPath = 'pubspec.yaml';
  static const String releaseConfigPath = 'release.config.yaml';

  /// 获取当前版本信息
  static Map<String, dynamic> getCurrentVersion() {
    final pubspecFile = File(pubspecPath);
    if (!pubspecFile.existsSync()) {
      throw Exception('pubspec.yaml not found');
    }

    final content = pubspecFile.readAsStringSync();
    final versionLine = content
        .split('\n')
        .firstWhere((line) => line.startsWith('version:'));

    final versionString = versionLine.split(':')[1].trim();
    final parts = versionString.split('+');
    final version = parts[0];
    final buildNumber = int.parse(parts[1]);

    return {
      'version': version,
      'buildNumber': buildNumber,
      'fullVersion': versionString,
    };
  }

  /// 更新版本号
  static void updateVersion(String newVersion, int newBuildNumber) {
    final pubspecFile = File(pubspecPath);
    var content = pubspecFile.readAsStringSync();

    final currentVersionInfo = getCurrentVersion();
    final oldVersionLine = 'version: ${currentVersionInfo['fullVersion']}';
    final newVersionLine = 'version: $newVersion+$newBuildNumber';

    content = content.replaceAll(oldVersionLine, newVersionLine);
    pubspecFile.writeAsStringSync(content);

    print('✅ 版本已更新: $newVersion+$newBuildNumber');
  }

  /// 递增版本号
  static void incrementVersion(String type) {
    final currentVersionInfo = getCurrentVersion();
    final version = currentVersionInfo['version'] as String;
    final buildNumber = currentVersionInfo['buildNumber'] as int;

    final versionParts = version.split('.').map(int.parse).toList();
    int major = versionParts[0];
    int minor = versionParts[1];
    int patch = versionParts[2];

    switch (type.toLowerCase()) {
      case 'major':
        major++;
        minor = 0;
        patch = 0;
        break;
      case 'minor':
        minor++;
        patch = 0;
        break;
      case 'patch':
        patch++;
        break;
      default:
        throw Exception(
          'Invalid version type: $type. Use major, minor, or patch',
        );
    }

    final newVersion = '$major.$minor.$patch';
    final newBuildNumber = buildNumber + 1;

    updateVersion(newVersion, newBuildNumber);
  }

  /// 创建Git标签
  static void createGitTag() {
    final versionInfo = getCurrentVersion();
    final version = versionInfo['version'] as String;
    final tag = 'v$version';

    // 检查标签是否已存在
    final checkResult = Process.runSync('git', ['tag', '-l', tag]);
    if (checkResult.stdout.toString().trim().isNotEmpty) {
      print('⚠️  标签 $tag 已存在');
      return;
    }

    // 创建标签
    final result = Process.runSync('git', [
      'tag',
      '-a',
      tag,
      '-m',
      'Release $version',
    ]);
    if (result.exitCode == 0) {
      print('✅ Git标签已创建: $tag');
    } else {
      print('❌ 创建Git标签失败: ${result.stderr}');
    }
  }

  /// 推送标签到远程仓库
  static void pushTags() {
    final result = Process.runSync('git', ['push', '--tags']);
    if (result.exitCode == 0) {
      print('✅ 标签已推送到远程仓库');
    } else {
      print('❌ 推送标签失败: ${result.stderr}');
    }
  }

  /// 生成更新日志
  static void generateChangelog() {
    final versionInfo = getCurrentVersion();
    final version = versionInfo['version'] as String;
    final date = DateTime.now().toIso8601String().split('T')[0];

    final changelogEntry =
        '''
## [$version] - $date

### 新增功能
- 完整的AI智能日历系统
- 一键语言切换功能
- 番茄钟专注模式
- 任务管理和智能分类
- Web平台PWA支持
- 外部日历同步

### 改进
- 优化用户界面和交互体验
- 提升应用性能和响应速度
- 完善错误处理和用户反馈
- 增强可访问性支持

### 修复
- 修复已知的界面显示问题
- 解决数据同步冲突
- 优化内存使用和性能

### 技术改进
- 完善测试覆盖率
- 优化代码结构和架构
- 更新依赖包版本
- 改进CI/CD流水线

''';

    final changelogFile = File('CHANGELOG.md');
    String content = '';

    if (changelogFile.existsSync()) {
      content = changelogFile.readAsStringSync();
    } else {
      content = '# 更新日志\n\n本文档记录了Prvin AI智能日历的所有重要更改。\n\n';
    }

    // 在文件开头插入新的更新日志条目
    final lines = content.split('\n');
    final headerIndex = lines.indexWhere((line) => line.startsWith('# '));
    if (headerIndex != -1) {
      lines.insert(headerIndex + 2, changelogEntry);
    } else {
      lines.add(changelogEntry);
    }

    changelogFile.writeAsStringSync(lines.join('\n'));
    print('✅ 更新日志已生成');
  }

  /// 准备发布
  static void prepareRelease(String type) {
    print('🚀 开始准备发布...');

    try {
      // 1. 递增版本号
      incrementVersion(type);

      // 2. 生成更新日志
      generateChangelog();

      // 3. 创建Git标签
      createGitTag();

      print('✅ 发布准备完成！');
      print('📝 下一步：');
      print(
        '   1. 检查并提交更改: git add . && git commit -m "chore: prepare release"',
      );
      print('   2. 推送到远程仓库: git push');
      print('   3. 推送标签: git push --tags');
      print('   4. 在GitHub上创建Release');
    } catch (e) {
      print('❌ 发布准备失败: $e');
      exit(1);
    }
  }
}

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    print('''
Prvin AI智能日历 - 版本管理工具

用法:
  dart scripts/version_manager.dart <command> [options]

命令:
  current              显示当前版本信息
  increment <type>     递增版本号 (major|minor|patch)
  tag                  创建Git标签
  push-tags           推送标签到远程仓库
  changelog           生成更新日志
  prepare <type>      准备发布 (major|minor|patch)

示例:
  dart scripts/version_manager.dart current
  dart scripts/version_manager.dart increment patch
  dart scripts/version_manager.dart prepare minor
''');
    return;
  }

  final command = arguments[0];

  try {
    switch (command) {
      case 'current':
        final versionInfo = VersionManager.getCurrentVersion();
        print('当前版本: ${versionInfo['fullVersion']}');
        break;

      case 'increment':
        if (arguments.length < 2) {
          print('❌ 请指定版本类型: major, minor, 或 patch');
          exit(1);
        }
        VersionManager.incrementVersion(arguments[1]);
        break;

      case 'tag':
        VersionManager.createGitTag();
        break;

      case 'push-tags':
        VersionManager.pushTags();
        break;

      case 'changelog':
        VersionManager.generateChangelog();
        break;

      case 'prepare':
        if (arguments.length < 2) {
          print('❌ 请指定版本类型: major, minor, 或 patch');
          exit(1);
        }
        VersionManager.prepareRelease(arguments[1]);
        break;

      default:
        print('❌ 未知命令: $command');
        exit(1);
    }
  } catch (e) {
    print('❌ 执行失败: $e');
    exit(1);
  }
}
