import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/models.dart';
import '../../data/repositories/supabase_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final reviewsProvider = FutureProvider<List<ReviewModel>>((ref) async {
  final repo = SupabaseRepository(Supabase.instance.client);
  return repo.getReviews();
});

class ReviewsScreen extends ConsumerWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncReviews = ref.watch(reviewsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Reviews')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: navigate to add review screen after completed appointment
        },
        child: const Icon(Icons.add_comment),
      ),
      body: asyncReviews.when(
        data: (items) => ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, i) {
            final r = items[i];
            return ListTile(
              title: Row(
                children: List.generate(
                    5,
                    (idx) => Icon(
                          idx < r.rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 20,
                        )),
              ),
              subtitle: Text(r.comment ?? ''),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
