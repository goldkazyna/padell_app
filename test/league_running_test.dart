import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/models/league.dart';

/// Счётчик «Мои лиги» в профиле.
///
/// Рядом с «Моими турнирами» и «Тренировками» число есть, а у лиг его не
/// было — раздел выглядел пустым, даже когда человек в двух лигах играет.
/// Считаем только идущие: завершённые живут в истории.
League _league(String status) => League.fromJson({
      'id': 1,
      'name': 'Осенняя лига',
      'status': status,
      'status_name': status,
    });

void main() {
  test('идущая лига считается, завершённая — нет', () {
    expect(_league('open').isRunning, isTrue);
    expect(_league('in_progress').isRunning, isTrue);
    expect(_league('completed').isRunning, isFalse);
    expect(_league('cancelled').isRunning, isFalse);
  });

  test('счёт по списку', () {
    final mine = [
      _league('in_progress'),
      _league('completed'),
      _league('open'),
    ];

    expect(mine.where((l) => l.isRunning).length, 2);
  });
}
