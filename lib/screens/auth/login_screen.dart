import 'dart:io' show Platform;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import 'telegram_waiting_screen.dart';
import 'email_login_screen.dart';
import 'legal_document_screen.dart';
import 'verify_code_screen.dart';

enum _Provider { telegram, whatsapp, google, apple }

class _ProviderTint {
  final Color bg;
  final Color border;
  const _ProviderTint(this.bg, this.border);
}

const _tints = {
  _Provider.telegram: _ProviderTint(
    Color(0x0F229ED9), // rgba(34,158,217,0.06)
    Color(0x2E229ED9), // rgba(34,158,217,0.18)
  ),
  _Provider.whatsapp: _ProviderTint(
    Color(0x0F25D366), // rgba(37,211,102,0.06)
    Color(0x2E25D366), // rgba(37,211,102,0.18)
  ),
  _Provider.google: _ProviderTint(
    Color(0x0AFFFFFF), // rgba(255,255,255,0.04)
    Color(0x1FFFFFFF), // rgba(255,255,255,0.12)
  ),
  _Provider.apple: _ProviderTint(
    Color(0x0AFFFFFF),
    Color(0x1FFFFFFF),
  ),
};

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _agreed = true;
  bool _showAgreeError = false;

  // Секретный вход (5 тапов на «Вход» → код 05070507 → форма телефона).
  int _secretTapCount = 0;
  bool _showPhoneLogin = false;
  final _phoneController = TextEditingController();
  final _phoneFormKey = GlobalKey<FormState>();
  String get _fullPhone => '7${_phoneController.text.replaceAll(RegExp(r'[^\d]'), '')}';

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Введите код',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 16),
        ),
        content: TextField(
          controller: controller,
          obscureText: true,
          keyboardType: TextInputType.number,
          autofocus: true,
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
            child: const Text(
              'Отмена',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
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

  Future<void> _sendCode() async {
    if (!_phoneFormKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.sendCode(_fullPhone);
    if (!mounted) return;
    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => VerifyCodeScreen(phone: _fullPhone)),
      );
    }
  }

  void _onProvider(_Provider p) {
    if (!_agreed) {
      setState(() => _showAgreeError = true);
      return;
    }
    switch (p) {
      case _Provider.telegram:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TelegramWaitingScreen()),
        );
        break;
      case _Provider.google:
        _signInWithGoogle();
        break;
      case _Provider.apple:
        if (Platform.isIOS || Platform.isMacOS) {
          _signInWithApple();
        } else {
          _showComingSoon();
        }
        break;
      case _Provider.whatsapp:
        _showComingSoon();
        break;
    }
  }

  Future<void> _signInWithGoogle() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.googleLogin();
    if (!mounted) return;
    if (!success && auth.error != null) {
      _showError(auth.error!);
    }
  }

  Future<void> _signInWithApple() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.appleLogin();
    if (!mounted) return;
    if (!success && auth.error != null) {
      _showError(auth.error!);
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Ошибка',
          style: TextStyle(
            color: AppTheme.error,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'OK',
              style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _onEmail() {
    if (!_agreed) {
      setState(() => _showAgreeError = true);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EmailLoginScreen()),
    );
  }

  void _showComingSoon() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Скоро',
          style: TextStyle(
            color: AppTheme.accent,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Этот способ входа скоро будет доступен',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'OK',
              style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _openTerms() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LegalDocumentScreen(
          title: AppLocalizations.of(context)!.termsOfService,
          assetPath: 'assets/legal/terms.html',
        ),
      ),
    );
  }

  void _openConsent() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LegalDocumentScreen(
          title: AppLocalizations.of(context)!.consentToProcessing,
          assetPath: 'assets/legal/consent.html',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Ambient glow top-right
            Positioned(
              top: -30,
              right: -40,
              child: IgnorePointer(
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Color(0x1422C47A), // rgba(34,196,122,0.08)
                        Color(0x0022C47A),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  // Back button
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0x14FFFFFF)),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, size: 20, color: AppTheme.textPrimary),
                      onPressed: () => Navigator.maybePop(context),
                      padding: EdgeInsets.zero,
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Header — секретный тап (5 раз) → код 05070507 → телефон
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _onSecretTap,
                    child: const Text(
                      'Вход',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Выберите удобный способ',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Секретная форма телефона (видна только после ввода 05070507)
                  if (_showPhoneLogin) ...[
                    _SecretPhoneForm(
                      formKey: _phoneFormKey,
                      controller: _phoneController,
                      onSubmit: _sendCode,
                    ),
                    const SizedBox(height: 22),
                  ],

                  // 4 social providers
                  _ProviderButton(
                    label: 'Telegram',
                    tint: _tints[_Provider.telegram]!,
                    icon: const _BrandTelegram(),
                    onTap: () => _onProvider(_Provider.telegram),
                  ),
                  const SizedBox(height: 8),
                  _ProviderButton(
                    label: 'WhatsApp',
                    tint: _tints[_Provider.whatsapp]!,
                    icon: const _BrandWhatsApp(),
                    onTap: () => _onProvider(_Provider.whatsapp),
                    disabled: true,
                  ),
                  const SizedBox(height: 8),
                  Consumer<AuthProvider>(
                    builder: (_, auth, child) => _ProviderButton(
                      label: 'Google',
                      tint: _tints[_Provider.google]!,
                      icon: const _BrandGoogle(),
                      loading: auth.isLoading,
                      onTap: auth.isLoading ? null : () => _onProvider(_Provider.google),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Consumer<AuthProvider>(
                    builder: (_, auth, child) => _ProviderButton(
                      label: 'Apple',
                      tint: _tints[_Provider.apple]!,
                      icon: const _BrandApple(),
                      loading: auth.isLoading,
                      onTap: auth.isLoading ? null : () => _onProvider(_Provider.apple),
                    ),
                  ),

                  // Divider "или"
                  Padding(
                    padding: const EdgeInsets.only(top: 18, bottom: 14),
                    child: Row(
                      children: [
                        Expanded(child: Container(height: 1, color: const Color(0x14FFFFFF))),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'или',
                            style: TextStyle(
                              color: AppTheme.textDim,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(child: Container(height: 1, color: const Color(0x14FFFFFF))),
                      ],
                    ),
                  ),

                  // Email fallback
                  _EmailButton(onTap: _onEmail),

                  const Spacer(),

                  // Consent row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => setState(() {
                          _agreed = !_agreed;
                          if (_agreed) _showAgreeError = false;
                        }),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 1),
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: _agreed ? AppTheme.accent : Colors.transparent,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: _agreed ? AppTheme.accent : const Color(0x33FFFFFF),
                                width: 1.5,
                              ),
                            ),
                            child: _agreed
                                ? const Icon(Icons.check, size: 12, color: Color(0xFF0A0A0D))
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ConsentText(
                          onTerms: _openTerms,
                          onConsent: _openConsent,
                        ),
                      ),
                    ],
                  ),

                  if (_showAgreeError)
                    Padding(
                      padding: const EdgeInsets.only(left: 28, top: 6),
                      child: Text(
                        AppLocalizations.of(context)!.authAcceptHint,
                        style: const TextStyle(color: AppTheme.error, fontSize: 11),
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Footer
                  const Center(
                    child: Opacity(
                      opacity: 0.6,
                      child: Text(
                        'Developed by Dudnikov Denis',
                        style: TextStyle(
                          color: AppTheme.textDim,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProviderButton extends StatelessWidget {
  final String label;
  final _ProviderTint tint;
  final Widget icon;
  final VoidCallback? onTap;
  final bool loading;
  final bool disabled;

  const _ProviderButton({
    required this.label,
    required this.tint,
    required this.icon,
    required this.onTap,
    this.loading = false,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final greyBg = const Color(0xFF1A1A1E);
    final greyBorder = const Color(0xFF27272A);
    final greyText = const Color(0xFF71717A);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: disabled ? greyBg : tint.bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: disabled ? greyBorder : tint.border),
          ),
          child: Row(
            children: [
              Opacity(
                opacity: disabled ? 0.45 : 1,
                child: SizedBox(width: 28, height: 28, child: icon),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: disabled ? greyText : AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (disabled) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF27272A),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'скоро',
                          style: TextStyle(
                            color: greyText,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (loading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.textSecondary,
                  ),
                )
              else
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: disabled ? greyText.withAlpha(60) : const Color(0x40FFFFFF),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmailButton extends StatelessWidget {
  final VoidCallback onTap;
  const _EmailButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x14FFFFFF)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 26, height: 26, child: _BrandEmail()),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.loginViaEmail,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConsentText extends StatefulWidget {
  final VoidCallback onTerms;
  final VoidCallback onConsent;
  const _ConsentText({required this.onTerms, required this.onConsent});

  @override
  State<_ConsentText> createState() => _ConsentTextState();
}

class _ConsentTextState extends State<_ConsentText> {
  late final TapGestureRecognizer _termsTap;
  late final TapGestureRecognizer _consentTap;

  @override
  void initState() {
    super.initState();
    _termsTap = TapGestureRecognizer()..onTap = widget.onTerms;
    _consentTap = TapGestureRecognizer()..onTap = widget.onConsent;
  }

  @override
  void dispose() {
    _termsTap.dispose();
    _consentTap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const linkStyle = TextStyle(
      color: AppTheme.accent,
      decoration: TextDecoration.underline,
      decorationColor: AppTheme.accent,
    );
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 11,
          height: 1.5,
        ),
        children: [
          const TextSpan(text: 'Продолжая, я принимаю '),
          TextSpan(
            text: 'Пользовательское соглашение',
            style: linkStyle,
            recognizer: _termsTap,
          ),
          const TextSpan(text: ' и '),
          TextSpan(
            text: 'согласие на обработку данных',
            style: linkStyle,
            recognizer: _consentTap,
          ),
        ],
      ),
    );
  }
}

// === Brand icons (SVG copied from plan/auth/auth-only/src/auth-assets.jsx) ===

const _telegramSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none">
  <circle cx="12" cy="12" r="12" fill="#229ED9"/>
  <path d="M5.5 11.8l11.8-4.6c.6-.2 1.1.2.9.9l-2 9.5c-.2.7-.6.9-1.2.6l-3.3-2.4-1.6 1.5c-.2.2-.3.3-.6.3l.2-3.3 6-5.4c.3-.2-.1-.4-.4-.2l-7.4 4.6-3.2-1c-.7-.2-.7-.7.1-1z" fill="#fff"/>
</svg>
''';

const _whatsappSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none">
  <circle cx="12" cy="12" r="12" fill="#25D366"/>
  <path d="M16.7 14.3c-.3-.1-1.6-.8-1.8-.9-.2-.1-.4-.1-.6.1-.2.3-.7.9-.8 1-.2.2-.3.2-.6.1-.3-.1-1.2-.5-2.3-1.4-.9-.8-1.4-1.7-1.6-2-.2-.3 0-.4.1-.5l.4-.5c.1-.2.2-.3.3-.5 0-.2 0-.4-.1-.5-.1-.1-.6-1.4-.8-1.9-.2-.5-.4-.4-.6-.4h-.5c-.2 0-.5.1-.7.3-.2.3-.9.9-.9 2.1 0 1.2.9 2.4 1 2.6.1.2 1.8 2.7 4.4 3.8.6.3 1.1.4 1.5.5.6.2 1.2.2 1.7.1.5-.1 1.6-.7 1.8-1.3.2-.6.2-1.2.2-1.3-.1-.2-.3-.2-.6-.3z" fill="#fff"/>
</svg>
''';

const _googleSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <rect width="24" height="24" rx="12" fill="#fff"/>
  <g transform="translate(3,3) scale(0.75)">
    <path d="M22.5 12.2c0-.7-.1-1.4-.2-2.1H12v4h5.9c-.3 1.4-1 2.5-2.2 3.3v2.7h3.5c2-1.9 3.3-4.7 3.3-7.9z" fill="#4285F4"/>
    <path d="M12 23c2.9 0 5.4-1 7.2-2.6l-3.5-2.7c-1 .7-2.2 1.1-3.7 1.1-2.8 0-5.2-1.9-6.1-4.5H2.3v2.8C4.1 20.7 7.8 23 12 23z" fill="#34A853"/>
    <path d="M5.9 14.3c-.2-.7-.4-1.4-.4-2.3s.1-1.6.4-2.3V6.9H2.3C1.5 8.5 1 10.2 1 12s.5 3.5 1.3 5.1l3.6-2.8z" fill="#FBBC05"/>
    <path d="M12 5.4c1.6 0 3 .5 4.1 1.6l3.1-3.1C17.4 2.1 14.9 1 12 1 7.8 1 4.1 3.3 2.3 6.9l3.6 2.8C6.8 7.3 9.2 5.4 12 5.4z" fill="#EA4335"/>
  </g>
</svg>
''';

const _appleSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <circle cx="12" cy="12" r="12" fill="#f3f3f5"/>
  <path d="M16.3 13.1c0-1.8 1.5-2.7 1.6-2.7-.9-1.2-2.2-1.4-2.7-1.4-1.1-.1-2.2.7-2.8.7-.6 0-1.5-.7-2.5-.6-1.3 0-2.4.7-3.1 1.9-1.3 2.3-.3 5.7.9 7.5.6.9 1.4 1.9 2.3 1.8.9 0 1.3-.6 2.3-.6s1.4.6 2.4.6c1 0 1.6-.9 2.2-1.8.7-.9 1-1.8 1-1.9-.1 0-1.9-.7-1.9-2.9zM14.5 7.8c.5-.6.8-1.4.8-2.2-.7 0-1.6.4-2.1 1-.4.5-.9 1.4-.8 2.2.8.1 1.6-.4 2.1-1z" fill="#0a0a0d"/>
</svg>
''';

const _emailSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <circle cx="12" cy="12" r="12" fill="#2a2a31"/>
  <rect x="6" y="8" width="12" height="9" rx="1.5" fill="none" stroke="#a2a2ab" stroke-width="1.6"/>
  <path d="M6.5 9l5.5 4 5.5-4" fill="none" stroke="#a2a2ab" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
''';

class _BrandTelegram extends StatelessWidget {
  const _BrandTelegram();
  @override
  Widget build(BuildContext context) => SvgPicture.string(_telegramSvg);
}

class _BrandWhatsApp extends StatelessWidget {
  const _BrandWhatsApp();
  @override
  Widget build(BuildContext context) => SvgPicture.string(_whatsappSvg);
}

class _BrandGoogle extends StatelessWidget {
  const _BrandGoogle();
  @override
  Widget build(BuildContext context) => SvgPicture.string(_googleSvg);
}

class _BrandApple extends StatelessWidget {
  const _BrandApple();
  @override
  Widget build(BuildContext context) => SvgPicture.string(_appleSvg);
}

class _BrandEmail extends StatelessWidget {
  const _BrandEmail();
  @override
  Widget build(BuildContext context) => SvgPicture.string(_emailSvg);
}

class _SecretPhoneForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final Future<void> Function() onSubmit;

  const _SecretPhoneForm({
    required this.formKey,
    required this.controller,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.phone,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
              _PhoneInputFormatter(),
            ],
            decoration: InputDecoration(
              prefixText: '+7  ',
              prefixStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 16),
              hintText: '(000) 000-00-00',
              hintStyle: TextStyle(color: AppTheme.textSecondary.withValues(alpha: 0.5)),
              filled: true,
              fillColor: AppTheme.card,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppTheme.accent),
              ),
            ),
            validator: (value) {
              final digits = value?.replaceAll(RegExp(r'[^\d]'), '') ?? '';
              if (digits.length < 10) {
                return AppLocalizations.of(context)!.enterValidNumber;
              }
              return null;
            },
          ),
          Consumer<AuthProvider>(
            builder: (_, auth, child) {
              if (auth.error == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(auth.error!, style: const TextStyle(color: AppTheme.error, fontSize: 13)),
              );
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: Consumer<AuthProvider>(
              builder: (_, auth, child) => ElevatedButton(
                onPressed: auth.isLoading ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: auth.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        AppLocalizations.of(context)!.continueButton,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
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
