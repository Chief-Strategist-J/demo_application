import 'package:equatable/equatable.dart';
import 'package:demo_application/models/call_request.dart';

class IncomingCallState extends Equatable {
  final CallRequest? callRequest;
  final bool loading;
  final String? error;
  final bool callAccepted;
  final bool callEnded;

  const IncomingCallState({
    this.callRequest,
    this.loading = false,
    this.error,
    this.callAccepted = false,
    this.callEnded = false,
  });

  IncomingCallState copyWith({
    CallRequest? callRequest,
    bool? loading,
    String? error,
    bool? callAccepted,
    bool? callEnded,
  }) {
    return IncomingCallState(
      callRequest: callRequest ?? this.callRequest,
      loading: loading ?? this.loading,
      error: error,
      callAccepted: callAccepted ?? this.callAccepted,
      callEnded: callEnded ?? this.callEnded,
    );
  }

  @override
  List<Object?> get props => [
        callRequest,
        loading,
        error,
        callAccepted,
        callEnded,
      ];
}
