import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/club_waiver.dart';
import '../providers/profile_provider.dart';
import '../services/api_service.dart';
import '../services/waiver_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_back_button.dart';
import '../widgets/waiver/signature_pad.dart';

/// Отказ от ответственности клуба: прочитать и расписаться пальцем.
///
/// Открывается по QR со стойки клуба — padelp://waiver/{club}.
class ClubWaiverScreen extends StatefulWidget {
  const ClubWaiverScreen({super.key, required this.clubId});

  final int clubId;

  @override
  State<ClubWaiverScreen> createState() => _ClubWaiverScreenState();
}

class _ClubWaiverScreenState extends State<ClubWaiverScreen> {
  final _pad = SignaturePadController();
  final _nameController = TextEditingController();

  ClubWaiver? _waiver;
  String? _error;
  bool _needAuth = false;
  bool _sending = false;
  bool _nameTouched = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _pad.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final waiver = await context.read<WaiverService>().load(widget.clubId);
      if (!mounted) return;

      // ФИО подставляем из профиля — там часто ник или одно имя,
      // поэтому поле остаётся редактируемым.
      if (!_nameTouched && _nameController.text.isEmpty) {
        _nameController.text =
            waiver.fullName ?? context.read<ProfileProvider>().user?.name ?? '';
      }

      setState(() {
        _waiver = waiver;
        _error = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      // Человек навёл камеру, не войдя в приложение: показываем, что делать,
      // вместо голого «Unauthenticated».
      setState(() => e.statusCode == 401 ? _needAuth = true : _error = '$e');
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '$e');
    }
  }

  bool get _canSign =>
      !_sending && _nameController.text.trim().length >= 3 && !_pad.isEmpty;

  Future<void> _sign() async {
    final waiver = _waiver;
    if (waiver?.textHash == null) return;

    // Сервис берём до await: после него трогать context нельзя.
    final service = context.read<WaiverService>();

    final png = await _pad.toPng();
    if (png == null) return;

    setState(() => _sending = true);
    try {
      final signedAt = await service.sign(
            clubId: widget.clubId,
            fullName: _nameController.text.trim(),
            textHash: waiver!.textHash!,
            signature: png,
          );
      if (!mounted) return;
      setState(() {
        _sending = false;
        _waiver = ClubWaiver(
          collects: waiver.collects,
          clubName: waiver.clubName,
          text: waiver.text,
          textHash: waiver.textHash,
          signedAt: signedAt,
          fullName: _nameController.text.trim(),
          signedText: waiver.text,
        );
      });
    } on WaiverTextChanged catch (e) {
      // Клуб поправил текст, пока человек читал: показываем свежий
      // и просим подписать заново.
      if (!mounted) return;
      _pad.clear();
      setState(() {
        _sending = false;
        _waiver = e.waiver;
      });
      _showMessage('Текст изменился — перечитайте его и подпишите снова');
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      _showMessage('$e');
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), backgroundColor: AppTheme.cardRaised),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 12),
          child: Center(child: AppBackButton()),
        ),
        title: const Text('Отказ от ответственности',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(top: false, child: _body()),
    );
  }

  Widget _body() {
    if (_needAuth) return _authRequired();
    if (_error != null) return _message(Icons.error_outline, _error!);

    final waiver = _waiver;
    if (waiver == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!waiver.collects) {
      return _message(
        Icons.info_outline,
        'Этот клуб не собирает отказ от ответственности.',
      );
    }
    if (waiver.isSigned) return _signed(waiver);

    return _form(waiver);
  }

  /// Отказ подписывает конкретный человек, поэтому без входа никак.
  ///
  /// Экран входа лежит под нами: приложение показывает его корнем, пока
  /// человек не авторизован. Кнопка туда и возвращает.
  Widget _authRequired() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, size: 42, color: AppTheme.textDim),
            const SizedBox(height: 14),
            Text(
              'Авторизуйтесь',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Отказ от ответственности подписывается от вашего имени — '
              'войдите в приложение Padel KZ.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: const Color(0xFF08130C),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Войти',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'После входа снова наведите камеру на QR-код на стойке клуба.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textDim, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _message(IconData icon, String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42, color: AppTheme.textDim),
            const SizedBox(height: 14),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _signed(ClubWaiver waiver) {
    final when = DateFormat('d MMMM y, HH:mm', 'ru').format(waiver.signedAt!);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.accentSoft,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: AppTheme.accent, size: 30),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Подписано',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.accent)),
                    const SizedBox(height: 3),
                    Text(when,
                        style: TextStyle(
                            fontSize: 13.5, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (waiver.fullName != null) ...[
          _label('Подписал'),
          const SizedBox(height: 6),
          Text(waiver.fullName!,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 18),
        ],
        _label('Текст, который вы подписали'),
        const SizedBox(height: 8),
        _textBlock(waiver.signedText ?? waiver.text ?? '', scrollable: false),
      ],
    );
  }

  Widget _form(ClubWaiver waiver) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        Text(
          waiver.clubName,
          style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 14),
        _textBlock(waiver.text ?? '', scrollable: true),
        const SizedBox(height: 22),
        _label('ФИО'),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          onChanged: (_) => setState(() => _nameTouched = true),
          textCapitalization: TextCapitalization.words,
          style: TextStyle(color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'Фамилия Имя Отчество',
            hintStyle: TextStyle(color: AppTheme.textDim),
            filled: true,
            fillColor: AppTheme.card,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(child: _label('Подпись')),
            TextButton(
              onPressed: () {
                _pad.clear();
                setState(() {});
              },
              child: Text('Очистить',
                  style: TextStyle(color: AppTheme.textSecondary)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Кнопка «Подписываю» оживает, когда на холсте появился штрих,
        // — состояние пересчитываем, как только палец оторвали.
        Listener(
          onPointerUp: (_) => setState(() {}),
          child: SignaturePad(controller: _pad),
        ),
        const SizedBox(height: 8),
        Text('Распишитесь пальцем в белом поле',
            style: TextStyle(fontSize: 12.5, color: AppTheme.textDim)),
        const SizedBox(height: 24),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: _canSign ? _sign : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              disabledBackgroundColor: AppTheme.card,
              foregroundColor: const Color(0xFF08130C),
              disabledForegroundColor: AppTheme.textDim,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: _sending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Color(0xFF08130C)))
                : const Text('Подписываю',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ),
        ),
      ],
    );
  }

  Widget _label(String text) => Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          letterSpacing: 0.9,
          fontWeight: FontWeight.w700,
          color: AppTheme.textDim,
        ),
      );

  Widget _textBlock(String text, {required bool scrollable}) {
    // Текст выделяется долгим нажатием: из отказа могут выписывать пункты.
    final content = SelectionArea(
      child: Text(
        text,
        style: TextStyle(
            fontSize: 14.5, height: 1.55, color: AppTheme.textSecondary),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      constraints: scrollable ? const BoxConstraints(maxHeight: 300) : null,
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: scrollable ? SingleChildScrollView(child: content) : content,
    );
  }
}
