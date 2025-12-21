import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/features/task_management/widgets/task_form.dart';
import 'package:prvin/features/task_management/widgets/task_list.dart';

void main() {
  group('Task Management Unit Tests', () {
    group('TaskFormData Tests', () {
      test('should create TaskFormData with required fields', () {
        final formData = TaskFormData(
          title: '测试任务',
          date: DateTime(2024, 12, 15),
        );

        expect(formData.title, equals('测试任务'));
        expect(formData.date, equals(DateTime(2024, 12, 15)));
        expect(formData.id, isNull);
        expect(formData.description, isNull);
        expect(formData.tags, isEmpty);
      });

      test('should create TaskFormData with all fields', () {
        final formData = TaskFormData(
          id: 'test-id',
          title: '测试任务',
          description: '测试描述',
          date: DateTime(2024, 12, 15),
          startTime: const TimeOfDay(hour: 9, minute: 0),
          endTime: const TimeOfDay(hour: 10, minute: 0),
          category: 'work',
          priority: 'high',
          tags: ['标签1', '标签2'],
        );

        expect(formData.id, equals('test-id'));
        expect(formData.title, equals('测试任务'));
        expect(formData.description, equals('测试描述'));
        expect(formData.date, equals(DateTime(2024, 12, 15)));
        expect(formData.startTime, equals(const TimeOfDay(hour: 9, minute: 0)));
        expect(formData.endTime, equals(const TimeOfDay(hour: 10, minute: 0)));
        expect(formData.category, equals('work'));
        expect(formData.priority, equals('high'));
        expect(formData.tags, equals(['标签1', '标签2']));
      });

      test('should copy TaskFormData with modifications', () {
        final original = TaskFormData(
          title: '原始任务',
          date: DateTime(2024, 12, 15),
          category: 'work',
        );

        final copied = original.copyWith(title: '修改后的任务', priority: 'high');

        expect(copied.title, equals('修改后的任务'));
        expect(copied.date, equals(DateTime(2024, 12, 15))); // 保持不变
        expect(copied.category, equals('work')); // 保持不变
        expect(copied.priority, equals('high')); // 新值
      });
    });

    group('TaskItem Tests', () {
      test('should create TaskItem with required fields', () {
        final task = TaskItem(
          id: '1',
          title: '测试任务',
          date: DateTime(2024, 12, 15),
        );

        expect(task.id, equals('1'));
        expect(task.title, equals('测试任务'));
        expect(task.date, equals(DateTime(2024, 12, 15)));
        expect(task.isCompleted, isFalse);
        expect(task.tags, isEmpty);
      });

      test('should create TaskItem with all fields', () {
        final task = TaskItem(
          id: '1',
          title: '测试任务',
          description: '测试描述',
          date: DateTime(2024, 12, 15),
          startTime: const TimeOfDay(hour: 9, minute: 0),
          endTime: const TimeOfDay(hour: 10, minute: 0),
          category: 'work',
          priority: 'high',
          tags: ['标签1', '标签2'],
          isCompleted: true,
          createdAt: DateTime(2024, 12, 14),
          updatedAt: DateTime(2024, 12, 15),
        );

        expect(task.id, equals('1'));
        expect(task.title, equals('测试任务'));
        expect(task.description, equals('测试描述'));
        expect(task.date, equals(DateTime(2024, 12, 15)));
        expect(task.startTime, equals(const TimeOfDay(hour: 9, minute: 0)));
        expect(task.endTime, equals(const TimeOfDay(hour: 10, minute: 0)));
        expect(task.category, equals('work'));
        expect(task.priority, equals('high'));
        expect(task.tags, equals(['标签1', '标签2']));
        expect(task.isCompleted, isTrue);
        expect(task.createdAt, equals(DateTime(2024, 12, 14)));
        expect(task.updatedAt, equals(DateTime(2024, 12, 15)));
      });

      test('should copy TaskItem with modifications', () {
        final original = TaskItem(
          id: '1',
          title: '原始任务',
          date: DateTime(2024, 12, 15),
        );

        final copied = original.copyWith(title: '修改后的任务', isCompleted: true);

        expect(copied.id, equals('1')); // 保持不变
        expect(copied.title, equals('修改后的任务')); // 新值
        expect(copied.date, equals(DateTime(2024, 12, 15))); // 保持不变
        expect(copied.isCompleted, isTrue); // 新值
      });

      test('should create TaskItem from TaskFormData', () {
        final formData = TaskFormData(
          id: 'form-id',
          title: '表单任务',
          description: '表单描述',
          date: DateTime(2024, 12, 15),
          startTime: const TimeOfDay(hour: 9, minute: 0),
          endTime: const TimeOfDay(hour: 10, minute: 0),
          category: 'work',
          priority: 'high',
          tags: ['标签1', '标签2'],
        );

        final task = TaskItem.fromFormData(formData);

        expect(task.id, equals('form-id'));
        expect(task.title, equals('表单任务'));
        expect(task.description, equals('表单描述'));
        expect(task.date, equals(DateTime(2024, 12, 15)));
        expect(task.startTime, equals(const TimeOfDay(hour: 9, minute: 0)));
        expect(task.endTime, equals(const TimeOfDay(hour: 10, minute: 0)));
        expect(task.category, equals('work'));
        expect(task.priority, equals('high'));
        expect(task.tags, equals(['标签1', '标签2']));
        expect(task.isCompleted, isFalse); // 默认值
        expect(task.createdAt, isNotNull);
        expect(task.updatedAt, isNotNull);
      });

      test('should convert TaskItem to TaskFormData', () {
        final task = TaskItem(
          id: '1',
          title: '测试任务',
          description: '测试描述',
          date: DateTime(2024, 12, 15),
          startTime: const TimeOfDay(hour: 9, minute: 0),
          endTime: const TimeOfDay(hour: 10, minute: 0),
          category: 'work',
          priority: 'high',
          tags: ['标签1', '标签2'],
          isCompleted: true,
        );

        final formData = task.toFormData();

        expect(formData.id, equals('1'));
        expect(formData.title, equals('测试任务'));
        expect(formData.description, equals('测试描述'));
        expect(formData.date, equals(DateTime(2024, 12, 15)));
        expect(formData.startTime, equals(const TimeOfDay(hour: 9, minute: 0)));
        expect(formData.endTime, equals(const TimeOfDay(hour: 10, minute: 0)));
        expect(formData.category, equals('work'));
        expect(formData.priority, equals('high'));
        expect(formData.tags, equals(['标签1', '标签2']));
      });
    });

    group('Task Management Logic Tests', () {
      test('should filter tasks by date range', () {
        final now = DateTime.now();
        final tasks = [
          TaskItem(id: '1', title: '今天的任务', date: now),
          TaskItem(
            id: '2',
            title: '昨天的任务',
            date: now.subtract(const Duration(days: 1)),
          ),
          TaskItem(
            id: '3',
            title: '明天的任务',
            date: now.add(const Duration(days: 1)),
          ),
        ];

        // 测试今天的任务筛选
        final todayTasks = tasks.where((task) {
          return task.date.year == now.year &&
              task.date.month == now.month &&
              task.date.day == now.day;
        }).toList();

        expect(todayTasks.length, equals(1));
        expect(todayTasks.first.title, equals('今天的任务'));
      });

      test('should sort tasks by priority', () {
        final tasks = [
          TaskItem(
            id: '1',
            title: '低优先级任务',
            date: DateTime.now(),
            priority: 'low',
          ),
          TaskItem(
            id: '2',
            title: '高优先级任务',
            date: DateTime.now(),
            priority: 'high',
          ),
          TaskItem(
            id: '3',
            title: '中优先级任务',
            date: DateTime.now(),
            priority: 'medium',
          ),
        ];

        // 按优先级排序
        tasks.sort((a, b) {
          final priorityOrder = {'high': 0, 'medium': 1, 'low': 2};
          final aPriority = priorityOrder[a.priority?.toLowerCase()] ?? 3;
          final bPriority = priorityOrder[b.priority?.toLowerCase()] ?? 3;
          return aPriority.compareTo(bPriority);
        });

        expect(tasks[0].priority, equals('high'));
        expect(tasks[1].priority, equals('medium'));
        expect(tasks[2].priority, equals('low'));
      });

      test('should sort tasks by category', () {
        final tasks = [
          TaskItem(
            id: '1',
            title: '工作任务',
            date: DateTime.now(),
            category: 'work',
          ),
          TaskItem(
            id: '2',
            title: '健康任务',
            date: DateTime.now(),
            category: 'health',
          ),
          TaskItem(
            id: '3',
            title: '个人任务',
            date: DateTime.now(),
            category: 'personal',
          ),
        ];

        // 按分类排序
        tasks.sort((a, b) {
          final aCategory = a.category ?? '';
          final bCategory = b.category ?? '';
          return aCategory.compareTo(bCategory);
        });

        expect(tasks[0].category, equals('health'));
        expect(tasks[1].category, equals('personal'));
        expect(tasks[2].category, equals('work'));
      });

      test('should filter completed tasks', () {
        final tasks = [
          TaskItem(
            id: '1',
            title: '已完成任务',
            date: DateTime.now(),
            isCompleted: true,
          ),
          TaskItem(
            id: '2',
            title: '未完成任务',
            date: DateTime.now(),
          ),
        ];

        // 筛选未完成任务
        final incompleteTasks = tasks
            .where((task) => !task.isCompleted)
            .toList();
        expect(incompleteTasks.length, equals(1));
        expect(incompleteTasks.first.title, equals('未完成任务'));

        // 筛选已完成任务
        final completedTasks = tasks.where((task) => task.isCompleted).toList();
        expect(completedTasks.length, equals(1));
        expect(completedTasks.first.title, equals('已完成任务'));
      });

      test('should validate task form data', () {
        // 测试有效数据
        final validData = TaskFormData(
          title: '有效任务',
          date: DateTime(2024, 12, 15),
        );
        expect(validData.title.trim().isNotEmpty, isTrue);

        // 测试无效数据
        final invalidData = TaskFormData(
          title: '   ', // 只有空格
          date: DateTime(2024, 12, 15),
        );
        expect(invalidData.title.trim().isEmpty, isTrue);
      });

      test('should handle time conflict detection', () {
        const startTime = TimeOfDay(hour: 10, minute: 0);
        const endTime = TimeOfDay(hour: 9, minute: 0); // 结束时间早于开始时间

        // 检测时间冲突的逻辑
        bool isTimeAfter(TimeOfDay time1, TimeOfDay time2) {
          return time1.hour > time2.hour ||
              (time1.hour == time2.hour && time1.minute > time2.minute);
        }

        expect(isTimeAfter(startTime, endTime), isTrue); // 存在冲突
      });
    });
  });
}
