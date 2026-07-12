import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../providers/court_provider.dart';
import '../theme/app_theme.dart';

/// Экран оплаты брони внутри приложения (WebView со страницей Plexy).
/// Готовность оплаты узнаём опросом нашего бэка (статус ставит вебхук Plexy).
/// Возвращает true, если оплата прошла; false — если закрыли вручную.
class PaymentWebViewScreen extends StatefulWidget {
  final String url;
  final int bookingId;

  const PaymentWebViewScreen({
    super.key,
    required this.url,
    required this.bookingId,
  });

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
    final res =
        await context.read<CourtProvider>().getPaymentStatus(widget.bookingId);
    if (!mounted) return;
    if (res['success'] == true && res['is_paid'] == true) {
      _paid = true;
      _poll?.cancel();
      Navigator.of(context).pop(true);
    }
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
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                color: AppTheme.background,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFF2A2A2A), width: 0.5),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.close,
                            color: AppTheme.textPrimary, size: 22),
                        onPressed: () => Navigator.of(context).pop(_paid),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Оплата',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    WebViewWidget(controller: _controller),
                    if (_isLoading)
                      const Center(
                        child:
                            CircularProgressIndicator(color: AppTheme.accent),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
