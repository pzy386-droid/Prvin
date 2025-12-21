import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:prvin/features/task_management/data/repositories/task_repository_impl.dart';
import 'package:prvin/features/task_management/domain/usecases/task_usecases.dart';
import 'package:prvin/features/task_management/presentation/bloc/task_bloc.dart';
import 'package:prvin/features/task_management/presentation/widgets/overlay_task_creator.dart';

void main() {
  runApp(const OverlayFixTestApp());
}

class OverlayFixTestApp extends StatelessWidget {
  const OverlayFixTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '时间选择器修复测试',
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
        child: const OverlayFixTestPage(),
      ),
    );
  }
}

class OverlayFixTestPage extends StatefulWidget {
  const OverlayFixTestPage({super.key});

  @override
  State<OverlayFixTestPage> createState() => _OverlayFixTestPageState();
}

class _OverlayFixTestPageState extends State<OverlayFixTestPage> {
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
                const Icon(
                  CupertinoIcons.checkmark_circle_fill,
                  size: 80,
                  color: Color(0xFF4FC3F7),
                ),
                const SizedBox(height: 24),
                const Text(
                  '时间选择器修复测试',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0277BD),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '点击下方按钮测试新的Overlay任务创建器',
                  style: TextStyle(fontSize: 16, color: Color(0xFF0288D1)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _showOverlayTaskCreator,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4FC3F7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '测试任务创建浮层',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '✅ 使用Overlay直接管理浮层\n'
                  '✅ RootTimePicker确保时间选择器在最顶层\n'
                  '✅ 解决层级冲突问题',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF0288D1),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showOverlayTaskCreator() {
    final taskBloc = context.read<TaskBloc>();

    OverlayTaskCreator.show(
      context,
      initialDate: DateTime.now(),
      taskBloc: taskBloc,
    );
  }
}
