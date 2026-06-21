import 'dart:async';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

/// Кнопка повторной отправки кода. После отправки блокируется на [seconds]
/// секунд с обратным отсчётом, затем снова становится активной.
class ResendCodeButton extends StatefulWidget {
  final Future<void> Function() onResend;
  final int seconds;

  const ResendCodeButton({
    super.key,
    required this.onResend,
    this.seconds = 60,
  });

  @override
  State<ResendCodeButton> createState() => _ResendCodeButtonState();
}

class _ResendCodeButtonState extends State<ResendCodeButton> {
  int _remaining = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _remaining = widget.seconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _remaining--);
      if (_remaining <= 0) t.cancel();
    });
  }

  Future<void> _onTap() async {
    await widget.onResend();
    if (mounted) _startCountdown();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (_remaining > 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          l.resendCodeIn(_remaining),
          style: const TextStyle(
            color: AppTheme.textDim,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    return TextButton(
      onPressed: _onTap,
      child: Text(
        l.resendCode,
        style: const TextStyle(
          color: AppTheme.accent,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
