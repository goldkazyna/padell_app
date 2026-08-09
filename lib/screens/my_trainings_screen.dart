import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/training.dart';
import '../services/training_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_back_button.dart';
import 'training_detail_screen.dart';
import 'trainings_screen.dart';

/// Занятия, на которые записан игрок: предстоящие и прошедшие.
class MyTrainingsScreen extends StatefulWidget {
  const MyTrainingsScreen({super.key});

  @override
  State<MyTrainingsScreen> createState() => _MyTrainingsScreenState();
}

class _MyTrainingsScreenState extends State<MyTrainingsScreen> {
  List<Training> _upcoming = const [];
  List<Training> _past = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await context.read<TrainingService>().getMy();
      if (!mounted) return;
      setState(() {
        _upcoming = data.upcoming;
        _past = data.past;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _open(Training t) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TrainingDetailScreen(trainingId: t.id)),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  const AppBackButton(),
                  const SizedBox(width: 12),
                  Text('Мои тренировки',
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_upcoming.isEmpty && _past.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Вы пока никуда не записались.\nПосмотрите ближайшие тренировки на главной.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          if (_upcoming.isNotEmpty) ...[
            _sectionTitle('Предстоящие'),
            for (final t in _upcoming) ...[
              TrainingCard(training: t, onTap: () => _open(t)),
              const SizedBox(height: 10),
            ],
          ],
          if (_past.isNotEmpty) ...[
            const SizedBox(height: 8),
            _sectionTitle('Прошедшие'),
            for (final t in _past) ...[
              Opacity(
                opacity: 0.65,
                child: TrainingCard(training: t, onTap: () => _open(t)),
              ),
              const SizedBox(height: 10),
            ],
          ],
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text,
            style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700)),
      );
}
