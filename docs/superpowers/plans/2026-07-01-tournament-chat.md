# Tournament Chat Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Добавить в приложение чат внутри каждого турнира — с ролями (только организатор / участники / все), кнопкой+бейджем непрочитанных на экране турнира, отправкой текста и опросом сервера без веб-сокетов.

**Architecture:** Сервер-центричные права — бэкенд отдаёт блок `chat` (capabilities + unread) в ответе турнира; клиент только рендерит. Слои по существующей структуре: `models/` → `services/chat_service.dart` → `providers/chat_provider.dart` → `screens/tournament_chat_screen.dart`. Реалтайм — polling-таймер, живущий только пока экран чата открыт.

**Tech Stack:** Flutter/Dart, `provider` (ChangeNotifier), `http` через `ApiService`, локализация `flutter_localizations` + `.arb` (RU/EN/KK). Бэкенд — Laravel (отдельный репозиторий `padel`), контракт описан в Приложении A.

## Global Constraints

- Dart SDK `^3.10.8`, Material 3, тёмная тема из `lib/theme/app_theme.dart`.
- **Все пользовательские строки — через `AppLocalizations`** (RU + EN + KK). Хардкод запрещён. Исключение: admin-экраны (`admin_create_tournament_screen`, форма редактирования) — там строки можно хардкодить (правило проекта).
- **Никаких SnackBar** — уведомления через `showAppAlert` из `lib/utils/app_alert.dart`.
- **Кнопка «назад»** — круглая через `AppBackButton` (`lib/widgets/app_back_button.dart`).
- **Палитра** — только `AppTheme.accent` / `orange` / насыщенный `#7C3AED`; бледный `AppTheme.purple` не использовать.
- Все `int`/`num` поля из API парсить null-safe (`(x as num?)?.toInt() ?? 0`).
- `ApiService`: `get(endpoint, token)`, `post(endpoint, body, token)`, `delete(endpoint, body?, token)`. Токен — `await _storage.getToken()`. Сервисы принимают `(ApiService, StorageService)`.
- Бэкенд — отдельный репозиторий; после правок бэка коммит+пуш сразу, миграции деплоить через `--path=` к конкретному файлу (правило проекта). Задачи по бэку в этом плане — только как контракт/handoff (Приложение A), их выполняет бэкендер.
- Запуск линта/тестов: `flutter analyze`, `flutter test`.

---

## File Structure

**Создать:**
- `lib/models/chat_message.dart` — модель сообщения `ChatMessage` (+ вложенный `ChatUser`).
- `lib/models/tournament_chat.dart` — блок capabilities `TournamentChat`.
- `lib/services/chat_service.dart` — 4 эндпоинта.
- `lib/providers/chat_provider.dart` — состояние ленты, опрос-таймер, send/delete/markRead.
- `lib/screens/tournament_chat_screen.dart` — экран чата.
- `lib/widgets/tournaments/chat_message_bubble.dart` — пузырь сообщения (свой/чужой/админ).
- `test/models/chat_message_test.dart`, `test/models/tournament_chat_test.dart`, `test/providers/chat_provider_test.dart`.

**Изменить:**
- `lib/models/tournament.dart` — поле `chat` (`TournamentChat?`) + парсинг в `fromJson`.
- `lib/main.dart` — регистрация `ChatProvider` (через `ChangeNotifierProvider`) и `Provider<ChatService>`.
- `lib/screens/tournament_detail_screen.dart` — круглая кнопка чата + бейдж непрочитанных в шапке.
- `lib/screens/admin/admin_create_tournament_screen.dart` — блок настроек чата (+ в форме редактирования турнира).
- `lib/l10n/app_ru.arb`, `app_en.arb`, `app_kk.arb` — строки чата.

---

## Task 1: Модели ChatMessage и TournamentChat

**Files:**
- Create: `lib/models/chat_message.dart`
- Create: `lib/models/tournament_chat.dart`
- Test: `test/models/chat_message_test.dart`, `test/models/tournament_chat_test.dart`

**Interfaces:**
- Produces:
  - `class ChatUser { final int id; final String name; final String? avatar; final String? level; factory ChatUser.fromJson(Map<String,dynamic>) }`
  - `class ChatMessage { final int id; final ChatUser user; final String text; final bool isAdmin; final bool isMine; final DateTime? createdAt; factory ChatMessage.fromJson(Map<String,dynamic>) }`
  - `class TournamentChat { final bool enabled; final String writeMode; final bool canRead; final bool canWrite; final bool isAdmin; final int unreadCount; factory TournamentChat.fromJson(Map<String,dynamic>) }`

- [ ] **Step 1: Написать падающий тест для ChatMessage**

`test/models/chat_message_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/models/chat_message.dart';

void main() {
  test('ChatMessage.fromJson парсит все поля', () {
    final m = ChatMessage.fromJson({
      'id': 123,
      'user': {'id': 7, 'name': 'Иван', 'avatar': 'u', 'level': '3.5'},
      'text': 'Кто на 19:00?',
      'is_admin': true,
      'is_mine': false,
      'created_at': '2026-07-01T12:00:00Z',
    });
    expect(m.id, 123);
    expect(m.user.name, 'Иван');
    expect(m.user.level, '3.5');
    expect(m.text, 'Кто на 19:00?');
    expect(m.isAdmin, true);
    expect(m.isMine, false);
    expect(m.createdAt, isNotNull);
  });

  test('ChatMessage.fromJson терпит отсутствующие поля', () {
    final m = ChatMessage.fromJson({'id': 1, 'user': {'id': 2, 'name': 'A'}, 'text': ''});
    expect(m.isAdmin, false);
    expect(m.isMine, false);
    expect(m.user.avatar, isNull);
    expect(m.createdAt, isNull);
  });
}
```

- [ ] **Step 2: Запустить тест — убедиться, что падает**

Run: `flutter test test/models/chat_message_test.dart`
Expected: FAIL — `Target of URI doesn't exist: 'package:padel_app/models/chat_message.dart'`.

- [ ] **Step 3: Реализовать `lib/models/chat_message.dart`**

```dart
class ChatUser {
  final int id;
  final String name;
  final String? avatar;
  final String? level;

  const ChatUser({required this.id, required this.name, this.avatar, this.level});

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    final rawLevel = json['level'];
    return ChatUser(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      avatar: json['avatar'] as String?,
      level: rawLevel == null ? null : rawLevel.toString(),
    );
  }
}

class ChatMessage {
  final int id;
  final ChatUser user;
  final String text;
  final bool isAdmin;
  final bool isMine;
  final DateTime? createdAt;

  const ChatMessage({
    required this.id,
    required this.user,
    required this.text,
    this.isAdmin = false,
    this.isMine = false,
    this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: (json['id'] as num?)?.toInt() ?? 0,
      user: ChatUser.fromJson(
          (json['user'] as Map<String, dynamic>?) ?? const {}),
      text: json['text'] as String? ?? '',
      isAdmin: json['is_admin'] as bool? ?? false,
      isMine: json['is_mine'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
    );
  }
}
```

- [ ] **Step 4: Написать падающий тест для TournamentChat**

`test/models/tournament_chat_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/models/tournament_chat.dart';

void main() {
  test('TournamentChat.fromJson парсит capabilities', () {
    final c = TournamentChat.fromJson({
      'enabled': true,
      'write_mode': 'participants',
      'can_read': true,
      'can_write': true,
      'is_admin': false,
      'unread_count': 3,
    });
    expect(c.enabled, true);
    expect(c.writeMode, 'participants');
    expect(c.canRead, true);
    expect(c.canWrite, true);
    expect(c.isAdmin, false);
    expect(c.unreadCount, 3);
  });

  test('TournamentChat.fromJson дефолты при пустом объекте', () {
    final c = TournamentChat.fromJson(const {});
    expect(c.enabled, false);
    expect(c.writeMode, 'participants');
    expect(c.canRead, false);
    expect(c.unreadCount, 0);
  });
}
```

- [ ] **Step 5: Реализовать `lib/models/tournament_chat.dart`**

```dart
class TournamentChat {
  final bool enabled;
  final String writeMode; // admin | participants | everyone
  final bool canRead;
  final bool canWrite;
  final bool isAdmin;
  final int unreadCount;

  const TournamentChat({
    this.enabled = false,
    this.writeMode = 'participants',
    this.canRead = false,
    this.canWrite = false,
    this.isAdmin = false,
    this.unreadCount = 0,
  });

  factory TournamentChat.fromJson(Map<String, dynamic> json) {
    return TournamentChat(
      enabled: json['enabled'] as bool? ?? false,
      writeMode: json['write_mode'] as String? ?? 'participants',
      canRead: json['can_read'] as bool? ?? false,
      canWrite: json['can_write'] as bool? ?? false,
      isAdmin: json['is_admin'] as bool? ?? false,
      unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
    );
  }
}
```

- [ ] **Step 6: Запустить оба теста — убедиться, что проходят**

Run: `flutter test test/models/chat_message_test.dart test/models/tournament_chat_test.dart`
Expected: PASS (все тесты зелёные).

- [ ] **Step 7: Коммит**

```bash
git add lib/models/chat_message.dart lib/models/tournament_chat.dart test/models/chat_message_test.dart test/models/tournament_chat_test.dart
git commit -m "feat(chat): модели ChatMessage и TournamentChat"
```

---

## Task 2: Встроить блок chat в Tournament

**Files:**
- Modify: `lib/models/tournament.dart` (поле, конструктор, `fromJson`)
- Test: `test/models/tournament_chat_field_test.dart`

**Interfaces:**
- Consumes: `TournamentChat` (Task 1).
- Produces: `Tournament.chat` (тип `TournamentChat?`).

- [ ] **Step 1: Написать падающий тест**

`test/models/tournament_chat_field_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/models/tournament.dart';

Map<String, dynamic> _baseJson() => {
      'id': 1, 'name': 'T', 'club': {'id': 1, 'name': 'C'},
      'date': '2026-07-01', 'time': '19:00',
      'datetime': '2026-07-01T19:00:00Z',
      'type': 'americano', 'type_name': 'Американо',
      'status': 'open', 'status_name': 'Открыт',
      'min_level': 1.0, 'max_level': 5.0, 'price': 0,
      'max_participants': 8, 'participants_count': 0,
    };

void main() {
  test('Tournament.chat парсится из блока chat', () {
    final json = _baseJson()
      ..['chat'] = {'enabled': true, 'can_read': true, 'unread_count': 2};
    final t = Tournament.fromJson(json);
    expect(t.chat, isNotNull);
    expect(t.chat!.canRead, true);
    expect(t.chat!.unreadCount, 2);
  });

  test('Tournament.chat == null если блока нет', () {
    final t = Tournament.fromJson(_baseJson());
    expect(t.chat, isNull);
  });
}
```
> Примечание: если конструктор `Tournament` требует другие обязательные поля — дополни `_baseJson()` минимально необходимыми ключами, сверяясь с `lib/models/tournament.dart:357` (`fromJson`).

- [ ] **Step 2: Запустить — убедиться, что падает**

Run: `flutter test test/models/tournament_chat_field_test.dart`
Expected: FAIL — `The getter 'chat' isn't defined for the class 'Tournament'`.

- [ ] **Step 3: Добавить импорт и поле в `lib/models/tournament.dart`**

Вверху файла, к остальным импортам моделей:
```dart
import 'tournament_chat.dart';
```
В список полей (после `final DateTime? moderationDeadline;`, строка ~307):
```dart
  final TournamentChat? chat;
```
В конструктор (после `this.moderationDeadline,`, строка ~346):
```dart
    this.chat,
```

- [ ] **Step 4: Распарсить в `fromJson`**

В теле `factory Tournament.fromJson` (около `return Tournament(`), добавить в список аргументов:
```dart
      chat: json['chat'] == null
          ? null
          : TournamentChat.fromJson(json['chat'] as Map<String, dynamic>),
```

- [ ] **Step 5: Запустить тест + анализ**

Run: `flutter test test/models/tournament_chat_field_test.dart && flutter analyze lib/models/tournament.dart`
Expected: тест PASS; analyze — без ошибок.

- [ ] **Step 6: Коммит**

```bash
git add lib/models/tournament.dart test/models/tournament_chat_field_test.dart
git commit -m "feat(chat): поле chat в модели Tournament"
```

---

## Task 3: ChatService (4 эндпоинта)

**Files:**
- Create: `lib/services/chat_service.dart`

**Interfaces:**
- Consumes: `ApiService`, `StorageService`, `ChatMessage` (Task 1).
- Produces:
  - `Future<List<ChatMessage>> getMessages(int tournamentId, {int? afterId, int? beforeId, int limit = 50})`
  - `Future<ChatMessage> sendMessage(int tournamentId, String text)`
  - `Future<void> deleteMessage(int tournamentId, int messageId)`
  - `Future<void> markRead(int tournamentId, int lastMessageId)`

- [ ] **Step 1: Реализовать `lib/services/chat_service.dart`**

```dart
import '../models/chat_message.dart';
import 'api_service.dart';
import 'storage_service.dart';

class ChatService {
  final ApiService _api;
  final StorageService _storage;

  ChatService(this._api, this._storage);

  /// Сообщения турнира. afterId — только новее (опрос/pull-to-refresh),
  /// beforeId — история вверх. Ответ ожидается в ключе `messages`.
  Future<List<ChatMessage>> getMessages(
    int tournamentId, {
    int? afterId,
    int? beforeId,
    int limit = 50,
  }) async {
    final token = await _storage.getToken();
    final qp = <String>['limit=$limit'];
    if (afterId != null) qp.add('after_id=$afterId');
    if (beforeId != null) qp.add('before_id=$beforeId');
    final r = await _api.get(
        '/tournaments/$tournamentId/chat/messages?${qp.join('&')}', token);
    final list = (r['messages'] as List?) ?? const [];
    return list
        .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
        .toList();
  }

  Future<ChatMessage> sendMessage(int tournamentId, String text) async {
    final token = await _storage.getToken();
    final r = await _api.post(
        '/tournaments/$tournamentId/chat/messages', {'text': text}, token);
    return ChatMessage.fromJson(r['message'] as Map<String, dynamic>);
  }

  Future<void> deleteMessage(int tournamentId, int messageId) async {
    final token = await _storage.getToken();
    await _api.delete(
        '/tournaments/$tournamentId/chat/messages/$messageId', null, token);
  }

  Future<void> markRead(int tournamentId, int lastMessageId) async {
    final token = await _storage.getToken();
    await _api.post('/tournaments/$tournamentId/chat/read',
        {'last_message_id': lastMessageId}, token);
  }
}
```

- [ ] **Step 2: Анализ**

Run: `flutter analyze lib/services/chat_service.dart`
Expected: без ошибок.

- [ ] **Step 3: Коммит**

```bash
git add lib/services/chat_service.dart
git commit -m "feat(chat): ChatService с 4 эндпоинтами"
```

---

## Task 4: ChatProvider (состояние + опрос + send/delete)

**Files:**
- Create: `lib/providers/chat_provider.dart`
- Test: `test/providers/chat_provider_test.dart`

**Interfaces:**
- Consumes: `ChatService` (Task 3), `ChatMessage` (Task 1).
- Produces (публичное API провайдера):
  - `List<ChatMessage> get messages`
  - `bool get isLoading`, `bool get isSending`, `String? get error`
  - `Future<void> loadInitial(int tournamentId)` — первичная загрузка + markRead
  - `Future<void> fetchNewer(int tournamentId)` — догрузка новых (опрос/refresh) + markRead
  - `Future<bool> send(int tournamentId, String text)` — true при успехе
  - `Future<void> delete(int tournamentId, int messageId)` — оптимистичное удаление
  - `void startPolling(int tournamentId)` / `void stopPolling()` — таймер 5с
  - `void clear()` — сброс при выходе с экрана

Провайдер отделяет таймер (тестируется через ручной вызов `fetchNewer`, не через реальный `Timer`).

- [ ] **Step 1: Написать падающие тесты с фейк-сервисом**

`test/providers/chat_provider_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/models/chat_message.dart';
import 'package:padel_app/providers/chat_provider.dart';
import 'package:padel_app/services/chat_service.dart';

class FakeChatService extends ChatService {
  FakeChatService() : super(_never(), _never());
  static dynamic _never() => throw UnimplementedError();

  final List<ChatMessage> store = [];
  int? lastReadId;
  bool failSend = false;

  @override
  Future<List<ChatMessage>> getMessages(int t,
      {int? afterId, int? beforeId, int limit = 50}) async {
    if (afterId != null) {
      return store.where((m) => m.id > afterId).toList();
    }
    return List<ChatMessage>.from(store);
  }

  @override
  Future<ChatMessage> sendMessage(int t, String text) async {
    if (failSend) throw Exception('network');
    final m = ChatMessage(
        id: store.length + 100,
        user: const ChatUser(id: 1, name: 'Me'),
        text: text,
        isMine: true);
    store.add(m);
    return m;
  }

  @override
  Future<void> deleteMessage(int t, int id) async {
    store.removeWhere((m) => m.id == id);
  }

  @override
  Future<void> markRead(int t, int lastId) async {
    lastReadId = lastId;
  }
}

ChatMessage _msg(int id, {bool mine = false}) => ChatMessage(
    id: id, user: ChatUser(id: id, name: 'U$id'), text: 't$id', isMine: mine);

void main() {
  test('loadInitial грузит сообщения и помечает прочитанным', () async {
    final fake = FakeChatService()..store.addAll([_msg(1), _msg(2)]);
    final p = ChatProvider(fake);
    await p.loadInitial(10);
    expect(p.messages.length, 2);
    expect(fake.lastReadId, 2);
    expect(p.isLoading, false);
  });

  test('fetchNewer дописывает только новые', () async {
    final fake = FakeChatService()..store.add(_msg(1));
    final p = ChatProvider(fake);
    await p.loadInitial(10);
    fake.store.add(_msg(2));
    await p.fetchNewer(10);
    expect(p.messages.map((m) => m.id), [1, 2]);
    expect(fake.lastReadId, 2);
  });

  test('send добавляет сообщение и возвращает true', () async {
    final fake = FakeChatService();
    final p = ChatProvider(fake);
    await p.loadInitial(10);
    final ok = await p.send(10, 'привет');
    expect(ok, true);
    expect(p.messages.last.text, 'привет');
  });

  test('send при ошибке возвращает false и не добавляет', () async {
    final fake = FakeChatService()..failSend = true;
    final p = ChatProvider(fake);
    await p.loadInitial(10);
    final ok = await p.send(10, 'x');
    expect(ok, false);
    expect(p.messages, isEmpty);
    expect(p.error, isNotNull);
  });

  test('delete убирает сообщение из ленты', () async {
    final fake = FakeChatService()..store.addAll([_msg(1), _msg(2)]);
    final p = ChatProvider(fake);
    await p.loadInitial(10);
    await p.delete(10, 1);
    expect(p.messages.map((m) => m.id), [2]);
  });
}
```

- [ ] **Step 2: Запустить — убедиться, что падает**

Run: `flutter test test/providers/chat_provider_test.dart`
Expected: FAIL — `Target of URI doesn't exist: '.../providers/chat_provider.dart'`.

- [ ] **Step 3: Реализовать `lib/providers/chat_provider.dart`**

```dart
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
      if (list.isNotEmpty) {
        list.sort((a, b) => a.id.compareTo(b.id));
        _messages.addAll(list);
        await _markReadSafe(tournamentId);
        notifyListeners();
      }
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
      _messages.add(msg);
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
```

- [ ] **Step 4: Запустить тесты — все зелёные**

Run: `flutter test test/providers/chat_provider_test.dart`
Expected: PASS (5 тестов).

- [ ] **Step 5: Коммит**

```bash
git add lib/providers/chat_provider.dart test/providers/chat_provider_test.dart
git commit -m "feat(chat): ChatProvider — лента, опрос, send/delete"
```

---

## Task 5: Регистрация провайдера и сервиса в main.dart

**Files:**
- Modify: `lib/main.dart`

**Interfaces:**
- Consumes: `ChatService` (Task 3), `ChatProvider` (Task 4).
- Produces: доступ `context.read<ChatProvider>()` и `context.read<ChatService>()`.

- [ ] **Step 1: Импорты и создание сервиса**

В `lib/main.dart` к импортам сервисов добавить:
```dart
import 'services/chat_service.dart';
import 'providers/chat_provider.dart';
```
Рядом с `final supportService = SupportService(apiService, storageService);` добавить:
```dart
  final chatService = ChatService(apiService, storageService);
```

- [ ] **Step 2: Зарегистрировать в MultiProvider**

В списке `providers:` добавить (рядом с прочими `ChangeNotifierProvider` / `Provider.value`):
```dart
        ChangeNotifierProvider(
          create: (_) => ChatProvider(chatService),
        ),
        Provider<ChatService>.value(value: chatService),
```

- [ ] **Step 3: Анализ**

Run: `flutter analyze lib/main.dart`
Expected: без ошибок.

- [ ] **Step 4: Коммит**

```bash
git add lib/main.dart
git commit -m "feat(chat): регистрация ChatProvider/ChatService в main"
```

---

## Task 6: Строки локализации (RU/EN/KK)

**Files:**
- Modify: `lib/l10n/app_ru.arb`, `lib/l10n/app_en.arb`, `lib/l10n/app_kk.arb`

**Interfaces:**
- Produces (геттеры `AppLocalizations`): `chatTitle`, `chatModeAdmin`, `chatModeParticipants`, `chatModeEveryone`, `chatInputHint`, `chatLockedOnlyAdmin`, `chatReadOnlyFinished`, `chatEmpty`, `chatDelete`, `chatOrganizerBadge`, `chatSendFailed`, `chatRetry`.

- [ ] **Step 1: Добавить ключи в `app_ru.arb`** (шаблон, `template-arb-file`)

Перед закрывающей `}` добавить:
```json
  "chatTitle": "Чат турнира",
  "chatModeAdmin": "Только организатор",
  "chatModeParticipants": "Участники",
  "chatModeEveryone": "Открытый чат",
  "chatInputHint": "Сообщение…",
  "chatLockedOnlyAdmin": "Писать может только организатор",
  "chatReadOnlyFinished": "Чат завершён — только чтение",
  "chatEmpty": "Сообщений пока нет",
  "chatDelete": "Удалить",
  "chatOrganizerBadge": "Организатор",
  "chatSendFailed": "Не удалось отправить сообщение",
  "chatRetry": "Повторить"
```
> Проверь запятую после предыдущего ключа. Все 12 ключей — простые строки без плейсхолдеров.

- [ ] **Step 2: Те же ключи в `app_en.arb`**

```json
  "chatTitle": "Tournament chat",
  "chatModeAdmin": "Organizer only",
  "chatModeParticipants": "Participants",
  "chatModeEveryone": "Open chat",
  "chatInputHint": "Message…",
  "chatLockedOnlyAdmin": "Only the organizer can post",
  "chatReadOnlyFinished": "Chat closed — read only",
  "chatEmpty": "No messages yet",
  "chatDelete": "Delete",
  "chatOrganizerBadge": "Organizer",
  "chatSendFailed": "Failed to send message",
  "chatRetry": "Retry"
```

- [ ] **Step 3: Те же ключи в `app_kk.arb`**

```json
  "chatTitle": "Турнир чаты",
  "chatModeAdmin": "Тек ұйымдастырушы",
  "chatModeParticipants": "Қатысушылар",
  "chatModeEveryone": "Ашық чат",
  "chatInputHint": "Хабарлама…",
  "chatLockedOnlyAdmin": "Тек ұйымдастырушы жаза алады",
  "chatReadOnlyFinished": "Чат жабылды — тек оқу",
  "chatEmpty": "Әзірге хабарлама жоқ",
  "chatDelete": "Жою",
  "chatOrganizerBadge": "Ұйымдастырушы",
  "chatSendFailed": "Хабарлама жіберілмеді",
  "chatRetry": "Қайталау"
```

- [ ] **Step 4: Сгенерировать локализации**

Run: `flutter gen-l10n` (или `flutter pub get` — генерация запускается через `generate: true`).
Затем: `flutter analyze lib/l10n`
Expected: файлы `app_localizations*.dart` содержат новые геттеры; analyze без ошибок.

- [ ] **Step 5: Коммит**

```bash
git add lib/l10n/
git commit -m "feat(chat): строки локализации RU/EN/KK"
```

---

## Task 7: Экран чата + пузырь сообщения

**Files:**
- Create: `lib/widgets/tournaments/chat_message_bubble.dart`
- Create: `lib/screens/tournament_chat_screen.dart`

**Interfaces:**
- Consumes: `ChatProvider` (Task 4), `ChatMessage`/`TournamentChat` (Task 1), `AppLocalizations` (Task 6), `AppBackButton`, `AppTheme`, `showAppAlert`.
- Produces: `class TournamentChatScreen extends StatefulWidget { final int tournamentId; final String tournamentName; final TournamentChat chat; }`; `class ChatMessageBubble extends StatelessWidget`.

- [ ] **Step 1: Реализовать пузырь `lib/widgets/tournaments/chat_message_bubble.dart`**

```dart
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/chat_message.dart';
import '../../theme/app_theme.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onLongPress;

  const ChatMessageBubble({super.key, required this.message, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mine = message.isMine;
    final bubbleColor = mine ? AppTheme.accent : AppTheme.card;
    final textColor = mine ? Colors.white : AppTheme.textPrimary;

    final bubble = GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(mine ? 16 : 4),
            bottomRight: Radius.circular(mine ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!mine)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message.user.name,
                      style: TextStyle(
                        color: message.isAdmin
                            ? AppTheme.accent
                            : AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (message.isAdmin) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.accentSoft,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          l10n.chatOrganizerBadge,
                          style: const TextStyle(
                              color: AppTheme.accent,
                              fontSize: 10,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            Text(message.text,
                style: TextStyle(color: textColor, fontSize: 14, height: 1.3)),
          ],
        ),
      ),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: bubble,
    );
  }
}
```

- [ ] **Step 2: Реализовать экран `lib/screens/tournament_chat_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/tournament_chat.dart';
import '../providers/chat_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_alert.dart';
import '../widgets/app_back_button.dart';
import '../widgets/tournaments/chat_message_bubble.dart';

class TournamentChatScreen extends StatefulWidget {
  final int tournamentId;
  final String tournamentName;
  final TournamentChat chat;

  const TournamentChatScreen({
    super.key,
    required this.tournamentId,
    required this.tournamentName,
    required this.chat,
  });

  @override
  State<TournamentChatScreen> createState() => _TournamentChatScreenState();
}

class _TournamentChatScreenState extends State<TournamentChatScreen>
    with WidgetsBindingObserver {
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  ChatProvider get _provider => context.read<ChatProvider>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _provider.loadInitial(widget.tournamentId);
      _jumpToBottom();
      _provider.startPolling(widget.tournamentId);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _provider.startPolling(widget.tournamentId);
    } else if (state == AppLifecycleState.paused) {
      _provider.stopPolling();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _provider.clear();
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _jumpToBottom() {
    if (!_scroll.hasClients) return;
    _scroll.jumpTo(_scroll.position.maxScrollExtent);
  }

  Future<void> _send() async {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    _controller.clear();
    final ok = await _provider.send(widget.tournamentId, text);
    if (!mounted) return;
    if (ok) {
      _jumpToBottom();
    } else {
      showAppAlert(context, AppLocalizations.of(context)!.chatSendFailed);
    }
  }

  String _modeLabel(AppLocalizations l10n) {
    switch (widget.chat.writeMode) {
      case 'admin':
        return l10n.chatModeAdmin;
      case 'everyone':
        return l10n.chatModeEveryone;
      default:
        return l10n.chatModeParticipants;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: const Padding(
            padding: EdgeInsets.only(left: 8), child: AppBackButton()),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.tournamentName,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis),
            Text(_modeLabel(l10n),
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textSecondary)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (_, p, __) {
                if (p.isLoading && p.messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (p.messages.isEmpty) {
                  return Center(
                    child: Text(l10n.chatEmpty,
                        style: const TextStyle(color: AppTheme.textSecondary)),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => p.fetchNewer(widget.tournamentId),
                  child: ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: p.messages.length,
                    itemBuilder: (_, i) {
                      final m = p.messages[i];
                      final canDelete = m.isMine || widget.chat.isAdmin;
                      return ChatMessageBubble(
                        message: m,
                        onLongPress: canDelete
                            ? () => _confirmDelete(m.id, l10n)
                            : null,
                      );
                    },
                  ),
                );
              },
            ),
          ),
          _buildComposer(l10n),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(int messageId, AppLocalizations l10n) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card,
      builder: (ctx) => SafeArea(
        child: ListTile(
          leading: const Icon(Icons.delete_outline, color: AppTheme.error),
          title: Text(l10n.chatDelete,
              style: const TextStyle(color: AppTheme.error)),
          onTap: () {
            Navigator.pop(ctx);
            _provider.delete(widget.tournamentId, messageId);
          },
        ),
      ),
    );
  }

  Widget _buildComposer(AppLocalizations l10n) {
    if (!widget.chat.canWrite) {
      // Две ветки: режим «только организатор» и я не админ → «только
      // организатор»; иначе (турнир завершён) → «только чтение».
      final label = (widget.chat.writeMode == 'admin' && !widget.chat.isAdmin)
          ? l10n.chatLockedOnlyAdmin
          : l10n.chatReadOnlyFinished;
      return Container(
        width: double.infinity,
        color: AppTheme.card,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline,
                size: 16, color: AppTheme.textSecondary),
            const SizedBox(width: 8),
            Flexible(
              child: Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.textSecondary)),
            ),
          ],
        ),
      );
    }

    return Container(
      color: AppTheme.card,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 4,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: l10n.chatInputHint,
                  hintStyle: const TextStyle(color: AppTheme.textDim),
                  filled: true,
                  fillColor: AppTheme.background,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _send,
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                    color: AppTheme.accent, shape: BoxShape.circle),
                child: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Анализ**

Run: `flutter analyze lib/screens/tournament_chat_screen.dart lib/widgets/tournaments/chat_message_bubble.dart`
Expected: без ошибок.

- [ ] **Step 4: Коммит**

```bash
git add lib/screens/tournament_chat_screen.dart lib/widgets/tournaments/chat_message_bubble.dart
git commit -m "feat(chat): экран чата турнира + пузырь сообщения"
```

---

## Task 8: Кнопка чата + бейдж на экране турнира

**Files:**
- Modify: `lib/screens/tournament_detail_screen.dart`

**Interfaces:**
- Consumes: `Tournament.chat` (Task 2), `TournamentChatScreen` (Task 7).
- Produces: круглая кнопка чата в шапке при `chat.canRead == true`, открывающая `TournamentChatScreen`; бейдж `unreadCount`.

- [ ] **Step 1: Импорт экрана**

В начало `lib/screens/tournament_detail_screen.dart`:
```dart
import 'tournament_chat_screen.dart';
```

- [ ] **Step 2: Добавить кнопку чата рядом с share (шапка, ~строка 149)**

Рядом с существующей круглой кнопкой `Icons.ios_share` (`onTap: () => _shareTournament()`), СЛЕВА от неё добавить кнопку чата. Используй тот же круглый стиль-хелпер, что и share (40×40, `AppTheme.card`, `Icons.chat_bubble_outline`). Обернуть в бейдж:
```dart
if (tournament.chat?.canRead == true)
  Padding(
    padding: const EdgeInsets.only(right: 8),
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        _circleHeaderButton(   // тот же хелпер, что рисует share-кнопку
          icon: Icons.chat_bubble_outline,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TournamentChatScreen(
                tournamentId: tournament.id,
                tournamentName: tournament.name,
                chat: tournament.chat!,
              ),
            ),
          ),
        ),
        if ((tournament.chat?.unreadCount ?? 0) > 0)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              decoration: const BoxDecoration(
                  color: AppTheme.accent, shape: BoxShape.circle),
              child: Text(
                '${tournament.chat!.unreadCount}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
      ],
    ),
  ),
```
> Если в файле нет отдельного хелпера для круглой кнопки шапки, а share нарисован инлайн — продублируй ту же обёртку `Container`/`InkWell` (40×40, `shape: BoxShape.circle`, `color: AppTheme.card`, `border` `Color(0xFF2A2A2A)`), подставив иконку `chat_bubble_outline`. Стиль обязан совпасть с share-кнопкой.

- [ ] **Step 3: Анализ + ручная проверка**

Run: `flutter analyze lib/screens/tournament_detail_screen.dart`
Expected: без ошибок.
Ручная проверка (`flutter run`, экран турнира с `chat.can_read=true` в ответе API): кнопка чата видна слева от share; при `unread_count>0` — бейдж; тап открывает экран чата. При `chat==null`/`can_read=false` кнопки нет.

- [ ] **Step 4: Коммит**

```bash
git add lib/screens/tournament_detail_screen.dart
git commit -m "feat(chat): кнопка чата и бейдж непрочитанных на экране турнира"
```

---

## Task 9: Настройки чата в форме создания/редактирования турнира (admin)

**Files:**
- Modify: `lib/screens/admin/admin_create_tournament_screen.dart`

**Interfaces:**
- Consumes: паттерн тумблеров `_ratingToggle` / `_verifiedToggle` (существующие).
- Produces: поля состояния `_chatEnabled` (bool, default true) и `_chatWriteMode` (String, default `'participants'`); отправка `chat_enabled` и `chat_write_mode` в payload создания/обновления турнира. Admin-строки — хардкод (разрешено).

- [ ] **Step 1: Добавить поля состояния**

Рядом с `bool _verifiedOnly = false;` (~строка 56):
```dart
  bool _chatEnabled = true;
  String _chatWriteMode = 'participants'; // admin | participants | everyone
```

- [ ] **Step 2: Блок UI — тумблер + сегменты**

Добавить метод (рядом с `_verifiedToggle`):
```dart
  Widget _chatSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text('Чат турнира',
                  style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
            ),
            Switch(
              value: _chatEnabled,
              activeColor: AppTheme.accent,
              onChanged: (v) => setState(() => _chatEnabled = v),
            ),
          ],
        ),
        if (_chatEnabled) ...[
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'admin', label: Text('Организатор')),
              ButtonSegment(value: 'participants', label: Text('Участники')),
              ButtonSegment(value: 'everyone', label: Text('Все')),
            ],
            selected: {_chatWriteMode},
            onSelectionChanged: (s) =>
                setState(() => _chatWriteMode = s.first),
            showSelectedIcon: false,
          ),
          const SizedBox(height: 6),
          const Text(
            'Кто может писать. Читать могут все, кому доступен чат.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
        ],
      ],
    );
  }
```
Вставить `_chatSettings()` в дерево формы рядом с `_verifiedToggle()` (~строка 509).

- [ ] **Step 3: Добавить поля в payload**

В теле метода, который формирует тело запроса создания/сохранения турнира (там, где кладутся `is_rated`, `verified_only` и т.п.), добавить:
```dart
      'chat_enabled': _chatEnabled,
      'chat_write_mode': _chatWriteMode,
```
Если экран также используется для редактирования и инициализируется из существующего турнира — в `initState`/загрузке проставить `_chatEnabled = tournament.chat?.enabled ?? true;` и `_chatWriteMode = tournament.chat?.writeMode ?? 'participants';`.

- [ ] **Step 4: Анализ + ручная проверка**

Run: `flutter analyze lib/screens/admin/admin_create_tournament_screen.dart`
Expected: без ошибок.
Ручная проверка: в форме создания турнира виден блок «Чат турнира» с тумблером и сегментами; выключение тумблера скрывает сегменты; выбранный режим уходит в payload (проверить через debugPrint тела запроса).

- [ ] **Step 5: Коммит**

```bash
git add lib/screens/admin/admin_create_tournament_screen.dart
git commit -m "feat(chat): настройки чата в форме создания/редактирования турнира"
```

---

## Task 10: Финальная проверка

- [ ] **Step 1: Полный анализ**

Run: `flutter analyze`
Expected: без новых ошибок/ворнингов по добавленным файлам.

- [ ] **Step 2: Все тесты**

Run: `flutter test`
Expected: PASS (модели + провайдер + существующий widget_test).

- [ ] **Step 3: Ручной прогон сценариев** (после готовности бэкенда, Приложение A)

- Турнир с `write_mode=participants`, я участник → кнопка чата, отправка, новые сообщения появляются при опросе/refresh, бейдж обнуляется.
- Турнир `write_mode=admin`, я не админ → плашка «Писать может только организатор», читаю объявления.
- Завершённый турнир → плашка «Чат завершён — только чтение».
- Long-press на своём сообщении → удаление; на чужом (не админ) — меню не появляется.
- `chat.can_read=false` → кнопки чата нет.

- [ ] **Step 4: Финальный коммит (если были правки после проверки)**

```bash
git add -A && git commit -m "test(chat): финальная проверка сценариев чата турнира"
```

---

## Приложение A: Контракт бэкенда (handoff бэкендеру)

Реализуется в отдельном репозитории `padel` (Laravel). Коммит+пуш сразу, миграции деплоить через `--path=` к конкретному файлу.

**Миграции:**
- Таблица `tournament_chat_messages`: `id`, `tournament_id` (FK, index), `user_id` (FK), `text` (text), `deleted_at` (nullable, soft delete), `created_at`.
- Таблица `tournament_chat_reads`: `tournament_id`, `user_id`, `last_read_message_id`, unique(`tournament_id`,`user_id`).
- В `tournaments`: `chat_enabled` (bool, default true), `chat_write_mode` (enum/string: `admin`|`participants`|`everyone`, default `participants`).

**Права (сервер — источник правды):**
- `admin` = пользователь, управляющий клубом турнира (admin/moderator клуба).
- `can_write`: `admin`-режим → только админ; `participants` → админ+участники; `everyone` → любой, кто видит турнир. И всегда `false`, если турнир `completed`.
- `can_read`: та же аудитория, что и `can_write`, НО в режиме `admin` читают также участники (read-only). После `completed` — `can_read` остаётся.

**Блок `chat` в ресурсе турнира** (`GET /tournaments/{id}` и карточки в списках):
```jsonc
"chat": { "enabled": true, "write_mode": "participants",
  "can_read": true, "can_write": true, "is_admin": false, "unread_count": 3 }
```
`unread_count` = число сообщений с `id > last_read_message_id` (кроме своих).

**Эндпоинты:**
- `GET /tournaments/{id}/chat/messages?after_id=&before_id=&limit=50` → `{ "messages": [ ChatMessage ] }` (по возрастанию id; `after_id` — только новее; `before_id` — история). 403 если `can_read=false`.
- `POST /tournaments/{id}/chat/messages` body `{ "text": "…" }` → `{ "message": ChatMessage }`. 403 если `can_write=false`; 422 если пусто/длиннее лимита (предложение: 2000).
- `DELETE /tournaments/{id}/chat/messages/{msgId}` → 204/200. Разрешено автору или админу турнира; иначе 403.
- `POST /tournaments/{id}/chat/read` body `{ "last_message_id": N }` → 200. Обновляет `last_read_message_id`.

**ChatMessage (сериализация):**
```jsonc
{ "id": 1, "user": {"id": 7, "name": "…", "avatar": "…", "level": "3.5"},
  "text": "…", "is_admin": true, "is_mine": false,
  "created_at": "2026-07-01T12:00:00Z" }
```

**Открытые вопросы бэкендера:** rate-limit на отправку (антиспам); лимит длины (предложение 2000); размер страницы истории (предложение 50).
