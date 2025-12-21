import 'package:flutter/widget_previews.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// 简单的按钮预览
@Preview(name: '主要按钮', group: 'UI组件', size: Size(200, 100))
Widget primaryButtonPreview() {
  return MaterialApp(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4FC3F7)),
    ),
    home: Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: Center(
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4FC3F7),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: const Text(
            '保存',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    ),
  );
}

/// 优先级徽章预览
@Preview(name: '优先级徽章 - 高', group: 'UI组件', size: Size(150, 80))
Widget priorityBadgePreview() {
  return MaterialApp(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4FC3F7)),
    ),
    home: Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFFB74D).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFFFB74D).withOpacity(0.5)),
          ),
          child: const Text(
            '高',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFFB74D),
            ),
          ),
        ),
      ),
    ),
  );
}

/// 时间选择按钮预览
@Preview(name: '时间选择按钮', group: 'UI组件', size: Size(150, 100))
Widget timeButtonPreview() {
  return MaterialApp(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4FC3F7)),
    ),
    home: Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            border: Border.all(color: const Color(0xFF4FC3F7).withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '开始',
                style: TextStyle(
                  fontSize: 10,
                  color: const Color(0xFF0288D1).withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                '14:00',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0277BD),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// 浮动操作按钮预览
@Preview(name: '浮动操作按钮', group: 'UI组件', size: Size(120, 120))
Widget fabPreview() {
  return MaterialApp(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4FC3F7)),
    ),
    home: Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4FC3F7).withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () {},
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            child: const Icon(CupertinoIcons.add, size: 26),
          ),
        ),
      ),
    ),
  );
}
