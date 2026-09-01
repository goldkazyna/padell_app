import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../providers/court_provider.dart';
import '../theme/app_theme.dart';

/// Экран оплаты внутри приложения (WebView со страницей Plexy).
/// Готовность оплаты узнаём опросом нашего бэка (статус ставит вебхук Plexy).
/// Возвращает true, если оплата прошла; false — если закрыли вручную.
///
/// Оплачивать можно не только бронь: за турнир платят так же, поэтому
/// вместо [bookingId] можно передать свою проверку [onCheckPaid].
class PaymentWebViewScreen extends StatefulWidget {
  final String url;
  final int? bookingId;

  /// Своя проверка «оплачено ли». Если не задана — спрашиваем про бронь.
  final Future<bool> Function()? onCheckPaid;

  /// Заголовок экрана: у брони и у турнира он разный.
  final String? title;

  /// За что платим — строка под заголовком («Американо, 1 сентября»).
  final String? subtitle;

  /// Сумма справа в шапке: человек должен видеть, сколько списывают,
  /// не доверяя это чужой странице.
  final String? amountLabel;

  const PaymentWebViewScreen({
    super.key,
    required this.url,
    this.bookingId,
    this.onCheckPaid,
    this.title,
    this.subtitle,
    this.amountLabel,
  }) : assert(bookingId != null || onCheckPaid != null,
            'нужен либо bookingId, либо своя проверка оплаты');

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _paid = false;
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));

    // Опрос статуса оплаты каждые 3 сек.
    _poll = Timer.periodic(const Duration(seconds: 3), (_) => _checkPaid());
  }

  Future<void> _checkPaid() async {
    if (_paid || !mounted) return;

    final bool paid;
    if (widget.onCheckPaid != null) {
      paid = await widget.onCheckPaid!();
    } else {
      final res = await context
          .read<CourtProvider>()
          .getPaymentStatus(widget.bookingId!);
      paid = res['success'] == true && res['is_paid'] == true;
    }

    if (!mounted || !paid) return;

    _paid = true;
    _poll?.cancel();
    Navigator.of(context).pop(true);
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(_paid);
      },
      // Фон и шапка — наши: страница шлюза лежит карточкой внутри экрана,
      // а не занимает его целиком. Иначе оплата выглядит как переход в
      // чужое приложение.
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                child: Row(
                  children: [
                    // Круглая 34×34 — как кнопка «назад» на остальных экранах.
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(_paid),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppTheme.card,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFF2A2A2A), width: 0.5),
                        ),
                        child: Icon(Icons.close,
                            color: AppTheme.textSecondary, size: 18),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.title ?? 'Оплата',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if ((widget.subtitle ?? '').isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                widget.subtitle!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Сумму показываем сами: чужой странице верить на слово
                    // человек не обязан.
                    if ((widget.amountLabel ?? '').isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          widget.amountLabel!,
                          style: const TextStyle(
                            color: AppTheme.accent,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20)),
                  child: Stack(
                    children: [
                      Container(color: Colors.white),
                      WebViewWidget(controller: _controller),
                      if (_isLoading)
                        Container(
                          color: AppTheme.background,
                          child: const Center(
                            child: CircularProgressIndicator(
                                color: AppTheme.accent),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
