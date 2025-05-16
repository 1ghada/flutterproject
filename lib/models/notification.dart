class UserNotification {
  int? id;
  int userId;
  String title;
  String message;
  DateTime createdAt;
  bool isRead;
  String type; // 'reservation_validated', 'reservation_rejected', etc.
  int? relatedId; // ID de la réservation concernée

  UserNotification({
    this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
    required this.type,
    this.relatedId,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'userId': userId,
      'title': title,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead ? 1 : 0,
      'type': type,
      'relatedId': relatedId,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory UserNotification.fromMap(Map<String, dynamic> map) {
    return UserNotification(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      message: map['message'],
      createdAt: DateTime.parse(map['createdAt']),
      isRead: map['isRead'] == 1,
      type: map['type'],
      relatedId: map['relatedId'],
    );
  }
}
