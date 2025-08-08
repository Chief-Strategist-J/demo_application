import 'package:equatable/equatable.dart';
import 'package:demo_application/models/user.dart';
import 'package:demo_application/models/call_request.dart';

abstract class UsersEvent extends Equatable {
  const UsersEvent();

  @override
  List<Object?> get props => [];
}

class LoadUsersEvent extends UsersEvent {}

class InitiateCallEvent extends UsersEvent {
  final User receiver;

  const InitiateCallEvent(this.receiver);

  @override
  List<Object?> get props => [receiver];
}

class CancelCallEvent extends UsersEvent {}

class RefreshUsersEvent extends UsersEvent {}

class CallStatusChanged extends UsersEvent {
  final CallRequest callRequest;

  const CallStatusChanged(this.callRequest);

  @override
  List<Object?> get props => [callRequest];
}
