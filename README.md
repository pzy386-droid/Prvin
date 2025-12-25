# Prvin AI智能日历 - 完整集成应用

Prvin是一个现代化的跨平台智能日程管理应用，集成了AI驱动的任务管理、番茄钟专注模式、一键语言切换、Web平台支持和外部日历同步等功能。基于Flutter框架开发，提供移动端和Web端的无缝体验。

## ✨ 核心特性

### 📅 智能日历系统
- **多视图模式**: 月视图、周视图、日视图的流畅切换
- **任务可视化**: 彩色编码的任务类型和优先级显示
- **拖拽交互**: 支持任务在不同日期间的拖拽移动
- **时间冲突检测**: 智能检测并提醒时间冲突
- **响应式设计**: 适配不同屏幕尺寸的完美布局

### ✅ 任务管理系统
- **快速创建**: 一键创建任务，支持标题、时间、标签和优先级设置
- **智能分类**: AI自动建议任务分类和标签
- **完整编辑**: 支持任务的完整属性编辑功能
- **状态管理**: 待办、进行中、已完成、已取消状态跟踪
- **数据持久化**: 本地SQLite数据库存储，确保数据安全

### 🍅 番茄钟专注系统
- **沉浸式界面**: 圆形进度动画和呼吸式效果
- **专注模式**: 阻止非紧急通知，提供纯净的专注环境
- **统计分析**: 专注时间趋势和效率分析
- **任务关联**: 可为特定任务启动番茄钟计时
- **成就系统**: 专注时长成就和激励机制

### 🤖 AI智能分析
- **工作模式分析**: 分析用户工作习惯，生成个性化报告
- **效率建议**: 基于数据提供专注时间建议和任务优化
- **智能分类**: 自动对相似任务进行分类和标签建议
- **学习适应**: 根据用户反馈持续改进推荐算法
- **数据可视化**: 时间分配图表和完成率统计

### 🌐 一键语言切换
- **即时切换**: 中英文之间的无缝快速切换
- **状态保持**: 切换过程中保持所有应用状态不变
- **持久化设置**: 自动保存并恢复用户语言偏好
- **流畅动画**: 提供优雅的切换动画和视觉反馈
- **错误处理**: 完善的错误处理和用户友好提示

### 🌍 Web平台支持
- **PWA功能**: 支持离线使用和原生应用体验
- **响应式布局**: 完美适配桌面端和移动端浏览器
- **键盘快捷键**: 支持桌面端快捷键操作
- **跨设备同步**: 实时数据同步，无缝设备切换
- **离线模式**: 网络中断时支持离线查看和编辑

### 🔄 外部服务集成
- **日历同步**: 支持Google Calendar、Outlook等主流服务
- **双向同步**: 保持本地和外部日历数据一致性
- **冲突解决**: 智能冲突检测和用户友好的解决选项
- **云端备份**: Firebase Firestore云端数据备份
- **实时更新**: 数据变更的实时同步和推送

### 🎨 现代化UI设计
- **毛玻璃效果**: 现代卡片式设计和柔和色彩方案
- **微交互动画**: 流畅的过渡动画和弹性效果
- **可访问性**: 完整的屏幕阅读器和键盘导航支持
- **主题适配**: 支持浅色/深色主题和高对比度模式
- **性能优化**: 60fps流畅动画和智能内存管理

## 🛠 技术架构

### 核心技术栈
- **框架**: Flutter 3.10+ (跨平台开发)
- **状态管理**: BLoC Pattern (响应式状态管理)
- **数据存储**: SQLite + SharedPreferences (本地数据持久化)
- **云端服务**: Firebase Firestore + Auth (云端同步和认证)
- **网络请求**: Dio + HTTP (网络通信)
- **动画系统**: Lottie + Flutter Animations (流畅动画效果)
- **测试框架**: Flutter Test + Mockito + Faker (全面测试覆盖)

### 项目架构
```
lib/
├── core/                    # 核心功能层
│   ├── bloc/               # BLoC状态管理
│   ├── cache/              # 缓存管理
│   ├── constants/          # 应用常量
│   ├── database/           # 数据库层
│   ├── error/              # 错误处理
│   ├── extensions/         # 扩展方法
│   ├── localization/       # 国际化支持
│   ├── services/           # 核心服务
│   ├── theme/              # 主题系统
│   ├── utils/              # 工具类
│   └── widgets/            # 通用组件
├── features/               # 功能模块
│   ├── ai/                 # AI分析功能
│   ├── calendar/           # 日历功能
│   ├── pomodoro/           # 番茄钟功能
│   ├── sync/               # 同步功能
│   └── task_management/    # 任务管理
├── previews/               # 组件预览
├── integrated_calendar_with_pomodoro.dart  # 集成应用
└── main.dart               # 应用入口
```

### 分层架构设计
```
┌─────────────────────────────────────────────────────────────┐
│                        UI Layer                             │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐           │
│  │  Calendar   │ │  Pomodoro   │ │  Language   │           │
│  │  Interface  │ │   Timer     │ │   Toggle    │           │
│  └─────────────┘ └─────────────┘ └─────────────┘           │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│                   Business Logic Layer                     │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐           │
│  │    Task     │ │     AI      │ │    Sync     │           │
│  │  Manager    │ │   Engine    │ │  Service    │           │
│  └─────────────┘ └─────────────┘ └─────────────┘           │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                            │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐           │
│  │   Local     │ │   Cloud     │ │  External   │           │
│  │  Storage    │ │   Sync      │ │  Calendar   │           │
│  └─────────────┘ └─────────────┘ └─────────────┘           │
└─────────────────────────────────────────────────────────────┘
```

## 📊 开发状态

### ✅ 已完成功能 (90%+)
- **核心架构**: 完整的Clean Architecture、BLoC状态管理、依赖注入
- **数据层**: SQLite数据库、缓存管理、数据源实现
- **业务逻辑**: 任务管理、番茄钟计时、AI分析引擎
- **UI界面**: 集成日历界面、任务管理界面、番茄钟界面
- **语言切换**: 完整的一键语言切换功能
- **主题系统**: 现代化UI设计、动画系统、响应式布局
- **Web平台**: PWA支持、响应式设计、键盘快捷键
- **测试覆盖**: 100+测试用例，包括属性测试和集成测试

### 🔄 进行中功能
- **AI算法优化**: 智能分类和建议算法的持续改进
- **外部服务集成**: Google Calendar、Outlook等服务的完善
- **性能优化**: 动画性能和内存管理的进一步优化
- **可访问性**: 屏幕阅读器和语音控制功能的完善

### 📋 待完成功能
- **帮助系统**: 应用内引导教程和上下文帮助
- **文档完善**: 用户指南和开发者文档
- **CI/CD流水线**: 自动化构建和部署
- **应用商店发布**: 移动端应用商店上架

## 🚀 快速开始

### 环境要求
- Flutter SDK 3.10.4 或更高版本
- Dart SDK 3.10.4 或更高版本
- Android Studio / VS Code (推荐)
- Git

### 安装步骤

1. **克隆项目**
   ```bash
   git clone https://github.com/pzy386-droid/Prvin.git
   cd Prvin
   ```

2. **安装依赖**
   ```bash
   flutter pub get
   ```

3. **运行应用**
   ```bash
   # 移动端运行
   flutter run
   
   # Web端运行
   flutter run -d chrome
   
   # 指定设备运行
   flutter devices
   flutter run -d [device-id]
   ```

4. **运行测试**
   ```bash
   # 运行所有测试
   flutter test
   
   # 运行特定测试文件
   flutter test test/core/widgets/one_click_language_toggle_button_test.dart
   
   # 运行属性测试
   flutter test test/core/widgets/language_toggle_consistency_property_test.dart
   ```

### 构建发布版本

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS (需要macOS)
flutter build ios --release

# Web版本
flutter build web --release
```

## 🌍 语言支持

Prvin支持双语操作，提供即时语言切换功能：

### 支持语言
- 🇨🇳 **中文** - 完整的中文本地化，80+翻译字符串
- 🇺🇸 **English** - 完整英文支持，无缝切换体验

### 一键语言切换特性
- ⚡ **即时切换** - 无需对话框确认的快速切换
- 💾 **持久化设置** - 自动保存并恢复语言偏好
- 🔄 **状态保持** - 切换过程中保持所有应用状态
- ♿ **可访问性** - 完整的屏幕阅读器和键盘导航支持
- 🎨 **流畅动画** - 优雅的切换动画和视觉反馈

### 使用示例

```dart
// 程序化切换语言
await context.toggleLanguage();

// 组件使用
OneClickLanguageToggleButton(
  size: 40.0,
  animationDuration: Duration(milliseconds: 300),
)

// 获取本地化文本
Text(context.l10n('calendar', fallback: '日历'))
```

详细使用指南请参考：[语言切换指南](docs/language_switching_guide.md)

## 📱 功能演示

### 日历界面
- **月视图**: 完整月份日历，彩色任务预览
- **任务拖拽**: 支持任务在不同日期间拖拽移动
- **快速创建**: 点击日期快速创建任务
- **时间冲突**: 智能检测并提醒时间冲突

### 任务管理
- **分类标签**: 工作、个人、学习、健康、社交等分类
- **优先级**: 低、中、高、紧急四个优先级
- **状态跟踪**: 待办、进行中、已完成、已取消
- **AI建议**: 智能分类和标签建议

### 番茄钟专注
- **沉浸式界面**: 圆形进度动画和呼吸效果
- **专注统计**: 每日、每周、每月专注时间统计
- **任务关联**: 为特定任务启动专注计时
- **成就系统**: 专注时长成就和激励

### AI智能分析
- **工作模式**: 分析用户工作习惯和时间分配
- **效率建议**: 基于数据提供个性化改进建议
- **趋势分析**: 完成率趋势和生产力分析
- **智能分类**: 自动任务分类和标签建议

## 🧪 测试覆盖

项目采用全面的测试策略，确保代码质量和功能正确性：

### 测试类型
- **单元测试**: 验证具体功能和边界条件
- **属性测试**: 验证通用属性和正确性保证
- **集成测试**: 验证模块间协作和端到端流程
- **UI测试**: 验证用户界面和交互体验

### 测试统计
- **总测试数**: 100+ 测试用例
- **覆盖率**: 80%+ 代码覆盖率
- **属性测试**: 30+ 基于属性的测试
- **性能测试**: 启动时间、响应时间、内存使用

### 运行测试
```bash
# 运行所有测试
flutter test

# 运行特定模块测试
flutter test test/features/task_management/

# 运行属性测试
flutter test test/core/widgets/language_toggle_consistency_property_test.dart

# 生成测试覆盖率报告
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## 🔧 开发指南

### 代码规范
- 遵循 [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- 使用 `very_good_analysis` 进行代码质量检查
- 所有公共API必须有文档注释
- 提交前运行 `flutter analyze` 和 `flutter test`

### 项目结构说明
```
lib/
├── core/                    # 核心功能，不依赖具体业务
│   ├── bloc/               # 全局BLoC和状态管理
│   ├── cache/              # 缓存管理和策略
│   ├── constants/          # 应用常量和配置
│   ├── database/           # 数据库抽象和实现
│   ├── error/              # 错误处理和异常定义
│   ├── extensions/         # Dart扩展方法
│   ├── localization/       # 国际化和本地化
│   ├── services/           # 核心服务和工具
│   ├── theme/              # 主题和UI配置
│   ├── utils/              # 工具类和辅助函数
│   └── widgets/            # 通用UI组件
├── features/               # 业务功能模块
│   ├── ai/                 # AI分析和智能推荐
│   ├── calendar/           # 日历显示和交互
│   ├── pomodoro/           # 番茄钟和专注管理
│   ├── sync/               # 数据同步和外部集成
│   └── task_management/    # 任务管理和CRUD操作
└── previews/               # 组件预览和开发工具
```

### 添加新功能
1. 在 `features/` 下创建新的功能模块
2. 遵循Clean Architecture分层结构
3. 实现对应的BLoC状态管理
4. 编写单元测试和属性测试
5. 更新文档和示例

### 性能优化
- 使用 `const` 构造函数减少重建
- 合理使用 `ListView.builder` 处理大列表
- 避免在 `build` 方法中创建复杂对象
- 使用 `RepaintBoundary` 优化动画性能

## 🤝 贡献指南

我们欢迎社区贡献！请遵循以下步骤：

### 贡献流程
1. **Fork** 项目到你的GitHub账户
2. **创建分支** 用于你的功能开发
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **提交更改** 并写清楚的提交信息
   ```bash
   git commit -m "feat: add new feature description"
   ```
4. **推送分支** 到你的Fork仓库
   ```bash
   git push origin feature/your-feature-name
   ```
5. **创建Pull Request** 并详细描述你的更改

### 提交规范
使用 [Conventional Commits](https://www.conventionalcommits.org/) 规范：
- `feat:` 新功能
- `fix:` 错误修复
- `docs:` 文档更新
- `style:` 代码格式调整
- `refactor:` 代码重构
- `test:` 测试相关
- `chore:` 构建过程或辅助工具的变动

### 代码审查
- 所有PR都需要代码审查
- 确保测试通过和代码质量检查
- 遵循项目的编码规范
- 提供清晰的PR描述和测试说明

## 📄 许可证

本项目采用 [MIT License](LICENSE) 许可证。

## 🙏 致谢

感谢以下开源项目和社区的支持：
- [Flutter](https://flutter.dev/) - 跨平台UI框架
- [BLoC](https://bloclibrary.dev/) - 状态管理库
- [Firebase](https://firebase.google.com/) - 云端服务
- [Material Design](https://material.io/) - 设计系统

## 📞 联系我们

- **项目主页**: [GitHub Repository](https://github.com/pzy386-droid/Prvin)
- **问题反馈**: [Issues](https://github.com/pzy386-droid/Prvin/issues)
- **功能建议**: [Discussions](https://github.com/pzy386-droid/Prvin/discussions)
- **邮箱**: your-email@example.com

---

**Prvin AI智能日历** - 让时间管理更智能，让生活更高效！ 🚀
