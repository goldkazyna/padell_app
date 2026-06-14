import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../models/club.dart';
import '../providers/court_provider.dart';
import '../providers/home_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_alert.dart';
import '../widgets/app_back_button.dart';
import '../widgets/secure_payment_badge.dart';
import 'booking_confirmation_screen.dart';
import 'club_detail_screen.dart';
import 'payment_webview_screen.dart';

class CourtBookingScreen extends StatefulWidget {
  final Club club;
  final int courtId;
  final String courtName;
  final String date;
  final String startTime;
  final double price;
  final List<dynamic> coaches;
  final List<dynamic> slots;
  final int slotIndex;

  const CourtBookingScreen({
    super.key,
    required this.club,
    required this.courtId,
    required this.courtName,
    required this.date,
    required this.startTime,
    required this.price,
    required this.coaches,
    required this.slots,
    required this.slotIndex,
  });

  @override
  State<CourtBookingScreen> createState() => _CourtBookingScreenState();
}

class _CourtBookingScreenState extends State<CourtBookingScreen> {
  int _selectedSlots = 1;
  int? _selectedCoachId;
  bool _needsCoach = false;
  final _commentController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isBooking = false;
  bool _initialized = false;
  bool _agreedToDocs = false;

  /// Тренеры с фото — только их показываем при выборе.
  List<dynamic> get _coachesWithPhoto => widget.coaches
      .where((c) => ((c['photo'] as String?) ?? '').isNotEmpty)
      .toList();

  int get _maxSlots {
    int count = 0;
    for (int i = widget.slotIndex; i < widget.slots.length; i++) {
      final s = widget.slots[i] as Map<String, dynamic>;
      if (s['status'] == 'free') {
        count++;
      } else {
        break;
      }
    }
    return count.clamp(1, 6);
  }

  double get _courtTotal {
    double total = 0;
    for (int i = 0; i < _selectedSlots && (widget.slotIndex + i) < widget.slots.length; i++) {
      final s = widget.slots[widget.slotIndex + i] as Map<String, dynamic>;
      total += (s['price'] as num?)?.toDouble() ?? widget.price;
    }
    return total;
  }

  double get _coachTotal {
    if (_selectedCoachId == null) return 0;
    final coach = widget.coaches.firstWhere(
      (c) => c['id'] == _selectedCoachId,
      orElse: () => null,
    );
    if (coach == null) return 0;

    final rates = coach['rates'] as Map<String, dynamic>? ?? {};
    final slotsKey = _selectedSlots.toString();
    double hourlyRate;
    if (rates.containsKey(slotsKey)) {
      hourlyRate = (rates[slotsKey] as num).toDouble();
    } else {
      hourlyRate = (coach['hourly_rate'] as num?)?.toDouble() ?? 0;
    }
    return hourlyRate * _selectedSlots;
  }

  double get _total => _courtTotal + _coachTotal;

  List<String> _localizedMonths(AppLocalizations l10n) => [
    '', l10n.challengeMonthJan, l10n.challengeMonthFeb, l10n.challengeMonthMar,
    l10n.challengeMonthApr, l10n.challengeMonthMay, l10n.challengeMonthJun,
    l10n.challengeMonthJul, l10n.challengeMonthAug, l10n.challengeMonthSep,
    l10n.challengeMonthOct, l10n.challengeMonthNov, l10n.challengeMonthDec,
  ];

  String _formatDate(String date, AppLocalizations l10n) {
    final parts = date.split('-');
    if (parts.length != 3) return date;
    final months = _localizedMonths(l10n);
    final day = int.tryParse(parts[2]) ?? 0;
    final month = int.tryParse(parts[1]) ?? 0;
    return '$day ${months[month]} ${parts[0]}';
  }

  String _fmtPrice(double p) {
    return p.toInt().toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]} ');
  }

  bool _isCoachAvailable(Map<String, dynamic> coach) {
    final avail = coach['availability'] as Map<String, dynamic>? ?? {};
    // Проверяем все выбранные слоты
    for (int i = 0; i < _selectedSlots && (widget.slotIndex + i) < widget.slots.length; i++) {
      final slot = widget.slots[widget.slotIndex + i] as Map<String, dynamic>;
      final time = slot['time'] as String? ?? '';
      if (avail[time] != true) return false;
    }
    return true;
  }

  Future<void> _book() async {
    setState(() => _isBooking = true);

    final provider = context.read<CourtProvider>();
    final result = await provider.book(
      clubId: widget.club.id,
      courtId: widget.courtId,
      date: widget.date,
      startTime: widget.startTime,
      slots: _selectedSlots,
      clientName: _nameController.text.isNotEmpty ? _nameController.text : null,
      clientPhone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
      coachId: _selectedCoachId,
      comment: _commentController.text.isNotEmpty ? _commentController.text : null,
      // «Нужен тренер» без конкретного выбора — клуб подберёт сам.
      needsCoach: _needsCoach && _selectedCoachId == null,
    );

    setState(() => _isBooking = false);

    if (!mounted) return;

    if (result['success'] == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BookingConfirmationScreen(
            booking: result['booking'] as Map<String, dynamic>? ?? {},
            clubName: widget.club.name,
          ),
        ),
      );
    } else {
      showAppAlert(
        context,
        result['message'] as String? ?? AppLocalizations.of(context)!.bookingError,
        title: 'Ошибка',
        isError: true,
      );
    }
  }

  String _formatPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isNotEmpty && !digits.startsWith('+')) {
      return '+$digits';
    }
    return phone.startsWith('+') ? phone : '+$phone';
  }

  @override
  void dispose() {
    _commentController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<HomeProvider>().user;
    if (!_initialized && user != null) {
      _nameController.text = user.name;
      _phoneController.text = _formatPhone(user.phone);
      _initialized = true;
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 12),
          child: Center(child: AppBackButton()),
        ),
        title: Text(AppLocalizations.of(context)!.booking,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Сводка
            _buildSummaryCard(),
            const SizedBox(height: 20),

            // Длительность
            _sectionLabel(AppLocalizations.of(context)!.duration),
            const SizedBox(height: 8),
            _buildDurationButtons(),
            const SizedBox(height: 16),

            // Итого
            _buildTotalBlock(),
            const SizedBox(height: 20),

            // Тренер
            _buildCoachSectionHeader(),
            const SizedBox(height: 8),
            _buildNeedsCoachButton(),
            if (_needsCoach) ...[
              if (_coachesWithPhoto.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildCoachGrid(),
              ] else ...[
                const SizedBox(height: 10),
                _buildClubContactHint(),
              ],
            ],
            const SizedBox(height: 20),

            // Имя
            _sectionLabel(AppLocalizations.of(context)!.yourName),
            const SizedBox(height: 8),
            _buildInput(_nameController, AppLocalizations.of(context)!.enterName),
            const SizedBox(height: 14),

            // Телефон
            _sectionLabel(AppLocalizations.of(context)!.phone),
            const SizedBox(height: 8),
            _buildInput(_phoneController, '+7 777 123 4567'),
            const SizedBox(height: 16),

            // Комментарий
            _sectionLabel(AppLocalizations.of(context)!.comment),
            const SizedBox(height: 8),
            _buildCommentField(),
            const SizedBox(height: 24),

            // Кнопка
            _buildBookButton(),
            if (widget.club.onlinePaymentEnabled) ...[
              const SizedBox(height: 14),
              _buildDocsAgreement(),
              const SizedBox(height: 20),
              const SecurePaymentBadge(),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0xFF71717A),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
      ),
      child: Column(
        children: [
          _summaryRow(AppLocalizations.of(context)!.summaryClub, widget.club.name),
          _summaryRow(AppLocalizations.of(context)!.summaryCourt, widget.courtName),
          _summaryRow(AppLocalizations.of(context)!.summaryDate, _formatDate(widget.date, AppLocalizations.of(context)!)),
          _summaryRow(AppLocalizations.of(context)!.summaryStart, widget.startTime),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF71717A), fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildDurationButtons() {
    final max = _maxSlots;
    return Row(
      children: List.generate(max, (i) {
        final n = i + 1;
        final isActive = n == _selectedSlots;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedSlots = n;
                // Сбросить тренера если он недоступен на новое кол-во слотов
                if (_selectedCoachId != null) {
                  final coach = widget.coaches.firstWhere(
                    (c) => c['id'] == _selectedCoachId,
                    orElse: () => null,
                  );
                  if (coach != null && !_isCoachAvailable(coach)) {
                    _selectedCoachId = null;
                  }
                }
              });
            },
            child: Container(
              margin: EdgeInsets.only(left: i > 0 ? 6 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isActive ? AppTheme.accent : AppTheme.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isActive ? AppTheme.accent : const Color(0xFF2A2A2A),
                  width: 0.5,
                ),
              ),
              child: Center(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$n ',
                        style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800,
                          color: isActive ? Colors.black : const Color(0xFFD4D4D8),
                        ),
                      ),
                      TextSpan(
                        text: _hourLabel(n, AppLocalizations.of(context)!),
                        style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600,
                          color: isActive ? Colors.black.withAlpha(180) : const Color(0xFF71717A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  String _hourLabel(int n, AppLocalizations l10n) {
    if (n == 1) return l10n.hourOne;
    if (n >= 2 && n <= 4) return l10n.hourFew;
    return l10n.hourMany;
  }

  Widget _buildTotalBlock() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.accent.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accent.withAlpha(50), width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.summaryTotal, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFA1A1AA))),
              if (_selectedCoachId != null)
                Text(
                  AppLocalizations.of(context)!.courtPriceBreakdown(_fmtPrice(_courtTotal), _fmtPrice(_coachTotal)),
                  style: const TextStyle(fontSize: 10, color: Color(0xFF71717A)),
                ),
            ],
          ),
          Text(
            '${_fmtPrice(_total)} ₸',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.accent),
          ),
        ],
      ),
    );
  }

  /// Тумблер «Нужен тренер». Включение раскрывает выбор тренеров (если есть).
  Widget _buildNeedsCoachButton() {
    final hasCoaches = _coachesWithPhoto.isNotEmpty;
    final subtitle = !_needsCoach
        ? 'Игра без тренера'
        : (hasCoaches
            ? 'Выберите тренера из списка'
            : 'Клуб свяжется с вами и подберёт тренера');

    void toggle(bool v) => setState(() {
          _needsCoach = v;
          if (!_needsCoach) _selectedCoachId = null;
        });

    return GestureDetector(
      onTap: () => toggle(!_needsCoach),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        decoration: BoxDecoration(
          color: _needsCoach ? AppTheme.accent.withAlpha(20) : AppTheme.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _needsCoach ? AppTheme.accent.withAlpha(100) : AppTheme.border,
            width: _needsCoach ? 1 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Нужен тренер',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: AppTheme.textDim),
                  ),
                ],
              ),
            ),
            Switch(
              value: _needsCoach,
              onChanged: toggle,
              activeThumbColor: Colors.white,
              activeTrackColor: AppTheme.accent,
            ),
          ],
        ),
      ),
    );
  }

  /// Заголовок секции «ТРЕНЕР» + тихая ссылка «Наши тренера ›» справа.
  Widget _buildCoachSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _sectionLabel('ТРЕНЕР'),
        if (_coachesWithPhoto.isNotEmpty)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ClubDetailScreen(
                    clubId: widget.club.id,
                    initialShowCoaches: true,
                  ),
                ),
              );
            },
            behavior: HitTestBehavior.opaque,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Наши тренера',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
                Icon(Icons.chevron_right, color: AppTheme.textSecondary, size: 16),
              ],
            ),
          ),
      ],
    );
  }

  /// Подсказка, когда у клуба нет заведённых тренеров.
  Widget _buildClubContactHint() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: AppTheme.textSecondary, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Клуб подберёт тренера и свяжется с вами для подтверждения.',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  /// Лента тренеров — горизонтальный скролл (свайп).
  Widget _buildCoachGrid() {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        physics: const BouncingScrollPhysics(),
        itemCount: _coachesWithPhoto.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) => SizedBox(
          width: 136,
          child: _buildCoachGridCard(_coachesWithPhoto[i] as Map<String, dynamic>),
        ),
      ),
    );
  }

  Widget _buildCoachGridCard(Map<String, dynamic> coach) {
    final id = coach['id'] as int;
    final name = coach['name'] as String? ?? '';
    final rate = (coach['hourly_rate'] as num?)?.toDouble() ?? 0;
    final photo = coach['photo'] as String?;
    final isSelected = _selectedCoachId == id;
    final isAvailable = _isCoachAvailable(coach);

    return GestureDetector(
      onTap: () {
        if (!isAvailable) return;
        setState(() => _selectedCoachId = isSelected ? null : id);
      },
      child: Opacity(
        opacity: isAvailable ? 1.0 : 0.35,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.accent.withAlpha(24) : AppTheme.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppTheme.accent : const Color(0xFF2A2A2A),
              width: isSelected ? 1.5 : 0.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Фото — квадратное, заглушка с инициалами при отсутствии
              SizedBox(
                width: 120,
                height: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    color: _coachColor(id),
                    child: (photo != null && photo.isNotEmpty)
                        ? Image.network(
                            photo,
                            fit: BoxFit.cover,
                            width: 120,
                            height: 120,
                            errorBuilder: (ctx, err, stack) => _coachInitials(name),
                          )
                        : _coachInitials(name),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  color: isSelected ? AppTheme.accent : AppTheme.textPrimary,
                  decoration: isAvailable ? null : TextDecoration.lineThrough,
                ),
              ),
              if (rate > 0) ...[
                const SizedBox(height: 3),
                Text(
                  '${_fmtPrice(rate)} ₸',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _coachInitials(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    final initials = words.length >= 2
        ? '${words[0][0]}${words[1][0]}'
        : (name.length >= 2 ? name.substring(0, 2) : name);
    return Center(
      child: Text(
        initials.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 34,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Color _coachColor(int id) {
    const palette = [
      Color(0xFF4A8BF5), Color(0xFFA89CF5), Color(0xFFEC4899),
      Color(0xFFF59E0B), Color(0xFF22C47A), Color(0xFF06B6D4),
    ];
    return palette[id % palette.length];
  }

  Widget _buildInput(TextEditingController controller, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF52525B), fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildCommentField() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
      ),
      child: TextField(
        controller: _commentController,
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
        maxLines: 2,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.optional,
          hintStyle: const TextStyle(color: Color(0xFF52525B), fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
        ),
      ),
    );
  }

  Widget _buildBookButton() {
    final l10n = AppLocalizations.of(context)!;

    // Клуб с онлайн-оплатой — две кнопки: оплатить онлайн (пока заглушка)
    // и забронировать без оплаты (обычная бронь). Кнопка онлайн-оплаты
    // неактивна, пока не отмечено согласие с документами (если они есть).
    if (widget.club.onlinePaymentEnabled) {
      final hasDocs = _docLinks(l10n).isNotEmpty;
      final canPayOnline = !hasDocs || _agreedToDocs;
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: (_isBooking || !canPayOnline) ? null : _payOnline,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: canPayOnline
                      ? AppTheme.accent
                      : AppTheme.accent.withAlpha(70),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: canPayOnline
                      ? [
                          BoxShadow(
                            color: AppTheme.accent.withAlpha(50),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    l10n.payOnlineButton(_fmtPrice(_total)),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: canPayOnline
                          ? Colors.black
                          : Colors.black.withAlpha(120),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (widget.club.allowBookingWithoutPayment) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: _isBooking ? null : _book,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.accent.withAlpha(120)),
                ),
                child: Center(
                  child: _isBooking
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(
                              color: AppTheme.accent, strokeWidth: 2.5))
                      : Text(
                          l10n.bookWithoutPaymentButton,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.accent,
                          ),
                        ),
                ),
              ),
            ),
          ),
          ],
        ],
      );
    }

    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: _isBooking ? null : _book,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: _isBooking ? AppTheme.accent.withAlpha(150) : AppTheme.accent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppTheme.accent.withAlpha(50),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: _isBooking
                ? const SizedBox(
                    width: 22, height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.black, strokeWidth: 2.5))
                : Text(
                    l10n.bookButton(_fmtPrice(_total)),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _payOnline() async {
    setState(() => _isBooking = true);
    final provider = context.read<CourtProvider>();

    // 1. Создаём бронь (та же логика, что при «Записаться без оплаты»).
    final result = await provider.book(
      clubId: widget.club.id,
      courtId: widget.courtId,
      date: widget.date,
      startTime: widget.startTime,
      slots: _selectedSlots,
      clientName: _nameController.text.isNotEmpty ? _nameController.text : null,
      clientPhone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
      coachId: _selectedCoachId,
      comment: _commentController.text.isNotEmpty ? _commentController.text : null,
      needsCoach: _needsCoach && _selectedCoachId == null,
    );

    if (!mounted) return;
    if (result['success'] != true) {
      setState(() => _isBooking = false);
      showAppAlert(
        context,
        result['message'] as String? ?? AppLocalizations.of(context)!.bookingError,
        title: 'Ошибка',
        isError: true,
      );
      return;
    }

    final booking = result['booking'] as Map<String, dynamic>? ?? {};
    final bookingId = booking['id'] is num ? (booking['id'] as num).toInt() : null;

    // 2. Создаём платёж в Plexy и открываем ссылку оплаты.
    final pay = bookingId != null
        ? await provider.createPayment(bookingId)
        : {'success': false, 'message': 'Не удалось определить бронь'};

    if (!mounted) return;
    setState(() => _isBooking = false);

    final url = pay['payment_url'] as String?;
    if (pay['success'] == true && url != null && url.isNotEmpty && bookingId != null) {
      // Открываем оплату внутри приложения (WebView). Экран сам закроется,
      // когда вебхук пометит бронь оплаченной (опрос статуса).
      await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentWebViewScreen(url: url, bookingId: bookingId),
        ),
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BookingConfirmationScreen(
            booking: booking,
            clubName: widget.club.name,
          ),
        ),
      );
    } else {
      // Бронь создана, но оплату открыть не удалось — показываем бронь
      // и сообщение (оплатить можно на месте / повторить позже).
      showAppAlert(
        context,
        pay['message'] as String? ??
            'Бронь создана, но не удалось открыть оплату. Оплатите на месте или попробуйте позже.',
        title: 'Оплата',
        isError: true,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BookingConfirmationScreen(
            booking: booking,
            clubName: widget.club.name,
          ),
        ),
      );
    }
  }

  /// Доступные документы клуба (название → URL), только загруженные.
  List<MapEntry<String, String>> _docLinks(AppLocalizations l10n) {
    final c = widget.club;
    return [
      if ((c.offerAgreementUrl ?? '').isNotEmpty)
        MapEntry(l10n.docOfferAgreement, c.offerAgreementUrl!),
      if ((c.privacyPolicyUrl ?? '').isNotEmpty)
        MapEntry(l10n.docPrivacyPolicy, c.privacyPolicyUrl!),
      if ((c.goodsDescriptionUrl ?? '').isNotEmpty)
        MapEntry(l10n.docGoodsDescription, c.goodsDescriptionUrl!),
      if ((c.cardPaymentDescriptionUrl ?? '').isNotEmpty)
        MapEntry(l10n.docCardPayment, c.cardPaymentDescriptionUrl!),
    ];
  }

  Widget _buildDocsAgreement() {
    final l10n = AppLocalizations.of(context)!;
    final docs = _docLinks(l10n);
    if (docs.isEmpty) return const SizedBox.shrink();

    final spans = <Widget>[
      Text(
        l10n.agreeWithDocsPrefix,
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
      ),
    ];
    for (var i = 0; i < docs.length; i++) {
      spans.add(GestureDetector(
        onTap: () => _openDoc(docs[i].value),
        child: Text(
          docs[i].key,
          style: const TextStyle(
            color: AppTheme.accent,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
            decorationColor: AppTheme.accent,
          ),
        ),
      ));
      if (i < docs.length - 1) {
        spans.add(const Text(', ',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)));
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _agreedToDocs,
            onChanged: (v) => setState(() => _agreedToDocs = v ?? false),
            activeColor: AppTheme.accent,
            checkColor: Colors.black,
            side: const BorderSide(color: AppTheme.textSecondary, width: 1.5),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Wrap(runSpacing: 2, children: spans),
          ),
        ),
      ],
    );
  }

  Future<void> _openDoc(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
