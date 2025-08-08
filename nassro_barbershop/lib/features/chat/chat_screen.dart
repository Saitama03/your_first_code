import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/models.dart';
import 'dart:async';
import 'package:async/async.dart';

final _chatProvider = StreamProvider.autoDispose<List<MessageModel>>((ref) {
  // Stream all messages where I'm sender or recipient
  final myId = Supabase.instance.client.auth.currentUser?.id;
  if (myId == null) return const Stream.empty();

  final sentStream = Supabase.instance.client
      .from('messages')
      .stream(primaryKey: ['id'])
      .inFilter('sender_id', [myId])
      .order('created_at')
      .map((rows) => rows
          .map((e) => MessageModel.fromMap(e as Map<String, dynamic>))
          .toList());

  final receivedStream = Supabase.instance.client
      .from('messages')
      .stream(primaryKey: ['id'])
      .inFilter('recipient_id', [myId])
      .order('created_at')
      .map((rows) => rows
          .map((e) => MessageModel.fromMap(e as Map<String, dynamic>))
          .toList());

  return StreamZip<List<MessageModel>>([sentStream, receivedStream])
      .map((lists) => [...lists[0], ...lists[1]]
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt)));
});

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final controller = TextEditingController();

  Future<void> _send() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;
    final client = Supabase.instance.client;
    final myId = client.auth.currentUser?.id;
    if (myId == null) return;
    // Find admin user (first admin profile)
    final admins =
        await client.from('profiles').select('id').eq('role', 'admin').limit(1);
    if (admins is List && admins.isNotEmpty) {
      final toUserId = (admins.first as Map<String, dynamic>)['id'] as String;
      await client.from('messages').insert({
        'sender_id': myId,
        'recipient_id': toUserId,
        'content': text,
      });
      controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncMessages = ref.watch(_chatProvider);
    final myId = Supabase.instance.client.auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: asyncMessages.when(
              data: (items) => ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final m = items[i];
                  final isMine = m.senderId == myId;
                  return Align(
                    alignment:
                        isMine ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: isMine
                            ? Colors.blue.shade600
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        m.content,
                        style: TextStyle(
                            color: isMine ? Colors.white : Colors.black87),
                      ),
                    ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration:
                        const InputDecoration(hintText: 'Type a message'),
                  ),
                ),
                IconButton(onPressed: _send, icon: const Icon(Icons.send)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
