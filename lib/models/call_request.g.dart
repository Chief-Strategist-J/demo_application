// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CallRequest _$CallRequestFromJson(Map<String, dynamic> json) => CallRequest(
      id: json['id'] as String,
      callerId: json['callerId'] as String,
      callerName: json['callerName'] as String,
      callerAvatar: json['callerAvatar'] as String,
      receiverId: json['receiverId'] as String,
      receiverName: json['receiverName'] as String,
      receiverAvatar: json['receiverAvatar'] as String,
      status: _$enumDecodeNullable(_$CallStatusEnumMap, json['status']) ??
          CallStatus.initiated,
      meetingId: json['meetingId'] as String?,
      token: json['token'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      answeredAt: json['answeredAt'] == null
          ? null
          : DateTime.parse(json['answeredAt'] as String),
      endedAt: json['endedAt'] == null
          ? null
          : DateTime.parse(json['endedAt'] as String),
    );

T? _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source,
) {
  if (source == null) return null;
  return enumValues.entries
      .singleWhere(
        (e) => e.value == source,
        orElse: () => throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        ),
      )
      .key;
}

Map<String, dynamic> _$CallRequestToJson(CallRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'callerId': instance.callerId,
      'callerName': instance.callerName,
      'callerAvatar': instance.callerAvatar,
      'receiverId': instance.receiverId,
      'receiverName': instance.receiverName,
      'receiverAvatar': instance.receiverAvatar,
      'status': _$CallStatusEnumMap[instance.status]!,
      'meetingId': instance.meetingId,
      'token': instance.token,
      'createdAt': instance.createdAt.toIso8601String(),
      'answeredAt': instance.answeredAt?.toIso8601String(),
      'endedAt': instance.endedAt?.toIso8601String(),
    };

const _$CallStatusEnumMap = {
  CallStatus.initiated: 'initiated',
  CallStatus.ringing: 'ringing',
  CallStatus.accepted: 'accepted',
  CallStatus.declined: 'declined',
  CallStatus.missed: 'missed',
  CallStatus.ended: 'ended',
  CallStatus.cancelled: 'cancelled',
};
