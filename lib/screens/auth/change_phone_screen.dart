import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/otp_code_input.dart';
import '../../widgets/resend_code_button.dart';

enum _Step { oldCode, newPhone, newCode }

/// Смена номера телефона: подтверждение старого номера по SMS → ввод нового →
/// подтверждение нового по SMS → успех. Возвращает новый номер через pop.
class ChangePhoneScreen extends StatefulWidget {
  /// Текущий номер (11 цифр) — для отображения в первом шаге.
  final String currentPhone;

  const ChangePhoneScreen({super.key, required this.currentPhone});

  @override
  State<ChangePhoneScreen> createState() => _ChangePhoneScreenState();
}

class _ChangePhoneScreenState extends State<ChangePhoneScreen> {
  _Step _step = _Step.oldCode;
  String? _token;
  bool _loading = false;
  String? _error;

  final _newPhoneController = TextEditingController();

  String get _fullNewPhone =>
      '7${_newPhoneController.text.replaceAll(RegExp(r'[^\d]'), '')}';

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _newPhoneController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    _token = await StorageService().getToken();
    await _sendOldCode();
  }

  String _formatPhone(String p) {
    if (p.length == 11) {
      return '+${p.substring(0, 1)} ${p.substring(1, 4)} ${p.substring(4, 7)} ${p.substring(7, 9)} ${p.substring(9)}';
    }
    return '+$p';
  }

  // --- API ---
  Future<bool> _post(String path, Map<String, dynamic> body) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ApiService().post(path, body, _token);
      if (mounted) setState(() => _loading = false);
      return true;
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.message;
        });
      }
      return false;
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Ошибка сети';
        });
      }
      return false;
    }
  }

  Future<void> _sendOldCode() => _post('/auth/phone/send-old-code', {});

  Future<void> _confirmOld(String code) async {
    final ok = await _post('/auth/phone/confirm-old', {'code': code});
    if (ok && mounted) setState(() => _step = _Step.newPhone);
  }

  Future<void> _sendNewCode() async {
    final digits = _newPhoneController.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length < 10) {
      setState(() => _error = AppLocalizations.of(context)!.enterValidNumber);
      return;
    }
    final ok =
        await _post('/auth/phone/send-new-code', {'phone': _fullNewPhone});
    if (ok && mounted) setState(() => _step = _Step.newCode);
  }

  Future<void> _confirmNew(String code) async {
    final ok = await _post('/auth/phone/confirm-new', {'code': code});
    if (ok && mounted) {
      Navigator.pop(context, _fullNewPhone);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: Text(l.changePhoneTitle,
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: switch (_step) {
            _Step.oldCode => _buildOldCode(l),
            _Step.newPhone => _buildNewPhone(l),
            _Step.newCode => _buildNewCode(l),
          },
        ),
      ),
    );
  }

  Widget _buildOldCode(AppLocalizations l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.changePhoneOldHint,
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(_formatPhone(widget.currentPhone),
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 15)),
        const SizedBox(height: 36),
        OtpCodeInput(
          key: const ValueKey('old'),
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
          onCompleted: _confirmOld,
        ),
        _errorText(),
        const SizedBox(height: 8),
        Center(child: ResendCodeButton(onResend: _sendOldCode)),
        if (_loading) ...[
          const SizedBox(height: 16),
          const Center(
              child: CircularProgressIndicator(color: AppTheme.accent)),
        ],
      ],
    );
  }

  Widget _buildNewPhone(AppLocalizations l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.changePhoneEnterNew,
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 36),
        TextField(
          controller: _newPhoneController,
          keyboardType: TextInputType.phone,
          autofocus: true,
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
          style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
            _KzPhoneFormatter(),
          ],
          decoration: InputDecoration(
            prefixText: '+7  ',
            prefixStyle: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 18,
                fontWeight: FontWeight.w600),
            hintText: '(000) 000-00-00',
            hintStyle:
                TextStyle(color: AppTheme.textSecondary.withValues(alpha: 0.5)),
            filled: true,
            fillColor: AppTheme.card,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppTheme.accent)),
          ),
        ),
        _errorText(),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _loading ? null : _sendNewCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              disabledBackgroundColor: AppTheme.accent.withValues(alpha: 0.5),
            ),
            child: _loading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : Text(l.getCodeButton,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildNewCode(AppLocalizations l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.changePhoneNewHint,
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(_formatPhone(_fullNewPhone),
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 15)),
        const SizedBox(height: 36),
        OtpCodeInput(
          key: const ValueKey('new'),
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
          onCompleted: _confirmNew,
        ),
        _errorText(),
        const SizedBox(height: 8),
        Center(child: ResendCodeButton(onResend: _sendNewCode)),
        if (_loading) ...[
          const SizedBox(height: 16),
          const Center(
              child: CircularProgressIndicator(color: AppTheme.accent)),
        ],
      ],
    );
  }

  Widget _errorText() {
    if (_error == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Center(
        child: Text(_error!,
            style: const TextStyle(color: AppTheme.error, fontSize: 14),
            textAlign: TextAlign.center),
      ),
    );
  }
}

class _KzPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 0) buffer.write('(');
      if (i == 3) buffer.write(') ');
      if (i == 6) buffer.write('-');
      if (i == 8) buffer.write('-');
      buffer.write(digits[i]);
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
