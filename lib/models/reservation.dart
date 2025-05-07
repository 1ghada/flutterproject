class Reservation {
  final int? id;
  final int userId;
  final int resourceId;
  final String date;
  final String timeSlot;

  Reservation({
    this.id,
    required this.userId,
    required this.resourceId,
    required this.date,
    required this.timeSlot,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'resourceId': resourceId,
      'date': date,
      'timeSlot': timeSlot,
    };
  }

  factory Reservation.fromMap(Map<String, dynamic> map) {
    return Reservation(
      id: map['id'],
      userId: map['userId'],
      resourceId: map['resourceId'],
      date: map['date'],
      timeSlot: map['timeSlot'],
    );
  }
}
