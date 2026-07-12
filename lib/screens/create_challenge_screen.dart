import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/challenge_provider.dart';
import '../providers/auth_provider.dart';
import '../models/challenge.dart';
import '../widgets/app_back_button.dart';
import '../widgets/challenges/court_widget.dart';
import '../l10n/app_localizations.dart';

class CreateChallengeScreen extends StatefulWidget {
  const CreateChallengeScreen({super.key});

  @override
  State<CreateChallengeScreen> createState() => _CreateChallengeScreenState();
}

class _CreateChallengeScreenState extends State<CreateChallengeScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedType = 'rated';
  double _minLevel = 1.0;
  double _maxLevel = 5.0;
  int _myPosition = 1;

  // Club selection
  List<Map<String, dynamic>> _clubs = [];
  int? _selectedClubId;
  bool _loadingClubs = false;

  // Invites
  final Map<int, Map<String, dynamic>> _invites = {};
  final List<ChallengePlayer> _courtPlayers = [];

  bool _isCreating = false;

  static const List<double> _levelValues = [1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadClubs();
      _rebuildCourtPlayers();
      setState(() {});
    });
  }

  Future<void> _loadClubs() async {
    setState(() => _loadingClubs = true);
    try {
      final clubs = await context.read<ChallengeProvider>().getClubs();
      if (mounted) {
        setState(() {
          _clubs = clubs;
          _loadingClubs = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingClubs = false);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppTheme.accent,
            surface: AppTheme.card,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 18, minute: 0),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppTheme.accent,
            surface: AppTheme.card,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _onPositionTap(int position) {
    // Position 1 is always the creator — skip
    if (position == _myPosition) return;
    _showInviteBottomSheet(position);
  }

  void _showInviteBottomSheet(int position) {
    final phoneController = TextEditingController();
    List<Map<String, dynamic>> foundPlayers = [];
    bool isSearching = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16, 20, 16,
                MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.challengeAddPlayer,
                    style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.challengePositionTeam(position, position <= 2 ? AppLocalizations.of(context)!.challengeTeamA : AppLocalizations.of(context)!.challengeTeamB),
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.challengePhoneHint,
                      hintStyle: TextStyle(color: AppTheme.textSecondary),
                      filled: true,
                      fillColor: AppTheme.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: isSearching
                            ? const SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accent),
                              )
                            : const Icon(Icons.search, color: AppTheme.accent),
                        onPressed: isSearching
                            ? null
                            : () async {
                                final phone = phoneController.text.trim();
                                if (phone.isEmpty) return;
                                setSheetState(() => isSearching = true);
                                final results = await context.read<ChallengeProvider>().searchPlayers(phone);
                                setSheetState(() {
                                  isSearching = false;
                                  foundPlayers = results;
                                });
                              },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Results list
                  if (foundPlayers.isNotEmpty) ...[
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.3),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: foundPlayers.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final player = foundPlayers[i];
                          final playerId = player['id'] as int?;
                          final alreadyAdded = _invites.values.any((inv) => inv['id'] == playerId) ||
                              _courtPlayers.any((cp) => cp.id == playerId);
                          return GestureDetector(
                            onTap: alreadyAdded ? null : () {
                              setState(() {
                                _invites[position] = {
                                  'phone': player['phone'] ?? phoneController.text.trim(),
                                  ...player,
                                };
                                _rebuildCourtPlayers();
                              });
                              Navigator.pop(ctx);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.background,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40, height: 40,
                                    decoration: BoxDecoration(
                                      color: AppTheme.accent,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      _getInitials(player['first_name'] ?? '', player['last_name'] ?? ''),
                                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          player['full_name'] ?? '',
                                          style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                                          maxLines: 1, overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${player['rating'] ?? 0} ELO · ${player['phone'] ?? ''}',
                                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                                          maxLines: 1, overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  alreadyAdded
                                      ? Icon(Icons.check_circle, color: AppTheme.textSecondary, size: 22)
                                      : const Icon(Icons.add_circle_outline, color: AppTheme.accent, size: 22),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                  ] else if (!isSearching && phoneController.text.trim().isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(AppLocalizations.of(context)!.challengeNobodyFound, style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    ),
                  ],
                  // Open slot button
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _invites.remove(position);
                        _rebuildCourtPlayers();
                      });
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.accent, width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        AppLocalizations.of(context)!.challengeLeaveOpen,
                        style: const TextStyle(color: AppTheme.accent, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _getInitials(String firstName, String lastName) {
    final f = firstName.isNotEmpty ? firstName[0] : '';
    final l = lastName.isNotEmpty ? lastName[0] : '';
    return '$f$l'.toUpperCase();
  }

  void _rebuildCourtPlayers() {
    _courtPlayers.clear();

    // Add creator at position 1
    try {
      final auth = context.read<AuthProvider>();
      final user = auth.user;
      final name = user?.name ?? '';
      final parts = name.trim().split(RegExp(r'\s+'));
      final firstName = parts.isNotEmpty ? parts[0] : '';
      final lastName = parts.length > 1 ? parts[1] : '';
      _courtPlayers.add(ChallengePlayer(
        id: user?.id ?? 0,
        position: _myPosition,
        status: 'confirmed',
        firstName: firstName,
        lastName: lastName,
        fullName: name.isNotEmpty ? name : AppLocalizations.of(context)!.challengeYou,
        rating: user?.rating ?? 0,
        level: double.tryParse(user?.level ?? '0') ?? 0.0,
        isMe: true,
      ));
    } catch (_) {
      _courtPlayers.add(ChallengePlayer(
        id: 0,
        position: _myPosition,
        status: 'confirmed',
        firstName: AppLocalizations.of(context)!.challengeYou,
        lastName: '',
        fullName: AppLocalizations.of(context)!.challengeYou,
        rating: 0,
        level: 0,
        isMe: true,
      ));
    }

    // Add invites
    for (final entry in _invites.entries) {
      _courtPlayers.add(ChallengePlayer(
        id: entry.value['id'] as int? ?? 0,
        position: entry.key,
        status: 'invited',
        firstName: entry.value['first_name'] as String? ?? '',
        lastName: entry.value['last_name'] as String? ?? '',
        fullName: '${entry.value['first_name'] ?? ''} ${entry.value['last_name'] ?? ''}',
        rating: entry.value['rating'] as int? ?? 0,
        level: (entry.value['level'] as num?)?.toDouble() ?? 0.0,
      ));
    }
  }

  Future<void> _create() async {
    if (_selectedDate == null || _selectedTime == null) {
      _showAlert(AppLocalizations.of(context)!.challengeSpecifyDateTime, isError: true);
      return;
    }

    setState(() => _isCreating = true);

    final scheduledAt = DateTime(
      _selectedDate!.year, _selectedDate!.month, _selectedDate!.day,
      _selectedTime!.hour, _selectedTime!.minute,
    );

    final data = <String, dynamic>{
      'scheduled_at': scheduledAt.toIso8601String(),
      'type': _selectedType,
      'min_level': _minLevel,
      'max_level': _maxLevel,
      'position': _myPosition,
    };

    if (_selectedClubId != null) {
      data['club_id'] = _selectedClubId;
    }

    final inviteList = <Map<String, dynamic>>[];
    for (final entry in _invites.entries) {
      inviteList.add({
        'phone': entry.value['phone'],
        'position': entry.key,
      });
    }
    if (inviteList.isNotEmpty) {
      data['invites'] = inviteList;
    }

    final result = await context.read<ChallengeProvider>().createChallenge(data);

    if (!mounted) return;
    setState(() => _isCreating = false);

    if (result.success) {
      Navigator.pop(context);
    } else {
      _showAlert(result.message, isError: true);
    }
  }

  void _showAlert(String message, {bool isError = false}) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isError ? AppLocalizations.of(context)!.challengeErrorTitle : AppLocalizations.of(context)!.challengeDoneTitle,
          style: TextStyle(
            color: isError ? AppTheme.error : AppTheme.accent,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK', style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final months = [
      l10n.challengeMonthJan, l10n.challengeMonthFeb, l10n.challengeMonthMar,
      l10n.challengeMonthApr, l10n.challengeMonthMay, l10n.challengeMonthJun,
      l10n.challengeMonthJul, l10n.challengeMonthAug, l10n.challengeMonthSep,
      l10n.challengeMonthOct, l10n.challengeMonthNov, l10n.challengeMonthDec,
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  String _formatTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  const AppBackButton(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.challengeNewTitle,
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Form
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date & Time
                    Row(
                      children: [
                        Expanded(child: _buildPickerField(
                          icon: Icons.calendar_today,
                          label: _selectedDate != null ? _formatDate(_selectedDate!) : AppLocalizations.of(context)!.challengeDatePlaceholder,
                          onTap: _pickDate,
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: _buildPickerField(
                          icon: Icons.access_time,
                          label: _selectedTime != null ? _formatTime(_selectedTime!) : AppLocalizations.of(context)!.challengeTimePlaceholder,
                          onTap: _pickTime,
                        )),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Club dropdown
                    _buildClubDropdown(),
                    const SizedBox(height: 16),

                    // Type
                    Text(AppLocalizations.of(context)!.challengeType, style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _buildTypeChip(label: AppLocalizations.of(context)!.challengeRated, value: 'rated')),
                        const SizedBox(width: 12),
                        Expanded(child: _buildTypeChip(label: AppLocalizations.of(context)!.challengeFriendly, value: 'friendly')),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Min level
                    Text(AppLocalizations.of(context)!.challengeMinLevel, style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    const SizedBox(height: 8),
                    _buildLevelButtons(
                      selected: _minLevel,
                      onSelect: (v) {
                        setState(() {
                          _minLevel = v;
                          if (_maxLevel < v) _maxLevel = v;
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    // Max level
                    Text(AppLocalizations.of(context)!.challengeMaxLevel, style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    const SizedBox(height: 8),
                    _buildLevelButtons(
                      selected: _maxLevel,
                      minEnabled: _minLevel,
                      onSelect: (v) {
                        setState(() => _maxLevel = v);
                      },
                    ),
                    const SizedBox(height: 24),

                    // Court
                    Text(
                      AppLocalizations.of(context)!.challengeCourtLayout,
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 12),
                    CourtWidget(
                      players: _courtPlayers,
                      status: 'open',
                      myUserId: null,
                      isEditing: true,
                      onPositionTap: _onPositionTap,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            // Create button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: GestureDetector(
                onTap: _isCreating ? null : _create,
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _isCreating ? AppTheme.accent.withAlpha(128) : AppTheme.accent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: _isCreating
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : Text(
                          AppLocalizations.of(context)!.challengeCreateButton,
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerField({required IconData icon, required String label, required VoidCallback onTap}) {
    final l10n = AppLocalizations.of(context)!;
    final isPlaceholder = label == l10n.challengeDatePlaceholder || label == l10n.challengeTimePlaceholder;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.textSecondary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isPlaceholder ? AppTheme.textSecondary : AppTheme.textPrimary,
                  fontSize: 14,
                ),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClubDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: _selectedClubId,
          isExpanded: true,
          dropdownColor: AppTheme.card,
          hint: Row(
            children: [
              Icon(Icons.location_on, color: AppTheme.textSecondary, size: 20),
              const SizedBox(width: 10),
              Text(
                _loadingClubs ? AppLocalizations.of(context)!.challengeLoadingClubs : AppLocalizations.of(context)!.challengeClubOptional,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
            ],
          ),
          icon: Icon(Icons.keyboard_arrow_down, color: AppTheme.textSecondary),
          items: [
            DropdownMenuItem<int?>(
              value: null,
              child: Text(AppLocalizations.of(context)!.challengeNoClub, style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
            ),
            ..._clubs.map((c) => DropdownMenuItem<int?>(
              value: c['id'] as int,
              child: Text(
                c['name'] as String,
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
            )),
          ],
          onChanged: (v) => setState(() => _selectedClubId = v),
        ),
      ),
    );
  }

  Widget _buildTypeChip({required String label, required String value}) {
    final isSelected = _selectedType == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = value),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accent.withAlpha(25) : AppTheme.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.accent : const Color(0xFF2A2A2A),
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.accent : AppTheme.textSecondary,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildLevelButtons({required double selected, double minEnabled = 1.0, required ValueChanged<double> onSelect}) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _levelValues.map((level) {
        final isSelected = level == selected;
        final isDisabled = level < minEnabled;
        return GestureDetector(
          onTap: isDisabled ? null : () => onSelect(level),
          child: Container(
            width: 52,
            height: 36,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.accent.withAlpha(25)
                  : isDisabled
                      ? const Color(0xFF151515)
                      : AppTheme.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? AppTheme.accent
                    : isDisabled
                        ? const Color(0xFF1E1E1E)
                        : const Color(0xFF2A2A2A),
                width: isSelected ? 1.5 : 0.5,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              level == level.truncateToDouble()
                  ? '${level.toInt()}.0'
                  : level.toStringAsFixed(1),
              style: TextStyle(
                color: isSelected
                    ? AppTheme.accent
                    : isDisabled
                        ? const Color(0xFF444444)
                        : AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
