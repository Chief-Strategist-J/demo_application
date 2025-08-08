part of 'meeting_bloc.dart';

class MeetingState {
  final Room? room;
  final bool micEnabled;
  final bool camEnabled;
  final Map<String, Participant> participants;

  const MeetingState({
    this.room,
    this.micEnabled = true,
    this.camEnabled = true,
    this.participants = const {},
  });

  MeetingState copyWith({
    Room? room,
    bool? micEnabled,
    bool? camEnabled,
    Map<String, Participant>? participants,
  }) {
    return MeetingState(
      room: room ?? this.room,
      micEnabled: micEnabled ?? this.micEnabled,
      camEnabled: camEnabled ?? this.camEnabled,
      participants: participants ?? this.participants,
    );
  }
}
