import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_alert.dart';
import '../widgets/app_back_button.dart';

/// Опросник для определения начального уровня игрока.
/// Показывается новым пользователям сразу после регистрации/логина.
/// Один вопрос на экран + прогресс снизу.
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  bool _loading = true;
  bool _submitting = false;
  List<_QuizQuestion> _questions = [];
  final List<int?> _answers = [];
  int _index = 0;
  _QuizResult? _result;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final token = await StorageService().getToken();
      final response = await ApiService().get('/profile/quiz', token);
      final list = (response['questions'] as List?) ?? [];
      setState(() {
        _questions = list.map((q) => _QuizQuestion.fromJson(q as Map<String, dynamic>)).toList();
        _answers.clear();
        _answers.addAll(List<int?>.filled(_questions.length, null));
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        showAppAlert(context, '$e', title: 'Ошибка загрузки опросника', isError: true);
      }
    }
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      final token = await StorageService().getToken();
      final response = await ApiService().post(
        '/profile/quiz',
        {'answers': _answers},
        token,
      );
      if (response['success'] == true) {
        setState(() {
          _result = _QuizResult(
            level: (response['level'] as num).toDouble(),
            score: (response['score'] as num).toInt(),
            maxScore: (response['max_score'] as num).toInt(),
            category: response['category'] as String? ?? '',
          );
          _submitting = false;
        });
      } else {
        throw Exception(response['message'] ?? 'Ошибка');
      }
    } catch (e) {
      setState(() => _submitting = false);
      if (mounted) {
        showAppAlert(context, '$e', title: 'Ошибка', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
            : _result != null
                ? _buildResult()
                : _buildQuestion(),
      ),
    );
  }

  Widget _buildResult() {
    final r = _result!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: [
          const Spacer(flex: 2),
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppTheme.accentSoft,
              borderRadius: BorderRadius.circular(22),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.check_circle, size: 56, color: AppTheme.accent),
          ),
          const SizedBox(height: 20),
          const Text(
            'Ваш уровень определён',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'По результатам опросника',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Text(
                  r.level.toStringAsFixed(2),
                  style: const TextStyle(
                    color: AppTheme.accent,
                    fontSize: 60,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -2,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  r.category,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${r.score} из ${r.maxScore} баллов',
                  style: const TextStyle(color: AppTheme.textDim, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Уровень ещё не подтверждён клубом. После нескольких игр в клубе администратор сможет его верифицировать.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.4),
            ),
          ),
          const Spacer(flex: 3),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                // Перезагружаем профиль: quizCompleted=true → Consumer
                // в app.dart переключит на MainScreen автоматически.
                await context.read<AuthProvider>().refreshUser();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'Перейти в приложение',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildQuestion() {
    final q = _questions[_index];
    final selected = _answers[_index];
    final isLast = _index == _questions.length - 1;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Row(
            children: [
              if (_index > 0)
                AppBackButton(onTap: () => setState(() => _index--))
              else
                const SizedBox(width: 34),
              const Spacer(),
              Text(
                '${_index + 1} / ${_questions.length}',
                style: const TextStyle(color: AppTheme.textDim, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              const SizedBox(width: 34),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  q.title,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                if (q.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    q.subtitle,
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                  ),
                ],
                const SizedBox(height: 24),
                ..._buildOptions(q, selected),
              ],
            ),
          ),
        ),
        // Кнопка действия
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selected == null || _submitting
                  ? null
                  : () {
                      if (isLast) {
                        _submit();
                      } else {
                        setState(() => _index++);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                disabledBackgroundColor: AppTheme.card,
                foregroundColor: Colors.white,
                disabledForegroundColor: AppTheme.textDim,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      isLast ? 'Готово' : 'Далее',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ),
        // Progress bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final p = (_index + 1) / _questions.length;
              return SizedBox(
                height: 4,
                child: Stack(
                  children: [
                    Container(
                      width: w,
                      decoration: BoxDecoration(
                        color: const Color(0x14FFFFFF),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: w * p,
                      decoration: BoxDecoration(
                        color: AppTheme.accent,
                        borderRadius: BorderRadius.circular(2),
                      ),
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

  List<Widget> _buildOptions(_QuizQuestion q, int? selected) {
    return List.generate(q.options.length, (i) {
      final isSelected = selected == i;
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: GestureDetector(
          onTap: () => setState(() => _answers[_index] = i),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.accentSoft : AppTheme.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppTheme.accent : AppTheme.border,
                width: isSelected ? 1.5 : 0.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.accent : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppTheme.accent : AppTheme.textSecondary,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    q.options[i],
                    style: TextStyle(
                      color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _QuizQuestion {
  final int id;
  final String title;
  final String subtitle;
  final List<String> options;

  _QuizQuestion({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.options,
  });

  factory _QuizQuestion.fromJson(Map<String, dynamic> json) {
    return _QuizQuestion(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      options: ((json['options'] as List?) ?? []).map((e) => e.toString()).toList(),
    );
  }
}

class _QuizResult {
  final double level;
  final int score;
  final int maxScore;
  final String category;

  _QuizResult({
    required this.level,
    required this.score,
    required this.maxScore,
    required this.category,
  });
}
