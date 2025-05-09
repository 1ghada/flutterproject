class Reservation {
  final int? id;
  final int userId;
  final int resourceId;
  final String date;
  final String timeSlot;
  final String status; // ✅ Nouveau champ

  Reservation({
    this.id,
    required this.userId,
    required this.resourceId,
    required this.date,
    required this.timeSlot,
    this.status = 'en_attente', // valeur par défaut
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'resourceId': resourceId,
      'date': date,
      'timeSlot': timeSlot,
      'status': status,
    };
  }

  factory Reservation.fromMap(Map<String, dynamic> map) {
    return Reservation(
      id: map['id'],
      userId: map['userId'],
      resourceId: map['resourceId'],
      date: map['date'],
      timeSlot: map['timeSlot'],
      status: map['status'] ?? 'en_attente',
    );
  }
}
