part of 'meeting_bloc.dart';

abstract class MeetingEvent {
  const MeetingEvent();
}

class InitMeetingEvent extends MeetingEvent {
  final String meetingId;
  final String token;
  final String? callId;

  const InitMeetingEvent({
    required this.meetingId, 
    required this.token,
    this.callId,
  });
}

class ParticipantJoinedEvent extends MeetingEvent {
  final Participant participant;

  const ParticipantJoinedEvent(this.participant);
}

class ParticipantLeftEvent extends MeetingEvent {
  final String participantId;

  const ParticipantLeftEvent(this.participantId);
}

class ToggleMicEvent extends MeetingEvent {}

class ToggleCameraEvent extends MeetingEvent {}

class LeaveMeetingEvent extends MeetingEvent {}

class CallEndedRemotelyEvent extends MeetingEvent {
  const CallEndedRemotelyEvent();
}
