// home_event.dart
part of 'home_bloc.dart';

sealed class HomeEvent {}

class InitCallEvent extends HomeEvent {}

class MakeFakeCallEvent extends HomeEvent {}

class EndCurrentCallEvent extends HomeEvent {}

class StartOutgoingCallEvent extends HomeEvent {}

class ActiveCallsEvent extends HomeEvent {}

class EndAllCallsEvent extends HomeEvent {}

class AppendCallEventLog extends HomeEvent {
  final String log;
  AppendCallEventLog(this.log);
}
