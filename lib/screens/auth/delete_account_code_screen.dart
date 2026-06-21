import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/otp_code_input.dart';
import '../../widgets/resend_code_button.dart';

/// Экран подтверждения удаления аккаунта по SMS-коду.
/// После верного кода аккаунт анонимизируется и происходит logout.
class DeleteAccountCodeScreen extends StatefulWidget {
  const DeleteAccountCodeScreen({super.key});

  @override
  State<DeleteAccountCodeScreen> createState() =>
      _DeleteAccountCodeScreenState();
}

class _DeleteAccountCodeScreenState extends State<DeleteAccountCodeScreen> {
  String _code = '';

  Future<void> _delete() async {
    if (_code.length < 4) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.deleteAccount(code: _code);
    if (ok && mounted) {
      // Провайдер уже сбросил сессию (status → unauthenticated).
      // Возвращаемся в корень — приложение покажет экран входа.
      Navigator.of(context).popUntil((route) => route.isFirst);
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
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
                l.deleteAccountTitle,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l.deleteAccountCodeHint,
                style:
                    const TextStyle(color: AppTheme.textSecondary, fontSize: 15),
              ),
              const SizedBox(height: 40),
              OtpCodeInput(
                activeColor: AppTheme.error,
                onChanged: (v) => setState(() => _code = v),
                onCompleted: (_) => _delete(),
              ),
              Consumer<AuthProvider>(
                builder: (_, auth, __) {
                  if (auth.error == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Center(
                      child: Text(
                        auth.error!,
                        style: const TextStyle(
                            color: AppTheme.error, fontSize: 14),
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
                    await context.read<AuthProvider>().sendDeleteCode();
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
                          (auth.isLoading || _code.length < 4) ? null : _delete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.error,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        disabledBackgroundColor:
                            AppTheme.error.withValues(alpha: 0.5),
                      ),
                      child: auth.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              l.deleteButton,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
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
