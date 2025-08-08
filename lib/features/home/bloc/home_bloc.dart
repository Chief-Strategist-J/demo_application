// home_bloc.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:demo_application/features/app_router.dart';
import 'package:demo_application/features/navigation_service.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:uuid/uuid.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final Uuid _uuid = const Uuid();

  HomeBloc() : super(HomeState.initial()) {
    on<InitCallEvent>(_onInitCall);
    on<MakeFakeCallEvent>(_onFakeCall);
    on<EndCurrentCallEvent>(_onEndCall);
    on<StartOutgoingCallEvent>(_onStartOutgoing);
    on<EndAllCallsEvent>(_onEndAll);
    on<AppendCallEventLog>(_onAppendLog);

    _listenCallEvents();
    add(InitCallEvent());
  }

  Future<void> _onInitCall(InitCallEvent event, Emitter<HomeState> emit) async {
    final calls = await FlutterCallkitIncoming.activeCalls();
    if (calls is List && calls.isNotEmpty) {
      emit(state.copyWith(currentUuid: calls[0]['id'], isAnimating: true));
    } else {
      emit(state.copyWith(currentUuid: '', isAnimating: false));
    }
  }

  Future<void> _onFakeCall(
    MakeFakeCallEvent event,
    Emitter<HomeState> emit,
  ) async {
    final newUuid = _uuid.v4();

    await Future.delayed(const Duration(seconds: 10), () async {
      final params = CallKitParams(
        id: newUuid,
        nameCaller: 'Hien Nguyen',
        appName: 'Callkit',
        avatar: 'https://picsum.photos/200',
        handle: '0123456789',
        type: 0,
        duration: 30000,
        textAccept: 'Accept',
        textDecline: 'Decline',
        missedCallNotification: const NotificationParams(
          showNotification: true,
          subtitle: 'Missed call',
          callbackText: 'Call back',
          isShowCallback: true,
        ),
        callingNotification: const NotificationParams(
          showNotification: true,
          subtitle: 'Calling...',
          callbackText: 'Hang Up',
          isShowCallback: true,
        ),
        android: const AndroidParams(isCustomNotification: true),
        ios: const IOSParams(iconName: 'CallKitLogo'),
      );

      await FlutterCallkitIncoming.showCallkitIncoming(params);
      emit(state.copyWith(currentUuid: newUuid, isAnimating: true));

      // Navigate to CallingPage
      NavigationService.instance.pushNamed(AppRoute.callingPage, args: params);
    });
  }

  Future<void> _onEndCall(
    EndCurrentCallEvent event,
    Emitter<HomeState> emit,
  ) async {
    await FlutterCallkitIncoming.endCall(state.currentUuid);
    emit(state.copyWith(currentUuid: '', isAnimating: false));
  }

  Future<void> _onStartOutgoing(
    StartOutgoingCallEvent event,
    Emitter<HomeState> emit,
  ) async {
    final newUuid = _uuid.v4();
    final params = CallKitParams(
      id: newUuid,
      nameCaller: 'Hien Nguyen',
      handle: '0123456789',
      type: 1,
      extra: {'userId': '1a2b3c4d'},
      ios: const IOSParams(handleType: 'generic'),
      callingNotification: const NotificationParams(showNotification: true),
      android: const AndroidParams(
        isCustomNotification: true,
        isShowCallID: true,
      ),
    );

    await FlutterCallkitIncoming.startCall(params);
    emit(state.copyWith(currentUuid: newUuid, isAnimating: true));

    // Navigate to CallingPage
    NavigationService.instance.pushNamed(AppRoute.callingPage, args: params);
  }

  Future<void> _onEndAll(
    EndAllCallsEvent event,
    Emitter<HomeState> emit,
  ) async {
    await FlutterCallkitIncoming.endAllCalls();
    emit(state.copyWith(currentUuid: '', isAnimating: false));
  }

  Future<void> _onAppendLog(
    AppendCallEventLog event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(
        textEvents:
            "${state.textEvents}-----------------------\n${event.log}\n",
      ),
    );
  }

  void _listenCallEvents() {
    FlutterCallkitIncoming.onEvent.listen((event) {
      add(AppendCallEventLog(event.toString()));
    });
  }
}
