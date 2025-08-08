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
  status:
      $enumDecodeNullable(_$CallStatusEnumMap, json['status']) ??
      CallStatus.initiated,
  meetingId: json['meetingId'] as String?,
  token: json['token'] as String?,
  createdAt: CallRequest._dateTimeFromJson(json['createdAt']),
  answeredAt: CallRequest._dateTimeFromJsonNullable(json['answeredAt']),
  endedAt: CallRequest._dateTimeFromJsonNullable(json['endedAt']),
);

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
      'createdAt': CallRequest._dateTimeToJson(instance.createdAt),
      'answeredAt': CallRequest._dateTimeToJsonNullable(instance.answeredAt),
      'endedAt': CallRequest._dateTimeToJsonNullable(instance.endedAt),
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
