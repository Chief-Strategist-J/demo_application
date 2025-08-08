import 'package:equatable/equatable.dart';
import 'package:demo_application/models/call_request.dart';

abstract class IncomingCallEvent extends Equatable {
  const IncomingCallEvent();

  @override
  List<Object?> get props => [];
}

class InitializeIncomingCall extends IncomingCallEvent {
  final CallRequest callRequest;

  const InitializeIncomingCall(this.callRequest);

  @override
  List<Object?> get props => [callRequest];
}

class AcceptCall extends IncomingCallEvent {}

class DeclineCall extends IncomingCallEvent {}
