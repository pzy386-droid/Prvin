# Prvin - AI智能日程表应用

Prvin是一个集成人工智能功能的现代化日历和任务管理系统，提供直观的日历界面、任务管理功能、番茄钟专注模式，以及AI驱动的智能分析和建议功能。

## 功能特性

- 📅 **智能日历** - 月/周/日视图，颜色分区显示不同任务类型
- ✅ **任务管理** - 快速添加任务，设置时间、标签、优先级
- 🍅 **番茄钟** - 专注时间管理，沉浸式计时界面
- 🤖 **AI分析** - 智能任务分类，数据分析，专注时间建议
- 🔄 **日历同步** - 支持Google Calendar、Outlook等外部服务
- 🎨 **现代UI** - 卡片式设计，微动效，柔和色系

## 技术栈

- **框架**: Flutter 3.10+
- **状态管理**: BLoC Pattern
- **数据存储**: SQLite + SharedPreferences
- **网络请求**: Dio + HTTP
- **动画**: Lottie + Flutter Animations
- **测试**: Flutter Test + Mockito + Faker

## 项目结构

```
lib/
├── core/                 # 核心功能
│   ├── constants/       # 应用常量
│   ├── theme/          # 主题配置
│   ├── error/          # 错误处理
│   ├── utils/          # 工具类
│   └── services/       # 核心服务
├── features/           # 功能模块
│   ├── calendar/       # 日历功能
│   ├── tasks/          # 任务管理
│   ├── pomodoro/       # 番茄钟
│   ├── ai/             # AI分析
│   └── sync/           # 同步功能
└── main.dart           # 应用入口
```

## 开发进度

- [x] 项目初始化和核心架构搭建
- [x] 核心数据模型实现
- [x] 数据模型属性测试
- [x] 事件总线和状态管理
- [x] 本地存储服务实现（数据库、缓存、数据源）
- [x] 数据访问层完整实现
- [ ] 数据迁移属性测试（待完善）
- [ ] 业务逻辑层实现（Repository层）
- [ ] UI层实现
- [ ] 集成测试

## 当前状态

**已完成的功能模块：**
- ✅ 核心架构：依赖注入、事件总线、主题系统、BLoC状态管理
- ✅ 数据模型：Task、PomodoroSession、CalendarEvent、AnalyticsData
- ✅ 数据库层：SQLite数据库助手，完整的表结构和索引
- ✅ 缓存系统：LRU缓存管理器，支持TTL过期
- ✅ 数据源：任务、番茄钟、日历事件的本地数据源实现
- ✅ Repository层：任务仓库实现，封装数据访问逻辑
- ✅ 业务逻辑层：TaskManager用例，提供高级任务操作
- ✅ 测试覆盖：40个测试用例全部通过

**技术架构：**
```
UI层 (未实现)
    ↓
业务逻辑层 (UseCases)
    ├── TaskManager ✅
    ├── PomodoroTimer (待实现)
    └── AIAnalytics (待实现)
    ↓
领域层 (Domain)
    ├── Entities ✅
    └── Repositories (接口) ✅
    ↓
数据层 (Data)
    ├── Repositories (实现) ✅
    ├── DataSources ✅
    ├── Models ✅
    └── Cache ✅
    ↓
核心层 (Core)
    ├── Database ✅
    ├── BLoC ✅
    ├── DI ✅
    └── Theme ✅
```

**下一步工作：**
1. 实现番茄钟和AI分析的Repository和UseCase
2. 开始UI层开发（日历界面、任务列表、番茄钟界面）
3. 实现BLoC层连接UI和业务逻辑

## 开始使用

1. 确保已安装Flutter SDK (3.10+)
2. 克隆项目并安装依赖：
   ```bash
   flutter pub get
   ```
3. 运行应用：
   ```bash
   flutter run
   ```
4. 运行测试：
   ```bash
   flutter test
   ```

## 贡献

欢迎提交Issue和Pull Request来帮助改进Prvin！

## 许可证

MIT License
