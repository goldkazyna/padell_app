import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../services/support_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_back_button.dart';

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
  bool _sending = false;

  static const _maxPhotos = 5;

  @override
  void dispose() {
    _subject.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    if (_photos.length >= _maxPhotos) return;
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 85,
    );
    if (picked == null) return;
    try {
      final dir = await getTemporaryDirectory();
      final target =
          '${dir.path}/sup_${DateTime.now().millisecondsSinceEpoch}.webp';
      final compressed = await FlutterImageCompress.compressAndGetFile(
        picked.path,
        target,
        format: CompressFormat.webp,
        quality: 80,
        minWidth: 1600,
        minHeight: 1600,
      );
      if (!mounted) return;
      setState(() => _photos.add(File(compressed?.path ?? picked.path)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _photos.add(File(picked.path)));
    }
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
                children: const [
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
                  _label('Тема'),
                  _field(_subject, hint: 'Например: Не проходит оплата'),
                  const SizedBox(height: 16),
                  _label('Сообщение'),
                  _field(_body,
                      hint: 'Опишите проблему подробно', maxLines: 6),
                  const SizedBox(height: 16),
                  _label('Фото (до $_maxPhotos)'),
                  const SizedBox(height: 8),
                  _photosRow(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _sending ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _sending
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.black),
                        )
                      : const Text('Отправить',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w800,
                              fontSize: 15)),
                ),
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
                    decoration: const BoxDecoration(
                        color: Color(0xFFEF4444), shape: BoxShape.circle),
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
            onTap: _pickPhoto,
            child: Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              child: const Icon(Icons.add_a_photo_outlined,
                  color: AppTheme.textDim),
            ),
          ),
      ],
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
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
        style: const TextStyle(color: AppTheme.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppTheme.textDim),
          filled: true,
          fillColor: AppTheme.card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
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
