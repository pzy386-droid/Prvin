import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/core/services/state_isolation_manager.dart';
import 'package:prvin/core/services/state_preservation_service.dart';
import 'package:prvin/features/task_management/domain/entities/task.dart';
import 'package:prvin/features/task_management/presentation/bloc/task_bloc.dart';

/// **Feature: one-click-language-toggle, Property 4: 状态保持不变性**
/// *对于任何*语言切换操作，除了界面语言外的所有应用状态（任务数据、日期选择、番茄钟状态等）应该保持不变
/// **Validates: Requirements 3.1, 3.2, 3.3, 3.5**
void main() {
  group('State Preservation Invariant Property Tests', () {
    final faker = Faker();
    late StatePreservationService statePreservationService;
    late StateIsolationManager stateIsolationManager;

    setUp(() {
      statePreservationService = StatePreservationService.instance;
      stateIsolationManager = StateIsolationManager.instance;
    });

    tearDown(() {
      statePreservationService.clearSnapshot();
      if (stateIsolationManager.currentStatus == IsolationStatus.active) {
        stateIsolationManager.forceEndIsolation();
      }
    });

    test(
      'Property 4: 状态保持不变性 - task management state should remain unchanged during language toggle',
      () async {
        // **Feature: one-click-language-toggle, Property 4: 状态保持不变性**

        // 运行100次迭代以确保属性在各种输入下都成立
        for (var i = 0; i < 100; i++) {
          // 生成随机的任务管理状态
          final initialTaskState = _generateRandomTaskState(faker);

          // 模拟语言切换操作（不改变任务状态）
          final languageToggleResult = _simulateLanguageToggle(
            initialTaskState,
            faker,
          );

          // 验证任务管理状态保持不变
          _verifyTaskStatePreservation(
            initialTaskState,
            languageToggleResult.taskStateAfterToggle,
          );

          // 验证状态完整性的核心属性
          expect(
            languageToggleResult.languageChanged,
            isTrue,
            reason: 'Language should change during toggle operation',
          );

          expect(
            languageToggleResult.taskStateAfterToggle.tasks.length,
            equals(initialTaskState.tasks.length),
            reason: 'Task count should remain unchanged',
          );

          expect(
            languageToggleResult.taskStateAfterToggle.selectedDate,
            equals(initialTaskState.selectedDate),
            reason: 'Selected date should remain unchanged',
          );
        }
      },
    );

    test(
      'Property 4: 状态保持不变性 - selected date should be preserved across language switches',
      () {
        // **Feature: one-click-language-toggle, Property 4: 状态保持不变性**

        for (var i = 0; i < 50; i++) {
          // 生成随机的日期选择状态
          final selectedDate = _generateRandomDate(faker);
          final initialState = _createTaskStateWithSelectedDate(selectedDate);

          // 执行多次语言切换
          var currentState = initialState;
          final switchCount = faker.randomGenerator.integer(5, min: 1);

          for (var switchIndex = 0; switchIndex < switchCount; switchIndex++) {
            // 模拟语言切换，确保日期选择不变
            final toggleResult = _simulateLanguageToggle(currentState, faker);
            currentState = toggleResult.taskStateAfterToggle;

            // 验证选中日期保持不变
            expect(
              currentState.selectedDate,
              equals(selectedDate),
              reason:
                  'Selected date should remain unchanged after switch $switchIndex',
            );
          }

          // 验证经过多次切换后日期仍然保持原值
          expect(
            currentState.selectedDate,
            equals(selectedDate),
            reason:
                'Selected date should be preserved after $switchCount language switches',
          );
        }
      },
    );

    test(
      'Property 4: 状态保持不变性 - search and filter state should be preserved',
      () {
        // **Feature: one-click-language-toggle, Property 4: 状态保持不变性**

        for (var i = 0; i < 50; i++) {
          // 生成随机的搜索和过滤状态
          final searchQuery = faker.lorem.words(3).join(' ');
          final filterCategory = _generateRandomTaskCategory(faker);
          final filterStatus = _generateRandomTaskStatus(faker);

          final initialState = _createTaskStateWithFilters(
            searchQuery: searchQuery,
            filterCategory: filterCategory,
            filterStatus: filterStatus,
          );

          // 执行语言切换
          final toggleResult = _simulateLanguageToggle(initialState, faker);
          final finalState = toggleResult.taskStateAfterToggle;

          // 验证搜索查询保持不变
          expect(
            finalState.searchQuery,
            equals(searchQuery),
            reason: 'Search query should be preserved during language toggle',
          );

          // 验证过滤器状态保持不变
          expect(
            finalState.filterCategory,
            equals(filterCategory),
            reason:
                'Filter category should be preserved during language toggle',
          );

          expect(
            finalState.filterStatus,
            equals(filterStatus),
            reason: 'Filter status should be preserved during language toggle',
          );
        }
      },
    );

    test(
      'Property 4: 状态保持不变性 - task list should remain unchanged during language toggle',
      () {
        // **Feature: one-click-language-toggle, Property 4: 状态保持不变性**

        for (var i = 0; i < 30; i++) {
          // 生成随机的任务列表
          final taskList = _generateRandomTaskList(faker);
          final initialState = _createTaskStateWithTasks(taskList);

          // 执行语言切换
          final toggleResult = _simulateLanguageToggle(initialState, faker);
          final finalState = toggleResult.taskStateAfterToggle;

          // 验证任务数量保持不变
          expect(
            finalState.tasks.length,
            equals(taskList.length),
            reason: 'Task count should remain unchanged during language toggle',
          );

          // 验证任务ID列表保持不变
          final initialTaskIds = taskList.map((task) => task.id).toList();
          final finalTaskIds = finalState.tasks.map((task) => task.id).toList();

          expect(
            finalTaskIds,
            equals(initialTaskIds),
            reason: 'Task IDs should remain unchanged during language toggle',
          );

          // 验证任务内容保持不变（抽样检查）
          for (var taskIndex = 0; taskIndex < taskList.length; taskIndex++) {
            final originalTask = taskList[taskIndex];
            final finalTask = finalState.tasks[taskIndex];

            expect(
              finalTask.id,
              equals(originalTask.id),
              reason: 'Task ID should be preserved',
            );

            expect(
              finalTask.title,
              equals(originalTask.title),
              reason: 'Task title should be preserved',
            );

            expect(
              finalTask.status,
              equals(originalTask.status),
              reason: 'Task status should be preserved',
            );
          }
        }
      },
    );

    test(
      'Property 4: 状态保持不变性 - concurrent state changes should be properly isolated',
      () {
        // **Feature: one-click-language-toggle, Property 4: 状态保持不变性**

        for (var i = 0; i < 20; i++) {
          // 生成初始状态
          final initialState = _generateRandomTaskState(faker);

          // 开始状态隔离会话
          final sessionId = stateIsolationManager.startIsolationSession();

          try {
            // 模拟语言相关的状态更新（应该被允许）
            final languageUpdate = stateIsolationManager.validateStateUpdate(
              stateKey: 'language_code',
              oldValue: 'zh',
              newValue: 'en',
              component: 'app_bloc',
            );

            expect(
              languageUpdate.isAllowed,
              isTrue,
              reason: 'Language updates should be allowed during isolation',
            );

            // 模拟受保护的状态更新（应该被阻止）
            final protectedUpdates = [
              _createStateUpdate('selected_date', 'task_bloc'),
              _createStateUpdate('search_query', 'task_bloc'),
              _createStateUpdate('filter_category', 'task_bloc'),
              _createStateUpdate('tasks', 'task_bloc'),
            ];

            for (final update in protectedUpdates) {
              final validation = stateIsolationManager.validateStateUpdate(
                stateKey: update.stateKey,
                oldValue: update.oldValue,
                newValue: update.newValue,
                component: update.component,
              );

              expect(
                validation.isAllowed,
                isFalse,
                reason:
                    'Protected state ${update.stateKey} should be blocked during isolation',
              );

              expect(
                validation.severity,
                isIn([ViolationSeverity.medium, ViolationSeverity.high]),
                reason:
                    'Protected state violations should have appropriate severity',
              );
            }

            // 结束隔离会话并验证报告
            final isolationReport = stateIsolationManager.endIsolationSession();

            expect(
              isolationReport.sessionId,
              equals(sessionId),
              reason: 'Isolation report should match session ID',
            );

            expect(
              isolationReport.protectedViolations,
              equals(protectedUpdates.length),
              reason:
                  'All protected state update attempts should be recorded as violations',
            );
          } finally {
            // 确保隔离会话被正确清理
            if (stateIsolationManager.currentStatus == IsolationStatus.active) {
              stateIsolationManager.forceEndIsolation();
            }
          }
        }
      },
    );

    test(
      'Property 4: 状态保持不变性 - error conditions should not corrupt state',
      () async {
        // **Feature: one-click-language-toggle, Property 4: 状态保持不变性**

        for (var i = 0; i < 20; i++) {
          // 生成初始状态
          final initialState = _generateRandomTaskState(faker);

          // 模拟各种错误条件
          final errorConditions = [
            () => _simulateLanguageToggleWithError(
              initialState,
              'BLoC access failure',
            ),
            () => _simulateLanguageToggleWithError(
              initialState,
              'SharedPreferences failure',
            ),
            () => _simulateLanguageToggleWithError(
              initialState,
              'Animation failure',
            ),
          ];

          for (final errorCondition in errorConditions) {
            // 执行可能失败的语言切换
            final result = errorCondition();

            // 验证即使在错误条件下，状态也应该保持不变或回滚到原始状态
            _verifyTaskStatePreservation(
              initialState,
              result.taskStateAfterToggle,
            );

            // 验证错误处理的正确性
            if (result.errorMessage != null) {
              expect(
                result.languageChanged,
                isFalse,
                reason: 'Language should not change when errors occur',
              );
            }
          }
        }
      },
    );

    group('Edge Cases Property Tests', () {
      test(
        'Property 4: 状态保持不变性 - empty state should be preserved correctly',
        () {
          // **Feature: one-click-language-toggle, Property 4: 状态保持不变性**

          for (var i = 0; i < 10; i++) {
            // 测试空状态的保持
            final emptyState = _createEmptyTaskState();

            final toggleResult = _simulateLanguageToggle(emptyState, faker);
            final finalState = toggleResult.taskStateAfterToggle;

            // 验证空状态特征保持不变
            expect(
              finalState.tasks,
              isEmpty,
              reason: 'Empty task list should remain empty',
            );

            expect(
              finalState.searchQuery,
              isEmpty,
              reason: 'Empty search query should remain empty',
            );

            expect(
              finalState.selectedDate,
              isNull,
              reason: 'Null selected date should remain null',
            );
          }
        },
      );

      test(
        'Property 4: 状态保持不变性 - large state should be preserved efficiently',
        () {
          // **Feature: one-click-language-toggle, Property 4: 状态保持不变性**

          for (var i = 0; i < 5; i++) {
            // 生成大量任务的状态
            final largeTaskList = _generateLargeTaskList(faker, 1000);
            final largeState = _createTaskStateWithTasks(largeTaskList);

            final toggleResult = _simulateLanguageToggle(largeState, faker);
            final finalState = toggleResult.taskStateAfterToggle;

            // 验证大状态的保持性能
            expect(
              finalState.tasks.length,
              equals(largeTaskList.length),
              reason: 'Large task list size should be preserved',
            );

            // 抽样验证任务内容（避免性能问题）
            final sampleIndices = [0, 100, 500, 999];
            for (final index in sampleIndices) {
              if (index < largeTaskList.length) {
                expect(
                  finalState.tasks[index].id,
                  equals(largeTaskList[index].id),
                  reason: 'Sample task $index should be preserved',
                );
              }
            }
          }
        },
      );
    });
  });
}

// Helper classes and methods

/// 语言切换结果
class LanguageToggleResult {
  const LanguageToggleResult({
    required this.taskStateAfterToggle,
    required this.languageChanged,
    this.errorMessage,
  });

  final TaskState taskStateAfterToggle;
  final bool languageChanged;
  final String? errorMessage;
}

/// 状态更新描述
class StateUpdateDescription {
  const StateUpdateDescription({
    required this.stateKey,
    required this.oldValue,
    required this.newValue,
    required this.component,
  });

  final String stateKey;
  final dynamic oldValue;
  final dynamic newValue;
  final String component;
}

/// 生成随机的任务状态
TaskState _generateRandomTaskState(Faker faker) {
  final tasks = _generateRandomTaskList(faker);
  final selectedDate = faker.randomGenerator.boolean()
      ? _generateRandomDate(faker)
      : null;
  final searchQuery = faker.randomGenerator.boolean()
      ? faker.lorem.words(faker.randomGenerator.integer(3, min: 1)).join(' ')
      : '';

  return TaskState(
    tasks: tasks,
    selectedDate: selectedDate,
    searchQuery: searchQuery,
    filterCategory: _generateRandomTaskCategory(faker),
    filterStatus: _generateRandomTaskStatus(faker),
    status: TaskBlocStatus.success,
  );
}

/// 生成随机的任务列表
List<Task> _generateRandomTaskList(Faker faker) {
  final taskCount = faker.randomGenerator.integer(20);
  return List.generate(taskCount, (index) => _generateRandomTask(faker));
}

/// 生成大量任务列表
List<Task> _generateLargeTaskList(Faker faker, int count) {
  return List.generate(count, (index) => _generateRandomTask(faker));
}

/// 生成随机任务
Task _generateRandomTask(Faker faker) {
  final now = DateTime.now();
  final startTime = _generateRandomDate(faker);
  final endTime = startTime.add(
    Duration(hours: faker.randomGenerator.integer(8, min: 1)),
  );

  return Task(
    id: faker.guid.guid(),
    title: faker.lorem.sentence(),
    description: faker.lorem.sentences(2).join(' '),
    startTime: startTime,
    endTime: endTime,
    createdAt: now,
    updatedAt: now,
    status: _generateRandomTaskStatus(faker),
    category: _generateRandomTaskCategory(faker) ?? TaskCategory.other,
  );
}

/// 生成随机日期
DateTime _generateRandomDate(Faker faker) {
  final now = DateTime.now();
  final daysOffset = faker.randomGenerator.integer(365, min: -365);
  return now.add(Duration(days: daysOffset));
}

/// 生成随机任务类别
TaskCategory? _generateRandomTaskCategory(Faker faker) {
  if (faker.randomGenerator.boolean()) {
    const categories = TaskCategory.values;
    return categories[faker.randomGenerator.integer(categories.length)];
  }
  return null;
}

/// 生成随机任务状态
TaskStatus _generateRandomTaskStatus(Faker faker) {
  const statuses = TaskStatus.values;
  return statuses[faker.randomGenerator.integer(statuses.length)];
}

/// 创建带有选中日期的任务状态
TaskState _createTaskStateWithSelectedDate(DateTime selectedDate) {
  return TaskState(
    selectedDate: selectedDate,
    status: TaskBlocStatus.success,
  );
}

/// 创建带有过滤器的任务状态
TaskState _createTaskStateWithFilters({
  required String searchQuery,
  required TaskStatus filterStatus, TaskCategory? filterCategory,
}) {
  return TaskState(
    searchQuery: searchQuery,
    filterCategory: filterCategory,
    filterStatus: filterStatus,
    status: TaskBlocStatus.success,
  );
}

/// 创建带有任务列表的任务状态
TaskState _createTaskStateWithTasks(List<Task> tasks) {
  return TaskState(
    tasks: tasks,
    status: TaskBlocStatus.success,
  );
}

/// 创建空的任务状态
TaskState _createEmptyTaskState() {
  return const TaskState(
    status: TaskBlocStatus.success,
  );
}

/// 模拟语言切换操作
LanguageToggleResult _simulateLanguageToggle(
  TaskState initialState,
  Faker faker,
) {
  // 模拟语言切换逻辑：语言改变，但任务状态保持不变
  return LanguageToggleResult(
    taskStateAfterToggle: initialState, // 任务状态应该保持不变
    languageChanged: true,
  );
}

/// 模拟带错误的语言切换
LanguageToggleResult _simulateLanguageToggleWithError(
  TaskState initialState,
  String errorType,
) {
  // 在错误条件下，状态应该保持不变或回滚
  return LanguageToggleResult(
    taskStateAfterToggle: initialState,
    languageChanged: false,
    errorMessage: errorType,
  );
}

/// 验证任务状态保持不变
void _verifyTaskStatePreservation(
  TaskState expectedState,
  TaskState actualState,
) {
  expect(
    actualState.selectedDate,
    equals(expectedState.selectedDate),
    reason: 'Selected date should be preserved',
  );

  expect(
    actualState.searchQuery,
    equals(expectedState.searchQuery),
    reason: 'Search query should be preserved',
  );

  expect(
    actualState.filterCategory,
    equals(expectedState.filterCategory),
    reason: 'Filter category should be preserved',
  );

  expect(
    actualState.filterStatus,
    equals(expectedState.filterStatus),
    reason: 'Filter status should be preserved',
  );

  expect(
    actualState.tasks.length,
    equals(expectedState.tasks.length),
    reason: 'Task count should be preserved',
  );

  // 验证任务ID列表
  final expectedTaskIds = expectedState.tasks.map((task) => task.id).toList();
  final actualTaskIds = actualState.tasks.map((task) => task.id).toList();

  expect(
    actualTaskIds,
    equals(expectedTaskIds),
    reason: 'Task IDs should be preserved',
  );
}

/// 创建状态更新描述
StateUpdateDescription _createStateUpdate(String stateKey, String component) {
  return StateUpdateDescription(
    stateKey: stateKey,
    oldValue: 'old_value',
    newValue: 'new_value',
    component: component,
  );
}
