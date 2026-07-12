import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_back_button.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final _apiService = ApiService();
  final _storageService = StorageService();

  bool _notifyOnlyMyLevel = false;
  bool _notifyReminders = true;
  bool _notifyOrganizerChat = true;
  List<int>? _notifyClubIds; // null = все клубы
  List<Map<String, dynamic>> _clubs = [];
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await _storageService.getToken();
      final response = await _apiService.get('/notifications/settings', token);
      setState(() {
        _notifyOnlyMyLevel = response['notify_only_my_level'] == true;
        _notifyReminders = response['notify_tournament_reminders'] != false;
        _notifyOrganizerChat = response['notify_organizer_chat'] != false;
        _notifyClubIds = response['notify_club_ids'] != null
            ? List<int>.from(response['notify_club_ids'])
            : null;
        _clubs = List<Map<String, dynamic>>.from(response['clubs'] ?? []);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'error';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateSetting(bool value) async {
    final oldValue = _notifyOnlyMyLevel;
    setState(() {
      _notifyOnlyMyLevel = value;
      _isSaving = true;
    });

    try {
      final token = await _storageService.getToken();
      await _apiService.post(
        '/notifications/settings',
        {'notify_only_my_level': value},
        token,
      );
      setState(() => _isSaving = false);
    } catch (e) {
      setState(() {
        _notifyOnlyMyLevel = oldValue;
        _isSaving = false;
      });
    }
  }

  Future<void> _updateReminders(bool value) async {
    final old = _notifyReminders;
    setState(() {
      _notifyReminders = value;
      _isSaving = true;
    });
    try {
      final token = await _storageService.getToken();
      await _apiService.post(
        '/notifications/settings',
        {'notify_tournament_reminders': value},
        token,
      );
      setState(() => _isSaving = false);
    } catch (e) {
      setState(() {
        _notifyReminders = old;
        _isSaving = false;
      });
    }
  }

  Future<void> _updateOrganizerChat(bool value) async {
    final old = _notifyOrganizerChat;
    setState(() {
      _notifyOrganizerChat = value;
      _isSaving = true;
    });
    try {
      final token = await _storageService.getToken();
      await _apiService.post(
        '/notifications/settings',
        {'notify_organizer_chat': value},
        token,
      );
      setState(() => _isSaving = false);
    } catch (e) {
      setState(() {
        _notifyOrganizerChat = old;
        _isSaving = false;
      });
    }
  }

  Future<void> _toggleClub(int clubId) async {
    final oldIds = _notifyClubIds != null ? List<int>.from(_notifyClubIds!) : null;

    setState(() {
      if (_notifyClubIds == null) {
        // Было "все клубы" → снимаем один = все кроме него
        _notifyClubIds = _clubs
            .map((c) => c['id'] as int)
            .where((id) => id != clubId)
            .toList();
      } else if (_notifyClubIds!.contains(clubId)) {
        _notifyClubIds!.remove(clubId);
        // Если сняли все — возвращаем null (все клубы)
        if (_notifyClubIds!.isEmpty) {
          _notifyClubIds = null;
        }
      } else {
        _notifyClubIds!.add(clubId);
        // Если выбрали все — null (все клубы)
        if (_notifyClubIds!.length == _clubs.length) {
          _notifyClubIds = null;
        }
      }
    });

    try {
      final token = await _storageService.getToken();
      await _apiService.post(
        '/notifications/settings',
        {'notify_club_ids': _notifyClubIds},
        token,
      );
    } catch (e) {
      setState(() => _notifyClubIds = oldIds);
    }
  }

  bool _isClubSelected(int clubId) {
    return _notifyClubIds == null || _notifyClubIds!.contains(clubId);
  }

  Widget _buildClubRow(Map<String, dynamic> club) {
    final clubId = club['id'] as int;
    final clubName = club['name'] as String;
    final clubLogo = club['logo'] as String?;
    final selected = _isClubSelected(clubId);

    return GestureDetector(
      onTap: () => _toggleClub(clubId),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // Logo / initials
            if (clubLogo != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  clubLogo,
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildClubInitials(clubName),
                ),
              )
            else
              _buildClubInitials(clubName),
            const SizedBox(width: 12),
            // Name
            Expanded(
              child: Text(
                clubName,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Checkbox
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: selected ? AppTheme.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: selected ? AppTheme.accent : const Color(0xFF3A3A3A),
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.black, size: 16)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClubInitials(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    final initials = words.length >= 2
        ? '${words[0][0]}${words[1][0]}'.toUpperCase()
        : name.length >= 2
            ? name.substring(0, 2).toUpperCase()
            : name.toUpperCase();

    final hash = name.hashCode;
    const colors = [
      Color(0xFFFF9F0A),
      Color(0xFFBF5AF2),
      Color(0xFF0A84FF),
      Color(0xFF30D5C8),
      Color(0xFFFF375F),
      Color(0xFF32D74B),
    ];
    final color = colors[hash.abs() % colors.length];

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withAlpha(180)],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const AppBackButton(),
                  const SizedBox(width: 12),
                  Text(
                    AppLocalizations.of(context)!.notifications,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            if (_isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: AppTheme.accent),
                ),
              )
            else if (_error != null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.failedToLoadSettings,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _loadSettings,
                        child: Text(AppLocalizations.of(context)!.retry),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Только мой уровень
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.card,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFF2A2A2A),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.onlyMyLevelTournaments,
                                    style: TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    AppLocalizations.of(context)!.onlyMyLevelTournamentsDesc,
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            _isSaving
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: AppTheme.accent,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Switch.adaptive(
                                    value: _notifyOnlyMyLevel,
                                    onChanged: _updateSetting,
                                    activeColor: AppTheme.accent,
                                  ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Напоминать о турнирах
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.card,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFF2A2A2A),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Напоминать о турнирах',
                                    style: TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Пуш за день и за 2 часа до начала записанного турнира',
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            _isSaving
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: AppTheme.accent,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Switch.adaptive(
                                    value: _notifyReminders,
                                    onChanged: _updateReminders,
                                    activeColor: AppTheme.accent,
                                  ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Чат организатора
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.card,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFF2A2A2A),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.notifyOrganizerChat,
                                    style: TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    AppLocalizations.of(context)!.notifyOrganizerChatDesc,
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            _isSaving
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: AppTheme.accent,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Switch.adaptive(
                                    value: _notifyOrganizerChat,
                                    onChanged: _updateOrganizerChat,
                                    activeColor: AppTheme.accent,
                                  ),
                          ],
                        ),
                      ),

                      // Клубы
                      if (_clubs.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Text(
                          AppLocalizations.of(context)!.notifyClubsTitle,
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppLocalizations.of(context)!.notifyClubsDesc,
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.card,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFF2A2A2A),
                              width: 0.5,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: [
                              for (int i = 0; i < _clubs.length; i++) ...[
                                if (i > 0)
                                  const Divider(height: 1, color: Color(0xFF2A2A2A)),
                                _buildClubRow(_clubs[i]),
                              ],
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
