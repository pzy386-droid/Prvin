# Prvin AI智能日历 - 分支策略

本文档描述了Prvin AI智能日历项目的Git分支策略和发布流程。

## 分支结构

### 主要分支

#### `main` 分支
- **用途**: 生产环境稳定版本
- **保护**: 受保护分支，只能通过PR合并
- **部署**: 自动部署到生产环境
- **标签**: 所有发布版本都在此分支打标签

#### `develop` 分支
- **用途**: 开发集成分支
- **保护**: 受保护分支，只能通过PR合并
- **部署**: 自动部署到测试环境
- **特性**: 包含最新的开发功能

### 支持分支

#### `feature/*` 分支
- **用途**: 新功能开发
- **命名**: `feature/功能名称` (如: `feature/ai-analysis`)
- **来源**: 从 `develop` 分支创建
- **合并**: 合并回 `develop` 分支
- **生命周期**: 功能完成后删除

#### `release/*` 分支
- **用途**: 发布准备
- **命名**: `release/版本号` (如: `release/1.1.0`)
- **来源**: 从 `develop` 分支创建
- **合并**: 合并到 `main` 和 `develop` 分支
- **生命周期**: 发布完成后删除

#### `hotfix/*` 分支
- **用途**: 紧急修复
- **命名**: `hotfix/修复描述` (如: `hotfix/critical-bug-fix`)
- **来源**: 从 `main` 分支创建
- **合并**: 合并到 `main` 和 `develop` 分支
- **生命周期**: 修复完成后删除

## 工作流程

### 功能开发流程

1. **创建功能分支**
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/new-feature
   ```

2. **开发和提交**
   ```bash
   # 进行开发工作
   git add .
   git commit -m "feat: add new feature"
   ```

3. **推送和创建PR**
   ```bash
   git push origin feature/new-feature
   # 在GitHub上创建PR到develop分支
   ```

4. **代码审查和合并**
   - 通过代码审查
   - 所有测试通过
   - 合并到develop分支
   - 删除功能分支

### 发布流程

1. **创建发布分支**
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b release/1.1.0
   ```

2. **发布准备**
   ```bash
   # 更新版本号
   dart scripts/version_manager.dart increment minor
   
   # 生成更新日志
   dart scripts/version_manager.dart changelog
   
   # 提交更改
   git add .
   git commit -m "chore: prepare release 1.1.0"
   ```

3. **测试和修复**
   - 进行全面测试
   - 修复发现的问题
   - 只允许bug修复，不允许新功能

4. **合并到主分支**
   ```bash
   # 合并到main分支
   git checkout main
   git merge --no-ff release/1.1.0
   
   # 创建标签
   git tag -a v1.1.0 -m "Release version 1.1.0"
   
   # 合并回develop分支
   git checkout develop
   git merge --no-ff release/1.1.0
   
   # 推送所有更改
   git push origin main develop --tags
   
   # 删除发布分支
   git branch -d release/1.1.0
   git push origin --delete release/1.1.0
   ```

### 热修复流程

1. **创建热修复分支**
   ```bash
   git checkout main
   git pull origin main
   git checkout -b hotfix/critical-fix
   ```

2. **修复问题**
   ```bash
   # 进行修复工作
   git add .
   git commit -m "fix: resolve critical issue"
   ```

3. **更新版本号**
   ```bash
   dart scripts/version_manager.dart increment patch
   git add .
   git commit -m "chore: bump version for hotfix"
   ```

4. **合并和发布**
   ```bash
   # 合并到main分支
   git checkout main
   git merge --no-ff hotfix/critical-fix
   git tag -a v1.0.1 -m "Hotfix version 1.0.1"
   
   # 合并到develop分支
   git checkout develop
   git merge --no-ff hotfix/critical-fix
   
   # 推送更改
   git push origin main develop --tags
   
   # 删除热修复分支
   git branch -d hotfix/critical-fix
   git push origin --delete hotfix/critical-fix
   ```

## 版本号规范

采用语义化版本控制 (Semantic Versioning)：

### 格式: `MAJOR.MINOR.PATCH`

- **MAJOR**: 不兼容的API更改
- **MINOR**: 向后兼容的功能添加
- **PATCH**: 向后兼容的bug修复

### 示例
- `1.0.0` - 首个稳定版本
- `1.1.0` - 添加新功能
- `1.1.1` - 修复bug
- `2.0.0` - 重大更新，可能不兼容

### 预发布版本
- `1.1.0-alpha.1` - 内测版本
- `1.1.0-beta.1` - 公测版本
- `1.1.0-rc.1` - 发布候选版本

## 提交信息规范

采用 [Conventional Commits](https://www.conventionalcommits.org/) 规范：

### 格式
```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### 类型 (type)
- `feat`: 新功能
- `fix`: bug修复
- `docs`: 文档更新
- `style`: 代码格式调整
- `refactor`: 代码重构
- `test`: 测试相关
- `chore`: 构建过程或辅助工具的变动
- `perf`: 性能优化
- `ci`: CI/CD相关

### 示例
```bash
feat(calendar): add drag and drop functionality
fix(auth): resolve login timeout issue
docs: update API documentation
style: format code with prettier
refactor(database): optimize query performance
test: add unit tests for task manager
chore: update dependencies
```

## 分支保护规则

### `main` 分支
- 禁止直接推送
- 需要PR审查
- 需要状态检查通过
- 需要分支是最新的
- 管理员可以绕过限制

### `develop` 分支
- 禁止直接推送
- 需要PR审查
- 需要状态检查通过
- 允许强制推送 (仅管理员)

## 自动化工作流

### GitHub Actions触发器

#### 推送到任何分支
- 运行测试
- 代码质量检查
- 构建验证

#### 推送到 `main` 分支
- 部署到生产环境
- 创建GitHub Release
- 发送通知

#### 推送到 `develop` 分支
- 部署到测试环境
- 运行集成测试

#### 创建标签
- 构建发布版本
- 上传构建产物
- 更新文档

## 最佳实践

### 分支命名
- 使用小写字母和连字符
- 包含简短的描述性名称
- 避免使用特殊字符

### 提交频率
- 经常提交小的更改
- 每个提交应该是一个逻辑单元
- 避免大型的单一提交

### 代码审查
- 所有PR都需要审查
- 审查者应该检查代码质量、测试覆盖率和文档
- 使用GitHub的审查功能提供反馈

### 测试要求
- 所有新功能都需要测试
- 修复bug时添加回归测试
- 保持测试覆盖率在80%以上

### 文档更新
- 新功能需要更新文档
- API更改需要更新文档
- 保持README和其他文档的最新状态

## 故障排除

### 常见问题

#### 合并冲突
```bash
# 解决冲突后
git add .
git commit -m "resolve merge conflicts"
```

#### 错误的分支
```bash
# 移动提交到正确的分支
git cherry-pick <commit-hash>
git checkout wrong-branch
git reset --hard HEAD~1
```

#### 撤销合并
```bash
# 撤销最后一次合并
git revert -m 1 HEAD
```

### 联系方式
如有问题，请联系项目维护者或在GitHub上创建Issue。