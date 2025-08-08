// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String,
      name: json['name'] as String,
      avatar: json['avatar'] as String,
      fcmToken: json['fcmToken'] as String,
      isOnline: json['isOnline'] as bool? ?? false,
      isInCall: json['isInCall'] as bool? ?? false,
      currentCallId: json['currentCallId'] as String?,
      lastSeen: DateTime.parse(json['lastSeen'] as String),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'avatar': instance.avatar,
      'fcmToken': instance.fcmToken,
      'isOnline': instance.isOnline,
      'isInCall': instance.isInCall,
      'currentCallId': instance.currentCallId,
      'lastSeen': instance.lastSeen.toIso8601String(),
    };
