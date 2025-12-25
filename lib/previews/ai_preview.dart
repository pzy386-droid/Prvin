import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:prvin/features/ai/data/repositories/ai_analytics_repository_impl.dart';
import 'package:prvin/features/ai/domain/entities/analytics_data.dart';

/// AI功能预览
@Preview(name: 'AI标签建议', group: 'AI功能', size: Size(400, 300))
Widget aiTagSuggestionsPreview() {
  return MaterialApp(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4FC3F7)),
    ),
    home: const Scaffold(
      backgroundColor: Color(0xFFE3F2FD),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: AITagSuggestionsDemo(),
      ),
    ),
  );
}

@Preview(name: 'AI分类建议', group: 'AI功能', size: Size(400, 300))
Widget aiCategorySuggestionPreview() {
  return MaterialApp(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4FC3F7)),
    ),
    home: const Scaffold(
      backgroundColor: Color(0xFFE3F2FD),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: AICategorySuggestionDemo(),
      ),
    ),
  );
}

@Preview(name: 'AI专注建议', group: 'AI功能', size: Size(400, 400))
Widget aiFocusRecommendationsPreview() {
  return MaterialApp(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4FC3F7)),
    ),
    home: const Scaffold(
      backgroundColor: Color(0xFFE3F2FD),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: AIFocusRecommendationsDemo(),
      ),
    ),
  );
}

/// AI标签建议演示组件
class AITagSuggestionsDemo extends StatefulWidget {
  const AITagSuggestionsDemo({super.key});

  @override
  State<AITagSuggestionsDemo> createState() => _AITagSuggestionsDemoState();
}

class _AITagSuggestionsDemoState extends State<AITagSuggestionsDemo> {
  const _repository = AIAnalyticsRepositoryImpl();
  final _controller = TextEditingController(text: '团队会议讨论项目进度');
  List<String> _suggestions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getSuggestions();
  }

  Future<void> _getSuggestions() async {
    if (_controller.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final suggestions = await _repository.getTagSuggestions(_controller.text);
      setState(() {
        _suggestions = suggestions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AI标签建议演示',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0277BD),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: '输入任务标题',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            suffixIcon: IconButton(
              icon: const Icon(CupertinoIcons.refresh),
              onPressed: _getSuggestions,
            ),
          ),
          onChanged: (_) => _getSuggestions(),
        ),
        const SizedBox(height: 16),
        const Text(
          '建议标签:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0288D1),
          ),
        ),
        const SizedBox(height: 8),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestions.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF4FC3F7).withValues(alpha: 0.2),
                      const Color(0xFF4FC3F7).withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF4FC3F7).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0277BD),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// AI分类建议演示组件
class AICategorySuggestionDemo extends StatefulWidget {
  const AICategorySuggestionDemo({super.key});

  @override
  State<AICategorySuggestionDemo> createState() =>
      _AICategorySuggestionDemoState();
}

class _AICategorySuggestionDemoState extends State<AICategorySuggestionDemo> {
  const _repository = AIAnalyticsRepositoryImpl();
  final _controller = TextEditingController(text: '健身房锻炼');
  TaskCategory _suggestion = TaskCategory.other;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getSuggestion();
  }

  Future<void> _getSuggestion() async {
    if (_controller.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final suggestion = await _repository.getCategorySuggestion(
        _controller.text,
      );
      setState(() {
        _suggestion = suggestion;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AI分类建议演示',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0277BD),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: '输入任务标题',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            suffixIcon: IconButton(
              icon: const Icon(CupertinoIcons.refresh),
              onPressed: _getSuggestion,
            ),
          ),
          onChanged: (_) => _getSuggestion(),
        ),
        const SizedBox(height: 16),
        const Text(
          '建议分类:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0288D1),
          ),
        ),
        const SizedBox(height: 8),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getCategoryColor(_suggestion).withValues(alpha: 0.2),
                  _getCategoryColor(_suggestion).withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getCategoryColor(_suggestion).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getCategoryIcon(_suggestion),
                  color: _getCategoryColor(_suggestion),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  _getCategoryLabel(_suggestion),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _getCategoryColor(_suggestion),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Color _getCategoryColor(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return const Color(0xFF4FC3F7);
      case TaskCategory.personal:
        return const Color(0xFF81C784);
      case TaskCategory.study:
        return const Color(0xFFAB47BC);
      case TaskCategory.health:
        return const Color(0xFFE57373);
      case TaskCategory.social:
        return const Color(0xFFFFB74D);
      case TaskCategory.other:
        return const Color(0xFF90A4AE);
    }
  }

  IconData _getCategoryIcon(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return CupertinoIcons.briefcase;
      case TaskCategory.personal:
        return CupertinoIcons.person;
      case TaskCategory.study:
        return CupertinoIcons.book;
      case TaskCategory.health:
        return CupertinoIcons.heart;
      case TaskCategory.social:
        return CupertinoIcons.group;
      case TaskCategory.other:
        return CupertinoIcons.tag;
    }
  }

  String _getCategoryLabel(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return '工作';
      case TaskCategory.personal:
        return '个人';
      case TaskCategory.study:
        return '学习';
      case TaskCategory.health:
        return '健康';
      case TaskCategory.social:
        return '社交';
      case TaskCategory.other:
        return '其他';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// AI专注建议演示组件
class AIFocusRecommendationsDemo extends StatefulWidget {
  const AIFocusRecommendationsDemo({super.key});

  @override
  State<AIFocusRecommendationsDemo> createState() =>
      _AIFocusRecommendationsDemoState();
}

class _AIFocusRecommendationsDemoState
    extends State<AIFocusRecommendationsDemo> {
  const _repository = AIAnalyticsRepositoryImpl();
  List<FocusRecommendation> _recommendations = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getRecommendations();
  }

  Future<void> _getRecommendations() async {
    setState(() => _isLoading = true);

    try {
      final recommendations = await _repository.getFocusRecommendations(
        'demo_user',
      );
      setState(() {
        _recommendations = recommendations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'AI专注建议',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0277BD),
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(CupertinoIcons.refresh),
              onPressed: _getRecommendations,
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else
          Expanded(
            child: ListView.builder(
              itemCount: _recommendations.length,
              itemBuilder: (context, index) {
                final recommendation = _recommendations[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.4),
                        Colors.white.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _getRecommendationIcon(recommendation.type),
                            color: const Color(0xFF4FC3F7),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              recommendation.message,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF0277BD),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF4FC3F7,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${recommendation.recommendedMinutes}分钟',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF0277BD),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF81C784,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '置信度: ${(recommendation.confidence * 100).toInt()}%',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF388E3C),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  IconData _getRecommendationIcon(String type) {
    switch (type) {
      case 'optimal_time':
        return CupertinoIcons.clock;
      case 'break_reminder':
        return CupertinoIcons.pause_circle;
      case 'task_batching':
        return CupertinoIcons.square_stack;
      default:
        return CupertinoIcons.lightbulb;
    }
  }
}
