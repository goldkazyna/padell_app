import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Оборачивает центрированный контент (пусто / ошибка) в pull-to-refresh,
/// чтобы «потянуть вниз» работало даже когда списка нет.
class RefreshableMessage extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  const RefreshableMessage({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppTheme.accent,
      backgroundColor: AppTheme.card,
      child: LayoutBuilder(
        builder: (context, c) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: c.maxHeight),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
