import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:prvin/features/task_management/data/repositories/task_repository_impl.dart';
import 'package:prvin/features/task_management/domain/usecases/task_usecases.dart';
import 'package:prvin/features/task_management/presentation/bloc/task_bloc.dart';
import 'package:prvin/features/task_management/presentation/widgets/overlay_task_creator.dart';

void main() {
  runApp(const TimeFixTestApp());
}

class TimeFixTestApp extends StatelessWidget {
  const TimeFixTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '时间选择器修复验证',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: '.SF Pro Display',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4FC3F7)),
      ),
      debugShowCheckedModeBanner: false,
      home: BlocProvider(
        create: (context) {
          final repository = TaskRepositoryImpl();
          final useCases = TaskUseCases(repository);
          return TaskBloc(useCases);
        },
        child: const TimeFixTestPage(),
      ),
    );
  }
}

class TimeFixTestPage extends StatefulWidget {
  const TimeFixTestPage({super.key});

  @override
  State<TimeFixTestPage> createState() => _TimeFixTestPageState();
}

class _TimeFixTestPageState extends State<TimeFixTestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB), Color(0xFFE1F5FE)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4FC3F7).withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    CupertinoIcons.time_solid,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  '时间选择器修复验证',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0277BD),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '测试新的Overlay系统和RootTimePicker',
                  style: TextStyle(fontSize: 16, color: Color(0xFF0288D1)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4FC3F7).withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _showTaskCreator,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.add_circled, size: 24),
                        SizedBox(width: 12),
                        Text(
                          '测试任务创建',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        '修复内容',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0277BD),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        '✅ 使用Overlay替代Dialog\n'
                        '✅ RootTimePicker确保时间选择器在最顶层\n'
                        '✅ 解决层级冲突问题\n'
                        '✅ 保持精美的UI设计和动画',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF0288D1),
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTaskCreator() {
    final taskBloc = context.read<TaskBloc>();

    OverlayTaskCreator.show(
      taskBloc: taskBloc,
      context,
      initialDate: DateTime.now(),
    );
  }
}
