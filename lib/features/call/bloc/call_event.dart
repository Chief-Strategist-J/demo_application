import 'package:flutter_callkit_incoming/entities/entities.dart';

abstract class CallingEvent {}

class InitializeCalling extends CallingEvent {
  final CallKitParams callKitParams;

  InitializeCalling(this.callKitParams);
}

class ConnectCall extends CallingEvent {}

class TickTimer extends CallingEvent {}

class EndCall extends CallingEvent {}
