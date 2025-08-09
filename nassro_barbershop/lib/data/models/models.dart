class ProfileModel {
  final String id;
  final String? fullName;
  final String? avatarUrl;
  final String role; // 'client' | 'admin'

  ProfileModel(
      {required this.id, this.fullName, this.avatarUrl, required this.role});

  factory ProfileModel.fromMap(Map<String, dynamic> map) => ProfileModel(
        id: map['id'] as String,
        fullName: map['full_name'] as String?,
        avatarUrl: map['avatar_url'] as String?,
        role: map['role'] as String,
      );
}

class ServiceModel {
  final String id;
  final String name;
  final String? description;
  final int priceCents;
  final int durationMinutes;
  final bool isActive;

  ServiceModel({
    required this.id,
    required this.name,
    this.description,
    required this.priceCents,
    required this.durationMinutes,
    required this.isActive,
  });

  factory ServiceModel.fromMap(Map<String, dynamic> map) => ServiceModel(
        id: map['id'] as String,
        name: map['name'] as String,
        description: map['description'] as String?,
        priceCents: map['price_cents'] as int,
        durationMinutes: map['duration_minutes'] as int,
        isActive: map['is_active'] as bool,
      );
}

class AppointmentModel {
  final String id;
  final String clientId;
  final String serviceId;
  final DateTime startAt;
  final DateTime endAt;
  final String status; // pending | approved | rejected | completed | cancelled
  final String? notes;

  AppointmentModel({
    required this.id,
    required this.clientId,
    required this.serviceId,
    required this.startAt,
    required this.endAt,
    required this.status,
    this.notes,
  });

  factory AppointmentModel.fromMap(Map<String, dynamic> map) =>
      AppointmentModel(
        id: map['id'] as String,
        clientId: map['client_id'] as String,
        serviceId: map['service_id'] as String,
        startAt: DateTime.parse(map['start_at'] as String),
        endAt: DateTime.parse(map['end_at'] as String),
        status: map['status'] as String,
        notes: map['notes'] as String?,
      );
}

class ReviewModel {
  final String id;
  final String appointmentId;
  final String clientId;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.appointmentId,
    required this.clientId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map) => ReviewModel(
        id: map['id'] as String,
        appointmentId: map['appointment_id'] as String,
        clientId: map['client_id'] as String,
        rating: map['rating'] as int,
        comment: map['comment'] as String?,
        createdAt: DateTime.parse(map['created_at'] as String),
      );
}

class MessageModel {
  final String id;
  final String senderId;
  final String recipientId;
  final String content;
  final DateTime createdAt;
  final DateTime? readAt;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.content,
    required this.createdAt,
    this.readAt,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) => MessageModel(
        id: map['id'] as String,
        senderId: map['sender_id'] as String,
        recipientId: map['recipient_id'] as String,
        content: map['content'] as String,
        createdAt: DateTime.parse(map['created_at'] as String),
        readAt: map['read_at'] != null
            ? DateTime.parse(map['read_at'] as String)
            : null,
      );
}

class NotificationItem {
  final String id;
  final String userId;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool read;

  NotificationItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.read,
  });

  factory NotificationItem.fromMap(Map<String, dynamic> map) =>
      NotificationItem(
        id: map['id'] as String,
        userId: map['user_id'] as String,
        title: map['title'] as String,
        body: map['body'] as String,
        createdAt: DateTime.parse(map['created_at'] as String),
        read: map['read'] as bool,
      );
}
