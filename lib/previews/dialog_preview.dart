import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:prvin/previews/custom_previews.dart';

/// 任务创建对话框预览
@PrvinPreview(name: '任务创建对话框', group: '对话框组件', size: Size(400, 600))
Widget taskCreationDialogPreview() {
  return MaterialApp(
    theme: PrvinPreview.themeBuilder().materialLight,
    home: Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: Center(child: _buildTaskCreationDialog()),
    ),
  );
}

@MultiBrightnessPreview(name: '任务创建对话框', group: '对话框组件', size: Size(400, 600))
Widget taskCreationDialogBrightnessPreview() {
  return _buildTaskCreationDialog();
}

@Preview(name: '时间选择按钮', group: '对话框组件', size: Size(200, 80))
Widget timeButtonPreview() {
  return MaterialApp(
    theme: PrvinPreview.themeBuilder().materialLight,
    home: Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _buildTimeButton(
            label: '开始',
            time: DateTime.now(),
            onTap: () {},
          ),
        ),
      ),
    ),
  );
}

@Preview(name: '优先级选择器', group: '对话框组件', size: Size(300, 100))
Widget prioritySelectorPreview() {
  return MaterialApp(
    theme: PrvinPreview.themeBuilder().materialLight,
    home: Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _buildPrioritySelector(),
        ),
      ),
    ),
  );
}

Widget _buildTaskCreationDialog() {
  return Container(
    width: 320,
    constraints: const BoxConstraints(maxHeight: 500),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.95),
          Colors.white.withOpacity(0.85),
        ],
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.3)),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF4FC3F7).withOpacity(0.2),
          blurRadius: 30,
          offset: const Offset(0, 15),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildTitleField(),
              const SizedBox(height: 12),
              _buildTimeSelector(),
              const SizedBox(height: 12),
              _buildPrioritySelector(),
              const SizedBox(height: 12),
              _buildCategorySelector(),
              const SizedBox(height: 16),
              _buildButtons(),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildHeader() {
  return Row(
    children: [
      Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(CupertinoIcons.add, color: Colors.white, size: 16),
      ),
      const SizedBox(width: 10),
      const Text(
        '创建任务',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0277BD),
        ),
      ),
      const Spacer(),
      Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: const Color(0xFF0288D1).withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(
          CupertinoIcons.xmark,
          size: 14,
          color: Color(0xFF0288D1),
        ),
      ),
    ],
  );
}

Widget _buildTitleField() {
  return TextField(
    style: const TextStyle(fontSize: 14),
    decoration: InputDecoration(
      hintText: '输入任务内容...',
      hintStyle: TextStyle(
        color: const Color(0xFF0288D1).withOpacity(0.5),
        fontSize: 14,
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: const Color(0xFF4FC3F7).withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: const Color(0xFF4FC3F7).withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF4FC3F7), width: 2),
      ),
    ),
  );
}

Widget _buildTimeSelector() {
  return Row(
    children: [
      Expanded(
        child: _buildTimeButton(
          label: '开始',
          time: DateTime.now(),
          onTap: () {},
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: _buildTimeButton(
          label: '结束',
          time: DateTime.now().add(const Duration(hours: 1)),
          onTap: () {},
        ),
      ),
    ],
  );
}

Widget _buildTimeButton({
  required String label,
  required DateTime time,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        border: Border.all(color: const Color(0xFF4FC3F7).withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: const Color(0xFF0288D1).withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${time.hour.toString().padLeft(2, '0')}:'
            '${time.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0277BD),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildPrioritySelector() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '优先级',
        style: TextStyle(
          fontSize: 10,
          color: const Color(0xFF0288D1).withOpacity(0.7),
        ),
      ),
      const SizedBox(height: 6),
      Row(
        children: ['低', '中', '高', '紧急'].asMap().entries.map((entry) {
          final isSelected = entry.key == 1; // 默认选中"中"
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF4FC3F7).withOpacity(0.2)
                      : Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF4FC3F7)
                        : const Color(0xFF4FC3F7).withOpacity(0.2),
                  ),
                ),
                child: Text(
                  entry.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: const Color(0xFF0277BD),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ],
  );
}

Widget _buildCategorySelector() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '分类',
        style: TextStyle(
          fontSize: 10,
          color: const Color(0xFF0288D1).withOpacity(0.7),
        ),
      ),
      const SizedBox(height: 6),
      Wrap(
        spacing: 6,
        runSpacing: 6,
        children: ['工作', '个人', '学习', '健康', '社交', '其他'].asMap().entries.map((
          entry,
        ) {
          final isSelected = entry.key == 5; // 默认选中"其他"
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF4FC3F7).withOpacity(0.2)
                  : Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF4FC3F7)
                    : const Color(0xFF4FC3F7).withOpacity(0.2),
              ),
            ),
            child: Text(
              entry.value,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: const Color(0xFF0277BD),
              ),
            ),
          );
        }).toList(),
      ),
    ],
  );
}

Widget _buildButtons() {
  return Row(
    children: [
      Expanded(
        child: TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            '取消',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0288D1),
            ),
          ),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 8),
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
    ],
  );
}
