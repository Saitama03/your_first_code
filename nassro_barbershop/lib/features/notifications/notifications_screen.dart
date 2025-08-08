import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/models.dart';
import '../../data/repositories/supabase_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final notificationsProvider =
    FutureProvider<List<NotificationItem>>((ref) async {
  final repo = SupabaseRepository(Supabase.instance.client);
  return repo.myNotifications();
});

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncItems = ref.watch(notificationsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: asyncItems.when(
        data: (items) => ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, i) {
            final n = items[i];
            return ListTile(
              title: Text(n.title),
              subtitle: Text(n.body),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
