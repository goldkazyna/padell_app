import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _service;
  ChatProvider(this._service);

  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _isSending = false;
  bool get isSending => _isSending;
  String? _error;
  String? get error => _error;

  Timer? _timer;

  int get _lastId => _messages.isEmpty ? 0 : _messages.last.id;

  Future<void> loadInitial(int tournamentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final list = await _service.getMessages(tournamentId);
      list.sort((a, b) => a.id.compareTo(b.id));
      _messages
        ..clear()
        ..addAll(list);
      await _markReadSafe(tournamentId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchNewer(int tournamentId) async {
    try {
      final list = await _service.getMessages(tournamentId, afterId: _lastId);
      if (list.isEmpty) return;
      final existing = _messages.map((m) => m.id).toSet();
      final fresh = list.where((m) => !existing.contains(m.id)).toList();
      if (fresh.isEmpty) return;
      fresh.sort((a, b) => a.id.compareTo(b.id));
      _messages.addAll(fresh);
      await _markReadSafe(tournamentId);
      notifyListeners();
    } catch (_) {
      // опрос молча ретраит на следующем тике
    }
  }

  Future<bool> send(int tournamentId, String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;
    _isSending = true;
    _error = null;
    notifyListeners();
    try {
      final msg = await _service.sendMessage(tournamentId, trimmed);
      if (!_messages.any((m) => m.id == msg.id)) {
        _messages.add(msg);
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  Future<void> delete(int tournamentId, int messageId) async {
    final idx = _messages.indexWhere((m) => m.id == messageId);
    if (idx == -1) return;
    final removed = _messages.removeAt(idx);
    notifyListeners();
    try {
      await _service.deleteMessage(tournamentId, messageId);
    } catch (e) {
      _messages.insert(idx, removed); // откат при ошибке
      _error = e.toString();
      notifyListeners();
    }
  }

  void startPolling(int tournamentId) {
    _timer?.cancel();
    _timer = Timer.periodic(
        const Duration(seconds: 5), (_) => fetchNewer(tournamentId));
  }

  void stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  void clear() {
    stopPolling();
    _messages.clear();
    _error = null;
    _isLoading = false;
    _isSending = false;
  }

  Future<void> _markReadSafe(int tournamentId) async {
    if (_messages.isEmpty) return;
    try {
      await _service.markRead(tournamentId, _lastId);
    } catch (_) {}
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
