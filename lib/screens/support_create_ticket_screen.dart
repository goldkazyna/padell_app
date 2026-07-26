import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/support_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_back_button.dart';
import '../widgets/app_primary_button.dart';
import '../widgets/support/attachment_picker.dart';

class SupportCreateTicketScreen extends StatefulWidget {
  const SupportCreateTicketScreen({super.key});

  @override
  State<SupportCreateTicketScreen> createState() =>
      _SupportCreateTicketScreenState();
}

class _SupportCreateTicketScreenState extends State<SupportCreateTicketScreen> {
  final _subject = TextEditingController();
  final _body = TextEditingController();
  final List<File> _photos = [];
  String? _category;
  bool _sending = false;

  static const _maxPhotos = 5;
  static const _categories = ['Аккаунт', 'Оплата', 'Турнир', 'Бронь', 'Другое'];

  @override
  void dispose() {
    _subject.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _addAttachment() async {
    if (_photos.length >= _maxPhotos) return;
    final file = await pickSupportAttachment(context);
    if (file == null || !mounted) return;
    setState(() => _photos.add(file));
  }

  Future<void> _submit() async {
    final subject = _subject.text.trim();
    final body = _body.text.trim();
    if (subject.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните тему и сообщение')),
      );
      return;
    }
    setState(() => _sending = true);
    try {
      await context.read<SupportService>().createTicket(
            subject: subject,
            body: body,
            category: _category,
            photoPaths: _photos.map((f) => f.path).toList(),
          );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось отправить: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              child: Row(
                children: [
                  AppBackButton(),
                  SizedBox(width: 4),
                  Text(
                    'Новое обращение',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  _label('Категория'),
                  const SizedBox(height: 8),
                  _categoryChips(),
                  const SizedBox(height: 16),
                  _label('Тема'),
                  _field(_subject, hint: 'Например: Не проходит оплата'),
                  const SizedBox(height: 16),
                  _label('Сообщение'),
                  _field(_body,
                      hint: 'Опишите проблему подробно — что произошло, '
                          'когда, на каком экране…',
                      maxLines: 6),
                  const SizedBox(height: 16),
                  _label('Вложения (до $_maxPhotos)'),
                  const SizedBox(height: 8),
                  _photosRow(),
                  const SizedBox(height: 8),
                  Text(
                    'Фото или PDF. Изображения сжимаются автоматически.',
                    style: TextStyle(color: AppTheme.textDim, fontSize: 12),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: AppPrimaryButton(
                label: 'Отправить обращение',
                onPressed: _submit,
                icon: Icons.send_rounded,
                loading: _sending,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _photosRow() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (int i = 0; i < _photos.length; i++)
          Stack(
            clipBehavior: Clip.none,
            children: [
              if (isPdfPath(_photos[i].path))
                Container(
                  width: 78,
                  height: 78,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF2A3330)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.picture_as_pdf,
                          color: AppTheme.error, size: 26),
                      const SizedBox(height: 4),
                      Text(
                        _photos[i].path.split(Platform.pathSeparator).last,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: AppTheme.textDim, fontSize: 9),
                      ),
                    ],
                  ),
                )
              else
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(_photos[i],
                      width: 78, height: 78, fit: BoxFit.cover),
                ),
              Positioned(
                top: -6,
                right: -6,
                child: GestureDetector(
                  onTap: () => setState(() => _photos.removeAt(i)),
                  child: Container(
                    decoration: BoxDecoration(
                        color: AppTheme.error, shape: BoxShape.circle),
                    padding: const EdgeInsets.all(2),
                    child: const Icon(Icons.close,
                        size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        if (_photos.length < _maxPhotos)
          GestureDetector(
            onTap: _addAttachment,
            child: Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF2A3330)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: AppTheme.textDim, size: 22),
                  SizedBox(height: 2),
                  Text('Добавить',
                      style: TextStyle(color: AppTheme.textDim, fontSize: 10)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  IconData? _catIcon(String c) {
    switch (c) {
      case 'Аккаунт':
        return Icons.person_outline;
      case 'Оплата':
        return Icons.credit_card;
      case 'Турнир':
        return Icons.emoji_events_outlined;
      case 'Бронь':
        return Icons.calendar_today_outlined;
      default:
        return null; // «Другое» — без иконки
    }
  }

  Widget _categoryChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final c in _categories)
          GestureDetector(
            onTap: () => setState(() => _category = _category == c ? null : c),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
              decoration: BoxDecoration(
                color: _category == c ? AppTheme.accentSoft : AppTheme.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _category == c
                      ? AppTheme.accent
                      : const Color(0xFF2A3330),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_catIcon(c) != null) ...[
                    Icon(_catIcon(c),
                        size: 15,
                        color: _category == c
                            ? AppTheme.accent
                            : AppTheme.textSecondary),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    c,
                    style: TextStyle(
                      color: _category == c
                          ? AppTheme.accent
                          : AppTheme.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _label(String text) => Text(
        text,
        style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w700),
      );

  Widget _field(TextEditingController c,
      {String? hint, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        style: TextStyle(color: AppTheme.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppTheme.textDim),
          filled: true,
          fillColor: AppTheme.card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2A3330)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2A3330)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.accent),
          ),
        ),
      ),
    );
  }
}
