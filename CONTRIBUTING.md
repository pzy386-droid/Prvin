# 贡献指南

感谢您对Prvin AI智能日历项目的关注！我们欢迎社区的贡献，无论是代码、文档、设计还是反馈建议。

## 🤝 如何贡献

### 贡献类型

我们欢迎以下类型的贡献：

- 🐛 **Bug修复**: 修复已知问题和缺陷
- ✨ **新功能**: 添加新的功能和特性
- 📚 **文档改进**: 完善文档、教程和示例
- 🎨 **UI/UX改进**: 优化用户界面和体验
- 🧪 **测试**: 添加或改进测试用例
- 🔧 **工具和基础设施**: 改进构建、部署和开发工具
- 🌐 **国际化**: 添加新语言支持或改进翻译
- 📈 **性能优化**: 提升应用性能和效率

### 贡献流程

1. **Fork项目**: 点击GitHub页面右上角的"Fork"按钮
2. **克隆仓库**: `git clone https://github.com/your-username/prvin-ai-calendar.git`
3. **创建分支**: `git checkout -b feature/your-feature-name`
4. **进行开发**: 实现您的功能或修复
5. **提交更改**: `git commit -m "feat: add your feature"`
6. **推送分支**: `git push origin feature/your-feature-name`
7. **创建PR**: 在GitHub上创建Pull Request

## 📋 开发环境设置

### 环境要求

- **Flutter SDK**: 3.10.4 或更高版本
- **Dart SDK**: 3.10.4 或更高版本
- **IDE**: Android Studio, VS Code, 或 IntelliJ IDEA
- **Git**: 版本控制工具

### 安装步骤

1. **安装Flutter**
   ```bash
   # 下载并安装Flutter SDK
   # 参考官方文档: https://flutter.dev/docs/get-started/install
   ```

2. **克隆项目**
   ```bash
   git clone https://github.com/pzy386-droid/Prvin.git
   cd Prvin
   ```

3. **安装依赖**
   ```bash
   flutter pub get
   ```

4. **运行应用**
   ```bash
   # 移动端
   flutter run
   
   # Web端
   flutter run -d chrome
   ```

5. **运行测试**
   ```bash
   flutter test
   ```

### 开发工具配置

#### VS Code
推荐安装以下扩展：
- Flutter
- Dart
- GitLens
- Bracket Pair Colorizer
- Material Icon Theme

#### Android Studio
确保安装了Flutter和Dart插件。

## 🏗️ 项目结构

```
lib/
├── core/                    # 核心功能层
│   ├── bloc/               # BLoC状态管理
│   ├── services/           # 核心服务
│   ├── widgets/            # 通用组件
│   └── theme/              # 主题系统
├── features/               # 功能模块
│   ├── calendar/           # 日历功能
│   ├── task_management/    # 任务管理
│   ├── pomodoro/           # 番茄钟
│   └── ai/                 # AI分析
└── main.dart               # 应用入口

test/                       # 测试代码
docs/                       # 项目文档
```

## 📝 编码规范

### Dart代码规范

遵循 [Effective Dart](https://dart.dev/guides/language/effective-dart) 指南：

1. **命名规范**
   ```dart
   // 类名使用PascalCase
   class TaskManager {}
   
   // 变量和函数使用camelCase
   String taskTitle = '';
   void createTask() {}
   
   // 常量使用lowerCamelCase
   const double defaultPadding = 16.0;
   
   // 私有成员使用下划线前缀
   String _privateField = '';
   ```

2. **代码格式**
   ```bash
   # 使用dart format格式化代码
   dart format .
   
   # 运行代码分析
   flutter analyze
   ```

3. **注释规范**
   ```dart
   /// 创建新任务
   /// 
   /// [title] 任务标题
   /// [description] 任务描述
   /// [dueDate] 截止日期
   /// 
   /// 返回创建的任务对象
   Future<Task> createTask({
     required String title,
     String? description,
     DateTime? dueDate,
   }) async {
     // 实现逻辑
   }
   ```

### 提交信息规范

使用 [Conventional Commits](https://www.conventionalcommits.org/) 规范：

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

#### 提交类型
- `feat`: 新功能
- `fix`: bug修复
- `docs`: 文档更新
- `style`: 代码格式调整
- `refactor`: 代码重构
- `test`: 测试相关
- `chore`: 构建过程或辅助工具的变动
- `perf`: 性能优化
- `ci`: CI/CD相关

#### 示例
```bash
feat(calendar): add drag and drop functionality
fix(auth): resolve login timeout issue
docs: update contributing guidelines
style: format code with dart format
refactor(database): optimize query performance
test: add unit tests for task manager
chore: update dependencies
perf: improve animation performance
ci: add automated testing workflow
```

## 🧪 测试指南

### 测试类型

1. **单元测试**: 测试单个函数或类
2. **组件测试**: 测试UI组件
3. **集成测试**: 测试功能流程
4. **属性测试**: 测试通用属性

### 编写测试

```dart
// 单元测试示例
import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/features/task_management/domain/entities/task.dart';

void main() {
  group('Task', () {
    test('should create task with required fields', () {
      // Arrange
      const title = 'Test Task';
      final dueDate = DateTime.now();
      
      // Act
      final task = Task(
        id: '1',
        title: title,
        dueDate: dueDate,
      );
      
      // Assert
      expect(task.title, equals(title));
      expect(task.dueDate, equals(dueDate));
    });
  });
}
```

```dart
// 组件测试示例
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/core/widgets/app_button.dart';

void main() {
  testWidgets('AppButton should display text and handle tap', (tester) async {
    // Arrange
    bool tapped = false;
    const buttonText = 'Test Button';
    
    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: AppButton(
          text: buttonText,
          onPressed: () => tapped = true,
        ),
      ),
    );
    
    // Assert
    expect(find.text(buttonText), findsOneWidget);
    
    await tester.tap(find.byType(AppButton));
    expect(tapped, isTrue);
  });
}
```

### 运行测试

```bash
# 运行所有测试
flutter test

# 运行特定测试文件
flutter test test/features/task_management/task_test.dart

# 运行测试并生成覆盖率报告
flutter test --coverage

# 查看覆盖率报告
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## 🎨 UI/UX指南

### 设计原则

1. **一致性**: 保持界面元素的一致性
2. **简洁性**: 避免不必要的复杂性
3. **可访问性**: 支持屏幕阅读器和键盘导航
4. **响应式**: 适配不同屏幕尺寸
5. **性能**: 确保流畅的用户体验

### 设计系统

- **颜色**: 使用Material Design色彩规范
- **字体**: 系统默认字体，确保可读性
- **间距**: 使用8dp网格系统
- **动画**: 遵循Material Motion指南

### 组件规范

```dart
// 使用现有的设计组件
AppButton(
  text: '确认',
  onPressed: () {},
  style: AppButtonStyle.primary,
)

AppCard(
  child: Text('内容'),
  elevation: 2,
)
```

## 🌐 国际化贡献

### 添加新语言

1. **创建语言文件**
   ```dart
   // lib/core/localization/app_strings_es.dart
   class AppStringsEs extends AppStrings {
     @override
     String get appTitle => 'Calendario Inteligente Prvin';
     
     @override
     String get calendar => 'Calendario';
     
     // 添加所有必需的翻译
   }
   ```

2. **注册语言**
   ```dart
   // lib/core/localization/app_localizations.dart
   static const List<Locale> supportedLocales = [
     Locale('zh', 'CN'),
     Locale('en', 'US'),
     Locale('es', 'ES'), // 新增语言
   ];
   ```

3. **测试翻译**
   - 确保所有文本都已翻译
   - 测试不同语言下的界面布局
   - 验证日期时间格式的本地化

## 📚 文档贡献

### 文档类型

- **README**: 项目介绍和快速开始
- **API文档**: 代码API文档
- **用户指南**: 功能使用说明
- **开发文档**: 技术实现细节
- **贡献指南**: 本文档

### 文档规范

1. **Markdown格式**: 使用标准Markdown语法
2. **结构清晰**: 使用合适的标题层级
3. **代码示例**: 提供可运行的代码示例
4. **截图说明**: 适当添加截图辅助说明
5. **链接检查**: 确保所有链接有效

### 文档更新

- 新功能需要更新相关文档
- API变更需要更新API文档
- 修复bug时更新故障排除文档
- 定期检查和更新过时信息

## 🔍 代码审查

### 审查清单

#### 功能性
- [ ] 功能实现符合需求
- [ ] 代码逻辑正确
- [ ] 错误处理完善
- [ ] 边界条件考虑充分

#### 代码质量
- [ ] 代码风格一致
- [ ] 命名清晰合理
- [ ] 注释充分
- [ ] 无重复代码

#### 性能
- [ ] 无明显性能问题
- [ ] 内存使用合理
- [ ] 网络请求优化
- [ ] 动画流畅

#### 测试
- [ ] 测试覆盖充分
- [ ] 测试用例有效
- [ ] 所有测试通过
- [ ] 无测试代码泄露

#### 安全性
- [ ] 无安全漏洞
- [ ] 输入验证完善
- [ ] 权限检查正确
- [ ] 敏感信息保护

### 审查流程

1. **自我审查**: 提交前自己先审查一遍
2. **同行审查**: 至少一个其他开发者审查
3. **测试验证**: 确保所有测试通过
4. **文档更新**: 必要时更新文档
5. **合并代码**: 审查通过后合并

## 🚀 发布流程

### 版本管理

使用语义化版本控制 (Semantic Versioning)：
- **MAJOR**: 不兼容的API更改
- **MINOR**: 向后兼容的功能添加
- **PATCH**: 向后兼容的bug修复

### 发布步骤

1. **准备发布**
   ```bash
   # 更新版本号
   dart scripts/version_manager.dart increment minor
   
   # 生成更新日志
   dart scripts/version_manager.dart changelog
   
   # 创建发布分支
   git checkout -b release/1.1.0
   ```

2. **测试验证**
   ```bash
   # 运行所有测试
   flutter test
   
   # 构建所有平台
   dart scripts/build_release.dart all
   
   # 手动测试关键功能
   ```

3. **创建发布**
   ```bash
   # 合并到主分支
   git checkout main
   git merge --no-ff release/1.1.0
   
   # 创建标签
   git tag -a v1.1.0 -m "Release version 1.1.0"
   
   # 推送更改
   git push origin main --tags
   ```

## 🎯 贡献建议

### 新手友好的任务

- 📝 改进文档和注释
- 🐛 修复简单的bug
- 🧪 添加测试用例
- 🌐 添加翻译
- 🎨 改进UI细节

### 寻找贡献机会

1. **查看Issues**: 寻找标记为 `good first issue` 的问题
2. **功能请求**: 实现社区需要的新功能
3. **性能优化**: 改进应用性能
4. **代码重构**: 优化代码结构
5. **文档完善**: 改进项目文档

### 获得帮助

- **GitHub Discussions**: 讨论想法和获取帮助
- **Issues**: 报告问题或寻求技术支持
- **代码审查**: 在PR中获取反馈
- **社区交流**: 参与项目相关讨论

## 📞 联系我们

- **GitHub Issues**: https://github.com/pzy386-droid/Prvin/issues
- **GitHub Discussions**: https://github.com/pzy386-droid/Prvin/discussions
- **邮箱**: your-email@example.com

## 🙏 致谢

感谢所有为Prvin AI智能日历项目做出贡献的开发者、设计师、测试人员和用户。您的贡献让这个项目变得更好！

---

**让我们一起打造更好的智能日历应用！** 🚀