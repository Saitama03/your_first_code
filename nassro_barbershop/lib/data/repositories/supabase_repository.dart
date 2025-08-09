import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class SupabaseRepository {
  SupabaseRepository(this.client);

  final SupabaseClient client;

  Future<ProfileModel?> getMyProfile() async {
    final user = client.auth.currentUser;
    if (user == null) return null;
    final res = await client
        .from('profiles')
        .select('*')
        .eq('id', user.id)
        .maybeSingle();
    final map = res as Map<String, dynamic>?;
    return map == null ? null : ProfileModel.fromMap(map);
  }

  Future<void> upsertMyProfile({String? fullName, String? avatarUrl}) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');
    await client.from('profiles').upsert({
      'id': user.id,
      if (fullName != null) 'full_name': fullName,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    });
  }

  // Services
  Future<List<ServiceModel>> getServices() async {
    final res = await client
        .from('services')
        .select('*')
        .eq('is_active', true)
        .order('created_at');
    return (res as List)
        .cast<Map<String, dynamic>>()
        .map(ServiceModel.fromMap)
        .toList();
  }

  Future<void> adminUpsertService(ServiceModel service) async {
    await client.from('services').upsert({
      'id': service.id,
      'name': service.name,
      'description': service.description,
      'price_cents': service.priceCents,
      'duration_minutes': service.durationMinutes,
      'is_active': service.isActive,
    });
  }

  Future<void> adminDeleteService(String id) async {
    await client.from('services').delete().eq('id', id);
  }

  // Appointments
  Future<List<AppointmentModel>> getMyAppointments() async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return [];
    final res = await client
        .from('appointments')
        .select('*')
        .eq('client_id', userId)
        .order('start_at');
    return (res as List)
        .cast<Map<String, dynamic>>()
        .map(AppointmentModel.fromMap)
        .toList();
  }

  Future<void> bookAppointment({
    required String serviceId,
    required DateTime startAt,
    required DateTime endAt,
    String? notes,
  }) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');
    await client.from('appointments').insert({
      'client_id': userId,
      'service_id': serviceId,
      'start_at': startAt.toIso8601String(),
      'end_at': endAt.toIso8601String(),
      if (notes != null) 'notes': notes,
    });
  }

  Future<List<AppointmentModel>> adminAllAppointments() async {
    final res = await client.from('appointments').select('*').order('start_at');
    return (res as List)
        .cast<Map<String, dynamic>>()
        .map(AppointmentModel.fromMap)
        .toList();
  }

  Future<void> adminUpdateAppointmentStatus(String id, String status) async {
    await client.from('appointments').update({'status': status}).eq('id', id);
  }

  // Reviews
  Future<List<ReviewModel>> getReviews() async {
    final res = await client
        .from('reviews')
        .select('*')
        .order('created_at', ascending: false);
    return (res as List)
        .cast<Map<String, dynamic>>()
        .map(ReviewModel.fromMap)
        .toList();
  }

  Future<void> addReview(
      {required String appointmentId,
      required int rating,
      String? comment}) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');
    await client.from('reviews').insert({
      'appointment_id': appointmentId,
      'client_id': userId,
      'rating': rating,
      if (comment != null) 'comment': comment,
    });
  }

  // Messages
  Stream<MessageModel> subscribeToMessages(String withUserId) {
    final myId = client.auth.currentUser?.id;
    if (myId == null) {
      return const Stream.empty();
    }
    return client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('recipient_id', myId)
        .order('created_at')
        .map((rows) =>
            rows.map((e) => MessageModel.fromMap(e as Map<String, dynamic>)))
        .asyncExpand((iter) => Stream.fromIterable(iter));
  }

  Future<void> sendMessage(
      {required String toUserId, required String content}) async {
    final myId = client.auth.currentUser?.id;
    if (myId == null) throw Exception('Not authenticated');
    await client.from('messages').insert({
      'sender_id': myId,
      'recipient_id': toUserId,
      'content': content,
    });
  }

  // Notifications
  Future<List<NotificationItem>> myNotifications() async {
    final myId = client.auth.currentUser?.id;
    if (myId == null) return [];
    final res = await client
        .from('notifications')
        .select('*')
        .eq('user_id', myId)
        .order('created_at', ascending: false);
    return (res as List)
        .cast<Map<String, dynamic>>()
        .map(NotificationItem.fromMap)
        .toList();
  }
}
