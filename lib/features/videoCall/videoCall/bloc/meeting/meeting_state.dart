part of 'meeting_bloc.dart';

class MeetingState {
  final Room? room;
  final bool micEnabled;
  final bool camEnabled;
  final Map<String, Participant> participants;
  final bool callEnded;

  const MeetingState({
    this.room,
    this.micEnabled = true,
    this.camEnabled = true,
    this.participants = const {},
    this.callEnded = false,
  });

  MeetingState copyWith({
    Room? room,
    bool? micEnabled,
    bool? camEnabled,
    Map<String, Participant>? participants,
    bool? callEnded,
  }) {
    return MeetingState(
      room: room ?? this.room,
      micEnabled: micEnabled ?? this.micEnabled,
      camEnabled: camEnabled ?? this.camEnabled,
      participants: participants ?? this.participants,
      callEnded: callEnded ?? this.callEnded,
    );
  }
}
