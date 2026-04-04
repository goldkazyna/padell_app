import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/club.dart';
import '../providers/court_provider.dart';
import '../providers/home_provider.dart';
import '../theme/app_theme.dart';
import 'booking_confirmation_screen.dart';

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
  final _commentController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isBooking = false;
  bool _initialized = false;

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] as String? ?? AppLocalizations.of(context)!.bookingError),
          backgroundColor: AppTheme.error,
        ),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
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
            if (widget.coaches.isNotEmpty) ...[
              _sectionLabel(AppLocalizations.of(context)!.coachOptional),
              const SizedBox(height: 8),
              _buildCoachChips(),
              const SizedBox(height: 20),
            ],

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

  Widget _buildCoachChips() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: widget.coaches.map((coach) {
        final id = coach['id'] as int;
        final name = coach['name'] as String? ?? '';
        final rate = (coach['hourly_rate'] as num?)?.toDouble() ?? 0;
        final isSelected = _selectedCoachId == id;
        final isAvailable = _isCoachAvailable(coach);

        return GestureDetector(
          onTap: () {
            if (!isAvailable) return;
            setState(() {
              _selectedCoachId = isSelected ? null : id;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFA78BFA)
                  : AppTheme.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFA78BFA)
                    : const Color(0xFF2A2A2A),
                width: 0.5,
              ),
            ),
            child: Opacity(
              opacity: isAvailable ? 1.0 : 0.3,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.black : AppTheme.textSecondary,
                      decoration: isAvailable ? null : TextDecoration.lineThrough,
                    ),
                  ),
                  if (rate > 0) ...[
                    const SizedBox(width: 4),
                    Text(
                      '${_fmtPrice(rate)} ₸',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.black.withAlpha(180) : AppTheme.accent,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
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
                    AppLocalizations.of(context)!.bookButton(_fmtPrice(_total)),
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
}
