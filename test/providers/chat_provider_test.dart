import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/models/chat_message.dart';
import 'package:padel_app/providers/chat_provider.dart';
import 'package:padel_app/services/api_service.dart';
import 'package:padel_app/services/chat_service.dart';
import 'package:padel_app/services/storage_service.dart';

// NOTE: deviation from plan — `super(_never(), _never())` (with `_never()`
// throwing) cannot work because Dart evaluates super-constructor arguments
// eagerly, before the subclass body/overrides exist, so it throws on every
// construction regardless of overridden methods. Passing real (but unused)
// ApiService()/StorageService() instances instead: both have no-arg
// constructors that do no I/O at construction time, and FakeChatService
// overrides every method that would otherwise use them, so the real network
// code is still never invoked.
class FakeChatService extends ChatService {
  FakeChatService() : super(ApiService(), StorageService());

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
