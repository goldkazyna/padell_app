import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../services/push_notification_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/otp_code_input.dart';
import '../../widgets/resend_code_button.dart';
import 'sms_registration_screen.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String phone;

  const VerifyCodeScreen({super.key, required this.phone});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  String _code = '';

  Future<void> _verifyCode() async {
    if (_code.length < 4) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.verifyCode(widget.phone, _code);

    if (success && mounted) {
      // Send FCM token and accept terms after login
      context.read<PushNotificationService>().registerToken();
      context.read<AuthProvider>().acceptTerms();
      // Новый пользователь (создан по номеру) → сначала экран регистрации
      // (ФИО, город, дата рождения, пол), потом обычный роутинг (квиз/главная).
      if (context.read<AuthProvider>().lastVerifyIsNew) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SmsRegistrationScreen()),
        );
      } else {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  String get _formattedPhone {
    final p = widget.phone;
    if (p.length == 11) {
      return '+${p.substring(0, 1)} ${p.substring(1, 4)} ${p.substring(4, 7)} ${p.substring(7, 9)} ${p.substring(9)}';
    }
    return '+$p';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () {
            context.read<AuthProvider>().clearError();
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.verificationCode,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l.codeSentTo(_formattedPhone),
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),
              OtpCodeInput(
                onChanged: (v) => setState(() => _code = v),
                onCompleted: (_) => _verifyCode(),
              ),
              Consumer<AuthProvider>(
                builder: (_, auth, __) {
                  if (auth.error == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Center(
                      child: Text(
                        auth.error!,
                        style: TextStyle(
                          color: AppTheme.error,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              Center(
                child: ResendCodeButton(
                  onResend: () async {
                    await context.read<AuthProvider>().sendCode(widget.phone);
                  },
                ),
              ),
              const Spacer(),
              Consumer<AuthProvider>(
                builder: (_, auth, __) {
                  return SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed:
                          (auth.isLoading || _code.length < 4) ? null : _verifyCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor:
                            AppTheme.accent.withValues(alpha: 0.5),
                      ),
                      child: auth.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              l.confirmButton,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
