import 'user.dart';
import 'resource.dart';

class Reservation {
  final String id;
  final User user;
  final Resource resource;
  final DateTime startTime;
  final DateTime endTime;
  final bool approvedByManager;

  Reservation({
    required this.id,
    required this.user,
    required this.resource,
    required this.startTime,
    required this.endTime,
    this.approvedByManager = false,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      user: User.fromJson(json['user']),
      resource: Resource.fromJson(json['resource']),
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      approvedByManager: json['approvedByManager'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user': user.toJson(),
    'resource': resource.toJson(),
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'approvedByManager': approvedByManager,
  };
}
