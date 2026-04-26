import 'package:flutter/foundation.dart';

/// Глобальный нотификатор активной вкладки нижнего меню в [MainScreen].
/// Любой экран может вызвать [mainTabNotifier.value = N] чтобы переключить
/// вкладку — это полезно для всплывающих экранов (типа live-турнира),
/// которые хотят показать «своё» нижнее меню и при тапе вернуться в
/// корень с нужной выбранной вкладкой.
final ValueNotifier<int> mainTabNotifier = ValueNotifier<int>(0);
