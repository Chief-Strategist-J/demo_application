import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String name;
  final String avatar;
  final String fcmToken;
  final bool isOnline;
  final bool isInCall;
  final String? currentCallId;
  final DateTime lastSeen;

  const User({
    required this.id,
    required this.name,
    required this.avatar,
    required this.fcmToken,
    this.isOnline = false,
    this.isInCall = false,
    this.currentCallId,
    required this.lastSeen,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? id,
    String? name,
    String? avatar,
    String? fcmToken,
    bool? isOnline,
    bool? isInCall,
    String? currentCallId,
    DateTime? lastSeen,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      fcmToken: fcmToken ?? this.fcmToken,
      isOnline: isOnline ?? this.isOnline,
      isInCall: isInCall ?? this.isInCall,
      currentCallId: currentCallId ?? this.currentCallId,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, isOnline: $isOnline, isInCall: $isInCall)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
