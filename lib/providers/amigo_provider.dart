import 'package:flutter/material.dart';

import '../models/amigo.dart';
import '../services/amigo_service.dart';
import '../services/storage_service.dart';

/// Состояние амигос: списки, лента, переписки, блокировки.
///
/// Держим в одном провайдере, потому что данные связаны: добавили человека —
/// он исчезает из кандидатов и появляется в списке; заблокировали — пропадает
/// и из списка, и из переписок.
class AmigoProvider extends ChangeNotifier {
  final AmigoService _service;
  final StorageService _storage;

  AmigoProvider(this._service, this._storage);

  List<Amigo> _amigos = [];
  List<Amigo> _followers = [];
  List<AmigoCandidate> _candidates = [];
  List<AmigoFeedEvent> _feed = [];
  List<ConversationSummary> _conversations = [];
  List<BlockedUser> _blocked = [];

  int _count = 0;
  int _playingCount = 0;
  int _unread = 0;

  bool _isLoading = false;
  bool _isLoadingFeed = false;
  bool _isLoadingConversations = false;
  bool _isActionLoading = false;
  String? _error;

  List<Amigo> get amigos => _amigos;
  List<Amigo> get followers => _followers;
  List<AmigoCandidate> get candidates => _candidates;
  List<AmigoFeedEvent> get feed => _feed;
  List<ConversationSummary> get conversations => _conversations;
  List<BlockedUser> get blocked => _blocked;

  int get count => _count;
  int get playingCount => _playingCount;
  int get unread => _unread;
  int get followersCount => _followers.length;

  bool get isLoading => _isLoading;
  bool get isLoadingFeed => _isLoadingFeed;
  bool get isLoadingConversations => _isLoadingConversations;
  bool get isActionLoading => _isActionLoading;
  String? get error => _error;

  /// Кто из своих сейчас на корте — для карточки в профиле.
  List<Amigo> get playing =>
      _amigos.where((a) => a.status?.isPlaying == true).toList();

  Future<String?> _token() => _storage.getToken();

  // ===== связи =====

  Future<void> loadAmigos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _token();
      if (token == null) return;

      final result = await _service.getAmigos(token);
      _amigos = result.items;
      _count = result.count;
      _playingCount = result.playingCount;
    } catch (e) {
      _error = '$e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFollowers() async {
    try {
      final token = await _token();
      if (token == null) return;

      _followers = await _service.getFollowers(token);
    } catch (e) {
      _error = '$e';
    }
    notifyListeners();
  }

  Future<void> loadCandidates() async {
    try {
      final token = await _token();
      if (token == null) return;

      _candidates = await _service.getCandidates(token);
    } catch (e) {
      _error = '$e';
    }
    notifyListeners();
  }

  Future<void> loadFeed() async {
    _isLoadingFeed = true;
    notifyListeners();

    try {
      final token = await _token();
      if (token == null) return;

      _feed = await _service.getFeed(token);
    } catch (e) {
      _error = '$e';
    } finally {
      _isLoadingFeed = false;
      notifyListeners();
    }
  }

  /// Карточка в профиле: список своих и счётчик непрочитанных.
  Future<void> loadSummary() async {
    await Future.wait([loadAmigos(), loadUnread()]);
  }

  Future<bool> follow(int userId) async {
    _isActionLoading = true;
    notifyListeners();

    try {
      final token = await _token();
      if (token == null) return false;

      await _service.follow(userId, token);

      // Кандидат становится добавленным на месте: строка не исчезает и
      // список не прыгает под пальцем.
      _candidates = _candidates
          .map((c) => c.id == userId ? c.copyWith(added: true) : c)
          .toList();
      _followers = _followers
          .map((f) => f.id == userId ? f.copyWith(isAmigo: true, mutual: true) : f)
          .toList();

      await loadAmigos();
      return true;
    } catch (e) {
      _error = '$e';
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> unfollow(int userId) async {
    _isActionLoading = true;
    notifyListeners();

    try {
      final token = await _token();
      if (token == null) return false;

      await _service.unfollow(userId, token);
      _amigos = _amigos.where((a) => a.id != userId).toList();
      _count = _amigos.length;
      _playingCount = playing.length;
      _followers = _followers
          .map((f) => f.id == userId ? f.copyWith(isAmigo: false, mutual: false) : f)
          .toList();
      return true;
    } catch (e) {
      _error = '$e';
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  // ===== переписка =====

  Future<void> loadConversations() async {
    _isLoadingConversations = true;
    notifyListeners();

    try {
      final token = await _token();
      if (token == null) return;

      _conversations = await _service.getConversations(token);
      _unread = _conversations.fold(0, (sum, c) => sum + c.unread);
    } catch (e) {
      _error = '$e';
    } finally {
      _isLoadingConversations = false;
      notifyListeners();
    }
  }

  Future<void> loadUnread() async {
    try {
      final token = await _token();
      if (token == null) return;

      _unread = await _service.getUnreadCount(token);
    } catch (e) {
      // Бейдж — не то, ради чего стоит показывать ошибку.
    }
    notifyListeners();
  }

  Future<ChatThread?> loadThread(int userId, {int? afterId}) async {
    try {
      final token = await _token();
      if (token == null) return null;

      return await _service.getThread(userId, token, afterId: afterId);
    } catch (e) {
      _error = '$e';
      return null;
    }
  }

  /// Отправить сообщение. Возвращает null и кладёт текст ошибки в [error],
  /// если сервер отказал (блокировка, лимит, повтор).
  Future<ChatMessage?> sendMessage(int userId, String text) async {
    try {
      final token = await _token();
      if (token == null) return null;

      _error = null;
      return await _service.sendMessage(userId, text, token);
    } catch (e) {
      _error = '$e';
      return null;
    }
  }

  Future<void> markRead(int userId) async {
    try {
      final token = await _token();
      if (token == null) return;

      _unread = await _service.markRead(userId, token);
      notifyListeners();
    } catch (e) {
      // Молча: непрочитанные пересчитаются при следующем открытии списка.
    }
  }

  Future<bool> deleteMessage(int messageId) async {
    try {
      final token = await _token();
      if (token == null) return false;

      await _service.deleteMessage(messageId, token);
      return true;
    } catch (e) {
      _error = '$e';
      return false;
    }
  }

  // ===== блокировки и жалобы =====

  Future<void> loadBlocked() async {
    try {
      final token = await _token();
      if (token == null) return;

      _blocked = await _service.getBlocked(token);
    } catch (e) {
      _error = '$e';
    }
    notifyListeners();
  }

  Future<bool> block(int userId) async {
    try {
      final token = await _token();
      if (token == null) return false;

      await _service.block(userId, token);

      // Блокировка рвёт связь и прячет переписку — убираем сразу, не дожидаясь
      // перезагрузки экрана.
      _amigos = _amigos.where((a) => a.id != userId).toList();
      _followers = _followers.where((f) => f.id != userId).toList();
      _conversations = _conversations.where((c) => c.playerId != userId).toList();
      _count = _amigos.length;
      _playingCount = playing.length;
      notifyListeners();
      return true;
    } catch (e) {
      _error = '$e';
      return false;
    }
  }

  Future<bool> unblock(int userId) async {
    try {
      final token = await _token();
      if (token == null) return false;

      await _service.unblock(userId, token);
      _blocked = _blocked.where((b) => b.id != userId).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _error = '$e';
      return false;
    }
  }

  Future<bool> report(int userId, String reason, {String? comment}) async {
    try {
      final token = await _token();
      if (token == null) return false;

      await _service.report(userId, reason, token, comment: comment);
      return true;
    } catch (e) {
      _error = '$e';
      return false;
    }
  }
}
