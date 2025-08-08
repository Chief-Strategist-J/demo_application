import 'dart:async';
import 'package:demo_application/features/call/bloc/call_event.dart';
import 'package:demo_application/features/call/bloc/call_state.dart';
import 'package:demo_application/features/navigation_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';

class CallingBloc extends Bloc<CallingEvent, CallingState> {
  Timer? _timer;

  CallingBloc() : super(CallingState.initial()) {
    on<InitializeCalling>(_onInit);
    on<ConnectCall>(_onConnect);
    on<TickTimer>(_onTick);
    on<EndCall>(_onEndCall);
  }

  void _onInit(InitializeCalling event, Emitter<CallingState> emit) {
    emit(state.copyWith(callKitParams: event.callKitParams));
  }

  void _onConnect(ConnectCall event, Emitter<CallingState> emit) async {
    if (state.callKitParams != null) {
      await FlutterCallkitIncoming.setCallConnected(state.callKitParams!.id!);
      _startTimer();
      emit(state.copyWith(isConnected: true));
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(TickTimer());
    });
  }

  void _onTick(TickTimer event, Emitter<CallingState> emit) {
    emit(state.copyWith(durationInSeconds: state.durationInSeconds + 1));
  }

  void _onEndCall(EndCall event, Emitter<CallingState> emit) async {
    _timer?.cancel();

    await FlutterCallkitIncoming.endAllCalls();
    NavigationService.instance.goBack();

    emit(CallingState.initial());
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
