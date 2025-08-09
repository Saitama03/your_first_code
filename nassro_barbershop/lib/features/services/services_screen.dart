import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/models.dart';
import '../../data/repositories/supabase_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final servicesProvider = FutureProvider<List<ServiceModel>>((ref) async {
  final repo = SupabaseRepository(Supabase.instance.client);
  return repo.getServices();
});

class ServicesScreen extends ConsumerWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncServices = ref.watch(servicesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Services')),
      body: asyncServices.when(
        data: (items) => ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final s = items[index];
            return ListTile(
              title: Text(s.name),
              subtitle: Text(s.description ?? ''),
              trailing: Text('€ ${(s.priceCents / 100).toStringAsFixed(2)}'),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
