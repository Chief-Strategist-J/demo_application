import 'package:flutter_callkit_incoming/entities/entities.dart';

class CallingState {
  final bool isConnected;
  final int durationInSeconds;
  final CallKitParams? callKitParams;

  const CallingState({
    required this.isConnected,
    required this.durationInSeconds,
    this.callKitParams,
  });

  CallingState copyWith({
    bool? isConnected,
    int? durationInSeconds,
    CallKitParams? callKitParams,
  }) {
    return CallingState(
      isConnected: isConnected ?? this.isConnected,
      durationInSeconds: durationInSeconds ?? this.durationInSeconds,
      callKitParams: callKitParams ?? this.callKitParams,
    );
  }

  factory CallingState.initial() => const CallingState(
        isConnected: false,
        durationInSeconds: 0,
        callKitParams: null,
      );
}
