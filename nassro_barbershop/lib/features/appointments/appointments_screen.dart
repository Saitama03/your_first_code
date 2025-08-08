import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/models.dart';
import '../../data/repositories/supabase_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final myAppointmentsProvider =
    FutureProvider<List<AppointmentModel>>((ref) async {
  final repo = SupabaseRepository(Supabase.instance.client);
  return repo.getMyAppointments();
});

class AppointmentsScreen extends ConsumerWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncAppts = ref.watch(myAppointmentsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My Appointments')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: push booking screen
        },
        label: const Text('Book'),
        icon: const Icon(Icons.add),
      ),
      body: asyncAppts.when(
        data: (items) => ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, i) {
            final a = items[i];
            final time =
                '${DateFormat.yMMMEd().format(a.startAt)} • ${DateFormat.Hm().format(a.startAt)} - ${DateFormat.Hm().format(a.endAt)}';
            return ListTile(
              title: Text(a.status.toUpperCase()),
              subtitle: Text(time),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
