import 'package:flutter/material.dart';

import '../../models/game.dart';
import '../../theme/app_theme.dart';

/// Выбор клуба для игры — шторка с поиском.
///
/// Раньше тут был выпадающий список: в нём не было ни поиска, ни нормальной
/// прокрутки, и до нужного клуба человек просто не доходил. Клубы уже
/// загружены, поэтому ищем на месте — без запросов к серверу.
///
/// Возвращает выбранный клуб, `null` — если закрыли, и [clearedClub], если
/// нажали «Убрать клуб».
Future<GameClub?> showGameClubPicker(
  BuildContext context, {
  required List<GameClub> clubs,
  GameClub? selected,
}) {
  return showModalBottomSheet<GameClub>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _ClubPickerSheet(clubs: clubs, selected: selected),
  );
}

/// Псевдо-клуб «ничего не выбрано»: шторка возвращает его, когда нажали
/// «Убрать клуб» — обычный null означал бы «закрыли, ничего не меняем».
final GameClub clearedClub = GameClub(id: -1, name: '');

class _ClubPickerSheet extends StatefulWidget {
  final List<GameClub> clubs;
  final GameClub? selected;

  const _ClubPickerSheet({required this.clubs, this.selected});

  @override
  State<_ClubPickerSheet> createState() => _ClubPickerSheetState();
}

class _ClubPickerSheetState extends State<_ClubPickerSheet> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final found = widget.clubs.where((c) => c.matches(_query)).toList();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                'Клуб',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _search,
                onChanged: (v) => setState(() => _query = v),
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Название, адрес или город',
                  hintStyle: TextStyle(color: AppTheme.textDim, fontSize: 13),
                  prefixIcon:
                      Icon(Icons.search, color: AppTheme.textSecondary, size: 20),
                  filled: true,
                  fillColor: AppTheme.cardRaised,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                    borderSide:
                        const BorderSide(color: AppTheme.accent, width: 1.2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              if (widget.selected != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(clearedClub),
                    child: Text(
                      'Убрать клуб',
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
                  maxHeight: MediaQuery.of(context).size.height * 0.45,
                ),
                child: found.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'Ничего не нашли',
                          style: TextStyle(
                              color: AppTheme.textSecondary, fontSize: 13),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: found.length,
                        separatorBuilder: (_, _) => Divider(
                          height: 1,
                          color: AppTheme.border,
                        ),
                        itemBuilder: (_, i) => _tile(found[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tile(GameClub club) {
    final chosen = club.id == widget.selected?.id;

    return InkWell(
      onTap: () => Navigator.of(context).pop(club),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(Icons.place_outlined,
                color: chosen ? AppTheme.accent : AppTheme.textSecondary,
                size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    club.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: chosen ? AppTheme.accent : AppTheme.textPrimary,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (club.place.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        club.place,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
            if (chosen)
              Icon(Icons.check, color: AppTheme.accent, size: 18),
          ],
        ),
      ),
    );
  }
}
