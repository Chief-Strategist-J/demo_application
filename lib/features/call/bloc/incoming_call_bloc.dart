import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:demo_application/features/call/bloc/incoming_call_event.dart';
import 'package:demo_application/features/call/bloc/incoming_call_state.dart';
import 'package:demo_application/services/firebase_service.dart';

class IncomingCallBloc extends Bloc<IncomingCallEvent, IncomingCallState> {
  final FirebaseService _firebaseService = FirebaseService();

  IncomingCallBloc() : super(const IncomingCallState()) {
    on<InitializeIncomingCall>(_onInitializeIncomingCall);
    on<AcceptCall>(_onAcceptCall);
    on<DeclineCall>(_onDeclineCall);
  }

  void _onInitializeIncomingCall(
    InitializeIncomingCall event,
    Emitter<IncomingCallState> emit,
  ) {
    emit(state.copyWith(callRequest: event.callRequest));
  }

  Future<void> _onAcceptCall(
    AcceptCall event,
    Emitter<IncomingCallState> emit,
  ) async {
    if (state.callRequest == null) return;

    emit(state.copyWith(loading: true));

    try {
      await _firebaseService.acceptCall(state.callRequest!.id);
      emit(state.copyWith(
        loading: false,
        callAccepted: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: 'Failed to accept call: $e',
      ));
    }
  }

  Future<void> _onDeclineCall(
    DeclineCall event,
    Emitter<IncomingCallState> emit,
  ) async {
    if (state.callRequest == null) return;

    emit(state.copyWith(loading: true));

    try {
      await _firebaseService.declineCall(state.callRequest!.id);
      emit(state.copyWith(
        loading: false,
        callEnded: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: 'Failed to decline call: $e',
      ));
    }
  }
}
