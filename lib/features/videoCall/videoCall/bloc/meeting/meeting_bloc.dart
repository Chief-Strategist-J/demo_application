import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:videosdk/videosdk.dart';
import 'package:demo_application/services/firebase_service.dart';
import 'package:demo_application/models/call_request.dart';

part 'meeting_event.dart';
part 'meeting_state.dart';

class MeetingBloc extends Bloc<MeetingEvent, MeetingState> {
  final FirebaseService _firebaseService = FirebaseService();
  String? _currentCallId;
  StreamSubscription<CallRequest?>? _callStatusSubscription;
  
  MeetingBloc() : super(const MeetingState()) {
    on<InitMeetingEvent>(_onInitMeeting);
    on<ParticipantJoinedEvent>(_onParticipantJoined);
    on<ParticipantLeftEvent>(_onParticipantLeft);
    on<ToggleMicEvent>(_onToggleMic);
    on<ToggleCameraEvent>(_onToggleCamera);
    on<LeaveMeetingEvent>(_onLeaveMeeting);
    on<CallEndedRemotelyEvent>(_onCallEndedRemotely);
  }

  Future<void> _onInitMeeting(
    InitMeetingEvent event,
    Emitter<MeetingState> emit,
  ) async {
    _currentCallId = event.callId;
    
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
      // Don't auto trigger leave meeting, let user handle it
    });

    room.join();

    // Set up call status monitoring if we have a call ID
    if (_currentCallId != null) {
      _setupCallStatusMonitoring(_currentCallId!);
    }

    emit(state.copyWith(room: room, callEnded: false));
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

  Future<void> _onLeaveMeeting(
    LeaveMeetingEvent event,
    Emitter<MeetingState> emit,
  ) async {
    try {
      // Stop monitoring call status
      _stopCallStatusMonitoring();
      
      // Leave the video room
      state.room?.leave();
      
      // End the call in Firebase if we have a call ID
      if (_currentCallId != null) {
        await _firebaseService.endCall(_currentCallId!);
      }
      
      // Reset state and mark call as ended
      emit(state.copyWith(callEnded: true));
      
      // Clear the call ID
      _currentCallId = null;
      
    } catch (e) {
      print('Error leaving meeting: $e');
      // Still reset state even if Firebase operation fails
      emit(state.copyWith(callEnded: true));
    }
  }
  
  void _onCallEndedRemotely(
    CallEndedRemotelyEvent event,
    Emitter<MeetingState> emit,
  ) {
    // Stop monitoring call status
    _stopCallStatusMonitoring();
    
    // Leave the video room without updating Firebase (already ended)
    state.room?.leave();
    
    // Mark call as ended
    emit(state.copyWith(callEnded: true));
    
    // Clear the call ID
    _currentCallId = null;
  }
  
  void _setupCallStatusMonitoring(String callId) {
    _callStatusSubscription?.cancel();
    _callStatusSubscription = _firebaseService
        .listenForCallStatusUpdates(callId)
        .listen(
          (callRequest) {
            // Only trigger remote call end if the call was ended/declined and we didn't initiate it
            if (callRequest != null && 
                (callRequest.status == CallStatus.ended || callRequest.status == CallStatus.declined)) {
              print('Call ended remotely: ${callRequest.status}');
              add(const CallEndedRemotelyEvent());
            }
          },
          onError: (error) {
            print('Error monitoring call status: $error');
          },
        );
  }
  
  void _stopCallStatusMonitoring() {
    _callStatusSubscription?.cancel();
    _callStatusSubscription = null;
  }
  
  @override
  Future<void> close() {
    // Cleanup when BLoC is disposed
    _stopCallStatusMonitoring();
    state.room?.leave();
    _currentCallId = null;
    return super.close();
  }
}
