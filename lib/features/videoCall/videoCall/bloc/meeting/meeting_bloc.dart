import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:videosdk/videosdk.dart';

part 'meeting_event.dart';
part 'meeting_state.dart';

class MeetingBloc extends Bloc<MeetingEvent, MeetingState> {
  MeetingBloc() : super(const MeetingState()) {
    on<InitMeetingEvent>(_onInitMeeting);
    on<ParticipantJoinedEvent>(_onParticipantJoined);
    on<ParticipantLeftEvent>(_onParticipantLeft);
    on<ToggleMicEvent>(_onToggleMic);
    on<ToggleCameraEvent>(_onToggleCamera);
    on<LeaveMeetingEvent>(_onLeaveMeeting);
  }

  Future<void> _onInitMeeting(
    InitMeetingEvent event,
    Emitter<MeetingState> emit,
  ) async {
    final room = VideoSDK.createRoom(
      roomId: event.meetingId,
      token: event.token,
      displayName: "John Doe",
      micEnabled: state.micEnabled,
      camEnabled: state.camEnabled,
      defaultCameraIndex: kIsWeb ? 0 : 1,
    );

    // Listen to room events
    room.on(Events.roomJoined, () {
      add(ParticipantJoinedEvent(room.localParticipant));
    });

    room.on(Events.participantJoined, (Participant participant) {
      add(ParticipantJoinedEvent(participant));
    });

    room.on(Events.participantLeft, (String participantId) {
      add(ParticipantLeftEvent(participantId));
    });

    room.on(Events.roomLeft, () {
      add(LeaveMeetingEvent());
    });

    room.join();

    emit(state.copyWith(room: room));
  }

  void _onParticipantJoined(
    ParticipantJoinedEvent event,
    Emitter<MeetingState> emit,
  ) {
    final updated = Map<String, Participant>.from(state.participants);
    updated[event.participant.id] = event.participant;
    emit(state.copyWith(participants: updated));
  }

  void _onParticipantLeft(
    ParticipantLeftEvent event,
    Emitter<MeetingState> emit,
  ) {
    final updated = Map<String, Participant>.from(state.participants);
    updated.remove(event.participantId);
    emit(state.copyWith(participants: updated));
  }

  void _onToggleMic(
    ToggleMicEvent event,
    Emitter<MeetingState> emit,
  ) {
    final micOn = !state.micEnabled;
    if (micOn) {
      state.room?.unmuteMic();
    } else {
      state.room?.muteMic();
    }
    emit(state.copyWith(micEnabled: micOn));
  }

  void _onToggleCamera(
    ToggleCameraEvent event,
    Emitter<MeetingState> emit,
  ) {
    final camOn = !state.camEnabled;
    if (camOn) {
      state.room?.enableCam();
    } else {
      state.room?.disableCam();
    }
    emit(state.copyWith(camEnabled: camOn));
  }

  void _onLeaveMeeting(
    LeaveMeetingEvent event,
    Emitter<MeetingState> emit,
  ) {
    state.room?.leave();
    emit(const MeetingState()); // Reset state
  }
}
