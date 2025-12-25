import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prvin/features/task_management/data/repositories/task_repository_impl.dart';
import 'package:prvin/features/task_management/domain/usecases/task_usecases.dart';
import 'package:prvin/features/task_management/presentation/bloc/task_bloc.dart';
import 'package:prvin/integrated_calendar_with_pomodoro.dart';

/// 简化的演示入口，避免复杂的依赖注入和Firebase问题
void main() {
  runApp(const DemoApp());
}

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prvin AI日历 - 演示版',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: '.SF Pro Display',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4FC3F7), // 天蓝色主题
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: BlocProvider(
        create: (context) {
          final repository = TaskRepositoryImpl();
          final useCases = TaskUseCases(repository);
          return TaskBloc(useCases);
        },
        child: const IntegratedCalendarWithPomodoroPage(),
      ),
    );
  }
}
