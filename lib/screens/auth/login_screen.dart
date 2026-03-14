import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import 'verify_code_screen.dart';
import 'telegram_waiting_screen.dart';
import 'email_login_screen.dart';
import 'legal_document_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showPhoneLogin = false;
  int _secretTapCount = 0;
  bool _termsAccepted = false;
  bool _consentAccepted = false;

  bool get _allAccepted => _termsAccepted && _consentAccepted;

  String get _fullPhone => '7${_phoneController.text.replaceAll(RegExp(r'[^\d]'), '')}';

  void _showAcceptHint() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.info_outline, color: AppTheme.accent, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Для продолжения необходимо принять пользовательское соглашение и дать согласие на обработку персональных данных',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Понятно', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.sendCode(_fullPhone);

    if (success && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyCodeScreen(phone: _fullPhone),
        ),
      );
    }
  }

  void _openTelegram() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TelegramWaitingScreen()),
    );
  }

  void _openTermsDocument() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LegalDocumentScreen(
          title: 'Пользовательское соглашение',
          assetPath: 'assets/legal/terms.html',
        ),
      ),
    );
  }

  void _openConsentDocument() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LegalDocumentScreen(
          title: 'Согласие на обработку данных',
          assetPath: 'assets/legal/consent.html',
        ),
      ),
    );
  }

  void _onSecretTap() {
    _secretTapCount++;
    if (_secretTapCount >= 5) {
      _secretTapCount = 0;
      _showSecretDialog();
    }
  }

  void _showSecretDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: const Text(
          'Введите код',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 16),
        ),
        content: TextField(
          controller: controller,
          obscureText: true,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: TextStyle(color: AppTheme.textSecondary.withValues(alpha: 0.5)),
            filled: true,
            fillColor: AppTheme.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              if (controller.text == '05070507') {
                Navigator.pop(ctx);
                setState(() => _showPhoneLogin = true);
              } else {
                Navigator.pop(ctx);
              }
            },
            child: const Text('OK', style: TextStyle(color: AppTheme.accent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Back button
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary, size: 20),
                    onPressed: () => Navigator.maybePop(context),
                    padding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 32),

                // Title — secret tap target
                GestureDetector(
                  onTap: _onSecretTap,
                  child: const Text(
                    'Вход',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _showPhoneLogin
                      ? 'Введите номер телефона для входа'
                      : 'Войдите через Telegram для продолжения',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 32),

                // Phone login (hidden by default)
                if (_showPhoneLogin) ...[
                  // Phone label
                  const Text(
                    'Номер телефона',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Phone input
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                      _PhoneInputFormatter(),
                    ],
                    decoration: InputDecoration(
                      prefixText: '+7  ',
                      prefixStyle: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 16,
                      ),
                      hintText: '(000) 000-00-00',
                      hintStyle: TextStyle(
                        color: AppTheme.textSecondary.withValues(alpha: 0.5),
                      ),
                      filled: true,
                      fillColor: AppTheme.card,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppTheme.accent),
                      ),
                    ),
                    validator: (value) {
                      final digits = value?.replaceAll(RegExp(r'[^\d]'), '') ?? '';
                      if (digits.length < 10) {
                        return 'Введите корректный номер';
                      }
                      return null;
                    },
                  ),

                  // Error message
                  Consumer<AuthProvider>(
                    builder: (_, auth, __) {
                      if (auth.error == null) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          auth.error!,
                          style: const TextStyle(
                            color: AppTheme.error,
                            fontSize: 14,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Continue button
                  Consumer<AuthProvider>(
                    builder: (_, auth, __) {
                      return SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: auth.isLoading || !_allAccepted ? null : _sendCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            disabledBackgroundColor: AppTheme.accent.withValues(alpha: 0.3),
                            elevation: 0,
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
                              : const Text(
                                  'Продолжить',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Divider with "или"
                  Row(
                    children: [
                      Expanded(child: Container(height: 1, color: AppTheme.card)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'или',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(child: Container(height: 1, color: AppTheme.card)),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                // Telegram button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _allAccepted ? _openTelegram : _showAcceptHint,
                    icon: const Icon(Icons.send, size: 20),
                    label: const Text(
                      'Войти через Telegram',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _allAccepted
                          ? const Color(0xFF38A5E1)
                          : const Color(0xFF38A5E1).withValues(alpha: 0.3),
                      foregroundColor: _allAccepted
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Divider "или"
                Row(
                  children: [
                    Expanded(child: Container(height: 1, color: AppTheme.card)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'или',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(child: Container(height: 1, color: AppTheme.card)),
                  ],
                ),
                const SizedBox(height: 20),

                // Email login button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: _allAccepted
                        ? () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EmailLoginScreen(),
                              ),
                            )
                        : _showAcceptHint,
                    icon: const Icon(Icons.email_outlined, size: 20),
                    label: const Text(
                      'Войти через Email',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _allAccepted
                          ? AppTheme.textPrimary
                          : AppTheme.textPrimary.withValues(alpha: 0.3),
                      side: BorderSide(
                        color: _allAccepted
                            ? const Color(0xFF2A2A2A)
                            : const Color(0xFF2A2A2A).withValues(alpha: 0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // Checkboxes for legal documents
                _buildCheckboxRow(
                  value: _termsAccepted,
                  onChanged: (v) => setState(() => _termsAccepted = v ?? false),
                  text: 'Пользовательское соглашение',
                  onTap: _openTermsDocument,
                ),
                const SizedBox(height: 8),
                _buildCheckboxRow(
                  value: _consentAccepted,
                  onChanged: (v) => setState(() => _consentAccepted = v ?? false),
                  text: 'Согласие на обработку персональных данных',
                  onTap: _openConsentDocument,
                ),

                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Developed by Dudnikov Denis',
                    style: TextStyle(
                      color: Color(0xFF3A3A3A),
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxRow({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: AppTheme.accent,
              checkColor: Colors.white,
              side: const BorderSide(color: AppTheme.textSecondary, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Text(
                text,
                style: const TextStyle(
                  color: AppTheme.accent,
                  fontSize: 13,
                  decoration: TextDecoration.underline,
                  decorationColor: AppTheme.accent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
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
