import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../theme/app_theme.dart';

/// Показывает меню «Камера / Галерея / Файлы» и возвращает выбранный файл:
/// изображение (сжатое в webp) или PDF. null — если отменили.
Future<File?> pickSupportAttachment(BuildContext context) async {
  final choice = await showModalBottomSheet<String>(
    context: context,
    backgroundColor: AppTheme.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          _tile(ctx, Icons.photo_camera_outlined, 'Сделать фото', 'camera'),
          _tile(ctx, Icons.photo_library_outlined, 'Из галереи', 'gallery'),
          _tile(ctx, Icons.insert_drive_file_outlined, 'Файл (PDF)', 'file'),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );

  switch (choice) {
    case 'camera':
      return _pickImage(ImageSource.camera);
    case 'gallery':
      return _pickImage(ImageSource.gallery);
    case 'file':
      return _pickPdf();
    default:
      return null;
  }
}

Widget _tile(BuildContext ctx, IconData icon, String label, String value) {
  return ListTile(
    leading: Icon(icon, color: AppTheme.accent),
    title: Text(label, style: TextStyle(color: AppTheme.textPrimary)),
    onTap: () => Navigator.pop(ctx, value),
  );
}

Future<File?> _pickImage(ImageSource source) async {
  final picked = await ImagePicker().pickImage(
    source: source,
    maxWidth: 1600,
    maxHeight: 1600,
    imageQuality: 85,
  );
  if (picked == null) return null;
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
    return File(compressed?.path ?? picked.path);
  } catch (_) {
    return File(picked.path);
  }
}

Future<File?> _pickPdf() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf'],
  );
  final path = result?.files.single.path;
  if (path == null) return null;
  return File(path);
}

bool isPdfPath(String path) => path.toLowerCase().endsWith('.pdf');
