import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'call_request.g.dart';

enum CallStatus {
  initiated,
  ringing,
  accepted,
  declined,
  missed,
  ended,
  cancelled
}

@JsonSerializable()
class CallRequest {
  final String id;
  final String callerId;
  final String callerName;
  final String callerAvatar;
  final String receiverId;
  final String receiverName;
  final String receiverAvatar;
  final CallStatus status;
  final String? meetingId;
  final String? token;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime createdAt;
  @JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable)
  final DateTime? answeredAt;
  @JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable)
  final DateTime? endedAt;

  const CallRequest({
    required this.id,
    required this.callerId,
    required this.callerName,
    required this.callerAvatar,
    required this.receiverId,
    required this.receiverName,
    required this.receiverAvatar,
    this.status = CallStatus.initiated,
    this.meetingId,
    this.token,
    required this.createdAt,
    this.answeredAt,
    this.endedAt,
  });

  factory CallRequest.fromJson(Map<String, dynamic> json) => _$CallRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CallRequestToJson(this);

  CallRequest copyWith({
    String? id,
    String? callerId,
    String? callerName,
    String? callerAvatar,
    String? receiverId,
    String? receiverName,
    String? receiverAvatar,
    CallStatus? status,
    String? meetingId,
    String? token,
    DateTime? createdAt,
    DateTime? answeredAt,
    DateTime? endedAt,
  }) {
    return CallRequest(
      id: id ?? this.id,
      callerId: callerId ?? this.callerId,
      callerName: callerName ?? this.callerName,
      callerAvatar: callerAvatar ?? this.callerAvatar,
      receiverId: receiverId ?? this.receiverId,
      receiverName: receiverName ?? this.receiverName,
      receiverAvatar: receiverAvatar ?? this.receiverAvatar,
      status: status ?? this.status,
      meetingId: meetingId ?? this.meetingId,
      token: token ?? this.token,
      createdAt: createdAt ?? this.createdAt,
      answeredAt: answeredAt ?? this.answeredAt,
      endedAt: endedAt ?? this.endedAt,
    );
  }

  @override
  String toString() {
    return 'CallRequest(id: $id, caller: $callerName, receiver: $receiverName, status: $status)';
  }

  bool get isActive => status == CallStatus.initiated || status == CallStatus.ringing || status == CallStatus.accepted;
  
  bool get isFinished => status == CallStatus.declined || status == CallStatus.missed || status == CallStatus.ended || status == CallStatus.cancelled;

  // Helper methods for DateTime conversion
  static DateTime _dateTimeFromJson(dynamic json) {
    if (json == null) return DateTime.now();
    
    // Handle Firestore Timestamp
    if (json is Timestamp) {
      return json.toDate();
    }
    
    // Handle string ISO format
    if (json is String) {
      return DateTime.parse(json);
    }
    
    // Handle milliseconds since epoch
    if (json is int) {
      return DateTime.fromMillisecondsSinceEpoch(json);
    }
    
    // Fallback
    return DateTime.now();
  }
  
  static DateTime? _dateTimeFromJsonNullable(dynamic json) {
    if (json == null) return null;
    return _dateTimeFromJson(json);
  }
  
  static dynamic _dateTimeToJson(DateTime dateTime) {
    return Timestamp.fromDate(dateTime);
  }
  
  static dynamic _dateTimeToJsonNullable(DateTime? dateTime) {
    if (dateTime == null) return null;
    return Timestamp.fromDate(dateTime);
  }
}
