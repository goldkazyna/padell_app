import 'admin_participant.dart';

/// Сетка пар парного Americano Flex в админке.
///
/// Место в таком турнире — это место в паре, а не строка в списке. Экран
/// рисует всю сетку сразу, включая пустые пары, поэтому и приходит она
/// целиком: сколько пар помещается и кто где сидит.
class AdminFlexPairs {
  final int maxPairs;
  final List<AdminFlexPair> pairs;

  const AdminFlexPairs({required this.maxPairs, required this.pairs});

  factory AdminFlexPairs.fromJson(Map<String, dynamic> json) {
    return AdminFlexPairs(
      maxPairs: (json['max_pairs'] as num?)?.toInt() ?? 0,
      pairs: ((json['pairs'] as List?) ?? const [])
          .map((j) => AdminFlexPair.fromJson(j as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Кто уже сидит в парах — по ним считаются пулы «без пары» и очередь.
  Set<int> get seatedIds => {
        for (final p in pairs) ...[
          if (p.player1 != null) p.player1!.id,
          if (p.player2 != null) p.player2!.id,
        ],
      };

  bool get canCreatePair => pairs.length < maxPairs;

  /// Номер строки, в которой откроется новая пара.
  int get nextPosition => pairs.length + 1;
}

class AdminFlexPair {
  final int id;
  final int position;
  final int ratingAvg;
  final AdminParticipant? player1;
  final AdminParticipant? player2;

  const AdminFlexPair({
    required this.id,
    required this.position,
    required this.ratingAvg,
    required this.player1,
    required this.player2,
  });

  factory AdminFlexPair.fromJson(Map<String, dynamic> json) {
    AdminParticipant? seat(String key) {
      final raw = json[key];
      if (raw is! Map<String, dynamic>) return null;
      return AdminParticipant.fromJson(raw);
    }

    return AdminFlexPair(
      id: (json['id'] as num).toInt(),
      position: (json['position'] as num?)?.toInt() ?? 0,
      ratingAvg: (json['rating_avg'] as num?)?.toInt() ?? 0,
      player1: seat('player1'),
      player2: seat('player2'),
    );
  }

  bool get isFull => player1 != null && player2 != null;

  bool has(int userId) => player1?.id == userId || player2?.id == userId;
}
