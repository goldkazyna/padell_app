import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';

/// Поле выбора клуба-площадки (где физически играют) для админских экранов.
///
/// Площадка необязательна: [clubId] == null означает «не выбрана». Тап
/// открывает bottom sheet с поиском по названию/адресу/городу, крестик
/// сбрасывает выбор без открытия sheet.
class VenueClubField extends StatelessWidget {
  const VenueClubField({
    super.key,
    required this.clubId,
    required this.clubName,
    required this.onChanged,
    this.enabled = true,
  });

  final int? clubId;
  final String? clubName;

  /// Вызывается с (id, name) при выборе и с (null, null) при сбросе.
  final void Function(int? id, String? name) onChanged;

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final hasVenue = clubId != null;

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: GestureDetector(
        onTap: enabled ? () => _showPicker(context) : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: AppTheme.cardRaised,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(Icons.place_outlined,
                  color: AppTheme.textSecondary, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hasVenue ? clubName ?? '' : 'Не выбран',
                  style: TextStyle(
                    color: hasVenue ? AppTheme.textPrimary : AppTheme.textDim,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (hasVenue && enabled)
                GestureDetector(
                  onTap: () => onChanged(null, null),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.close, color: AppTheme.textDim, size: 18),
                  ),
                )
              else
                Icon(Icons.chevron_right, color: AppTheme.textDim, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  /// Bottom sheet поиска клуба с debounce (400 мс).
  Future<void> _showPicker(BuildContext context) async {
    final admin = context.read<AdminService>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        final searchCtrl = TextEditingController();
        Timer? debounce;
        List<Map<String, dynamic>> results = [];
        bool loading = true;
        String? error;
        bool initialLoadStarted = false;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> runSearch(String query) async {
              setSheetState(() => loading = true);
              try {
                final found = await admin.searchClubs(query);
                setSheetState(() {
                  results = found;
                  loading = false;
                  error = null;
                });
              } catch (e) {
                setSheetState(() {
                  loading = false;
                  error = '$e';
                });
              }
            }

            // Первичная загрузка (пустой запрос) — один раз при открытии.
            if (!initialLoadStarted) {
              initialLoadStarted = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                runSearch('');
              });
            }

            void onChangedQuery(String value) {
              debounce?.cancel();
              debounce = Timer(const Duration(milliseconds: 400), () {
                runSearch(value);
              });
            }

            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3A3A3A),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Клуб (площадка)',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: searchCtrl,
                        onChanged: onChangedQuery,
                        style: TextStyle(
                            color: AppTheme.textPrimary, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Название, адрес или город',
                          hintStyle:
                              TextStyle(color: AppTheme.textDim, fontSize: 13),
                          prefixIcon: Icon(Icons.search,
                              color: AppTheme.textSecondary, size: 20),
                          filled: true,
                          fillColor: AppTheme.cardRaised,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: AppTheme.accent, width: 1.2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (clubId != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: GestureDetector(
                            onTap: () {
                              onChanged(null, null);
                              Navigator.of(sheetContext).pop();
                            },
                            child: Text(
                              'Убрать площадку',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.4,
                        ),
                        child: _buildResults(
                          sheetContext,
                          loading: loading,
                          error: error,
                          results: results,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildResults(
    BuildContext sheetContext, {
    required bool loading,
    required String? error,
    required List<Map<String, dynamic>> results,
  }) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
                color: AppTheme.accent, strokeWidth: 2.5),
          ),
        ),
      );
    }

    if (error != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Ошибка поиска: $error',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
      );
    }

    if (results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Ничего не найдено',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: results.length,
      itemBuilder: (context, index) {
        final club = results[index];
        final id = club['id'] as int;
        final name = '${club['name'] ?? ''}';
        final city = club['city'];
        final isSelected = clubId == id;

        return GestureDetector(
          onTap: () {
            onChanged(id, name);
            Navigator.of(sheetContext).pop();
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.accent.withAlpha(15)
                  : AppTheme.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppTheme.accent : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (city != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    '$city',
                    style:
                        TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
