import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../services/push_notification_service.dart';
import '../../theme/app_theme.dart';
import 'email_login_screen.dart';

class EmailRegisterScreen extends StatefulWidget {
  const EmailRegisterScreen({super.key});

  @override
  State<EmailRegisterScreen> createState() => _EmailRegisterScreenState();
}

class _EmailRegisterScreenState extends State<EmailRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String _phone = '';
  String? _city;

  static const _cities = ['Алматы', 'Астана', 'Шымкент', 'Караганда', 'Актобе'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showCityPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF3A3A3A),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.selectCityTitle,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ..._cities.map((city) => ListTile(
                  title: Text(
                    city,
                    style: TextStyle(
                      color: city == _city
                          ? AppTheme.accent
                          : AppTheme.textPrimary,
                      fontWeight: city == _city
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  trailing: city == _city
                      ? const Icon(Icons.check, color: AppTheme.accent)
                      : null,
                  onTap: () {
                    setState(() => _city = city);
                    Navigator.pop(ctx);
                  },
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.emailRegister(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
      phone: _phone.isNotEmpty ? _phone : null,
      city: _city,
    );

    if (success && mounted) {
      context.read<PushNotificationService>().registerToken();
      auth.acceptTerms();
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
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
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
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
                        icon: const Icon(Icons.arrow_back,
                            color: AppTheme.textPrimary, size: 20),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Title
                    Text(
                      AppLocalizations.of(context)!.registrationTitle,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.createAccountToContinue,
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Name field
                    Text(
                      AppLocalizations.of(context)!.fullName,
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      style: const TextStyle(
                          color: AppTheme.textPrimary, fontSize: 16),
                      decoration: _inputDecoration(AppLocalizations.of(context)!.fullNamePlaceholder),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppLocalizations.of(context)!.enterFullName;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email field
                    const Text(
                      'Email',
                      style:
                          TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      style: const TextStyle(
                          color: AppTheme.textPrimary, fontSize: 16),
                      decoration: _inputDecoration('example@mail.com'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppLocalizations.of(context)!.enterEmail;
                        }
                        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                            .hasMatch(value.trim())) {
                          return AppLocalizations.of(context)!.enterValidEmail;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Phone field
                    Text(
                      AppLocalizations.of(context)!.phoneLabel,
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    IntlPhoneField(
                      decoration: _inputDecoration(''),
                      initialCountryCode: 'KZ',
                      languageCode: 'ru',
                      style: const TextStyle(
                          color: AppTheme.textPrimary, fontSize: 16),
                      dropdownTextStyle: const TextStyle(
                          color: AppTheme.textPrimary, fontSize: 16),
                      dropdownIcon: const Icon(Icons.arrow_drop_down, color: AppTheme.textSecondary),
                      flagsButtonPadding: const EdgeInsets.only(left: 12),
                      disableLengthCheck: false,
                      onChanged: (phone) {
                        _phone = phone.completeNumber;
                      },
                    ),
                    const SizedBox(height: 16),

                    // City field
                    Text(
                      AppLocalizations.of(context)!.cityLabel,
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _showCityPicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.card,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _city ?? AppLocalizations.of(context)!.selectCityTitle,
                                style: TextStyle(
                                  color: _city != null
                                      ? AppTheme.textPrimary
                                      : AppTheme.textSecondary.withValues(alpha: 0.5),
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: AppTheme.textSecondary,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password field
                    Text(
                      AppLocalizations.of(context)!.password,
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(
                          color: AppTheme.textPrimary, fontSize: 16),
                      decoration:
                          _inputDecoration(AppLocalizations.of(context)!.minSixChars).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppTheme.textSecondary,
                            size: 20,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.enterPasswordHint;
                        }
                        if (value.length < 6) {
                          return AppLocalizations.of(context)!.passwordMinLength;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Confirm password field
                    Text(
                      AppLocalizations.of(context)!.confirmPassword,
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirm,
                      style: const TextStyle(
                          color: AppTheme.textPrimary, fontSize: 16),
                      decoration:
                          _inputDecoration(AppLocalizations.of(context)!.repeatPassword).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppTheme.textSecondary,
                            size: 20,
                          ),
                          onPressed: () => setState(
                              () => _obscureConfirm = !_obscureConfirm),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.confirmPasswordHint;
                        }
                        if (value != _passwordController.text) {
                          return AppLocalizations.of(context)!.passwordsDontMatch;
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

                    // Register button
                    Consumer<AuthProvider>(
                      builder: (_, auth, __) {
                        return SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: auth.isLoading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              disabledBackgroundColor:
                                  AppTheme.accent.withValues(alpha: 0.3),
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
                                : Text(
                                    AppLocalizations.of(context)!.registerAction,
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

                    // Login link
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.alreadyHaveAccount,
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EmailLoginScreen(),
                              ),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.signInLink,
                              style: TextStyle(
                                color: AppTheme.accent,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppTheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppTheme.error),
      ),
    );
  }
}
