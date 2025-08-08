import 'package:equatable/equatable.dart';
import 'package:demo_application/models/user.dart';
import 'package:demo_application/models/call_request.dart';

class UsersState extends Equatable {
  final List<User> users;
  final User? currentUser;
  final bool loading;
  final String? error;
  final bool callInitiated;
  final CallRequest? activeCall;

  const UsersState({
    this.users = const [],
    this.currentUser,
    this.loading = false,
    this.error,
    this.callInitiated = false,
    this.activeCall,
  });

  UsersState copyWith({
    List<User>? users,
    User? currentUser,
    bool? loading,
    String? error,
    bool? callInitiated,
    CallRequest? activeCall,
  }) {
    return UsersState(
      users: users ?? this.users,
      currentUser: currentUser ?? this.currentUser,
      loading: loading ?? this.loading,
      error: error,
      callInitiated: callInitiated ?? this.callInitiated,
      activeCall: activeCall ?? this.activeCall,
    );
  }

  UsersState clearError() {
    return copyWith(error: null);
  }

  @override
  List<Object?> get props => [
        users,
        currentUser,
        loading,
        error,
        callInitiated,
        activeCall,
      ];
}
