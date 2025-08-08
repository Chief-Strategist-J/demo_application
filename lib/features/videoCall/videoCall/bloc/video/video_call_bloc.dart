import 'package:demo_application/features/videoCall/services/video_call_service.dart';
import 'package:demo_application/features/videoCall/videoCall/bloc/video/video_call_event.dart';
import 'package:demo_application/features/videoCall/videoCall/bloc/video/video_call_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class JoinBloc extends Bloc<JoinEvent, JoinState> {
  JoinBloc() : super(JoinState.initial()) {
    on<CreateMeetingEvent>(_onCreateMeeting);
    on<JoinMeetingEvent>(_onJoinMeeting);
  }

  Future<void> _onCreateMeeting(
    CreateMeetingEvent event,
    Emitter<JoinState> emit,
  ) async {
    try {
      final meetingId = await createMeeting();
      emit(state.copyWith(meetingId: meetingId));
    } catch (_) {
      emit(state.copyWith(error: "Failed to create meeting"));
    }
  }

  void _onJoinMeeting(JoinMeetingEvent event, Emitter<JoinState> emit) {
    final re = RegExp("\\w{4}\\-\\w{4}\\-\\w{4}");
    if (event.meetingId.isNotEmpty && re.hasMatch(event.meetingId)) {
      emit(state.copyWith(meetingId: event.meetingId));
    } else {
      emit(state.copyWith(error: "Please enter valid meeting id"));
    }
  }
}
